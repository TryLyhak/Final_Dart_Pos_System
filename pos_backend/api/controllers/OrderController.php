<?php
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/models/order.php';
require_once dirname(__DIR__) . '/models/product.php';
require_once dirname(__DIR__) . '/helpers/response.php';
require_once dirname(__DIR__) . '/middleware/auth.php';
class OrderController
{
    private $orderModel;
    private $productModel;

    public function __construct()
    {
        $db = new Database();
        $conn = $db->connect();
        $this->orderModel = new OrderModel($conn);
        $this->productModel = new ProductModel($conn);
    }

    // GET /api/orders — any authenticated user (but regular users can only see their own orders, while admin can see all)
    public function index(): void
    {
        $payload = requireAuth();

        $orders = $payload['role'] === 'admin'
            ? $this->orderModel->getAllOrders()
            : $this->orderModel->getOrdersByUserId($payload['user_id']);
        sendResponse(200, true, 'Orders fetched.', $orders);
    }

    // GET /api/orders?id=X — any authenticated user (but can only view their own orders unless admin)
    public function show(): void
    {
        $payload = requireAuth();
        $id      = (int) ($_GET['id'] ?? 0);
        $order   = $this->orderModel->getOrdersByUserId($id);

        if (!$order) {
            sendResponse(404, false, 'Order not found.');
        }
        if ($payload['role'] !== 'admin' && (int) $order['user_id'] !== (int) $payload['user_id']) {
            sendResponse(403, false, 'Access denied. You can only view your own orders.');
        }
        $order['items'] = $this->orderModel->getOrderItems($id);
        sendResponse(200, true, 'Order found.', $order);
    }


    // POST /api/orders — checkout (any authenticated user)
    public function store(): void
    {
        $payload = requireAuth();
        $body    = json_decode(file_get_contents('php://input'), true);
        $items   = $body['items'] ?? [];

        // Validate cart is not empty
        if (empty($items)) {
            sendResponse(400, false, 'Cart is empty.');
        }

        $connection = $this->orderModel->getConn();

        // Start transaction — all or nothing
        $connection->begin_transaction();

        try {
            $total = 0.0;

            // Step 1 — Validate each item stock and calculate total
            foreach ($items as $item) {
                $productId = (int) ($item['product_id'] ?? 0);
                $quantity  = (int) ($item['quantity']   ?? 0);

                if ($quantity <= 0) {
                    throw new Exception("Invalid quantity for product ID $productId.");
                }

                $product = $this->productModel->getProductById($productId);

                if (!$product) {
                    throw new Exception("Product ID $productId not found.");
                }

                if (!$this->productModel->hasSufficientStock($productId, $quantity)) {
                    throw new Exception(
                        "Insufficient stock for '{$product['product_name']}'. " .
                            "Available: {$product['stock']}."
                    );
                }

                $total += (float) $product['price'] * $quantity;
            }

            // Step 2 — Create the order record
            $orderId = $this->orderModel->createOrder([
                'user_id' => $payload['user_id'],
                'total'   => $total
            ]);

            // Step 3 — Insert each order item and deduct stock
            foreach ($items as $item) {
                $productId = (int) $item['product_id'];
                $quantity  = (int) $item['quantity'];
                $product   = $this->productModel->getProductById($productId);
                $unitPrice = (float) $product['price'];
                $subtotal  = $unitPrice * $quantity;

                // Insert order item line
                $this->orderModel->addOrderItem($orderId, [
                    'product_id' => $productId,
                    'quantity'   => $quantity,
                    'unit_price' => $unitPrice,
                    'subtotal'   => $subtotal
                ]);
                // Deduct product stock
                $this->productModel->deductStock($productId, $quantity);
            }

            // All good — commit transaction
            $connection->commit();

            sendResponse(201, true, 'Order placed successfully.', [
                'order_id' => $orderId,
                'total'    => number_format($total, 2, '.', '')
            ]);
        } catch (Exception $e) {
            // Something failed — rollback everything
            $connection->rollback();
            sendResponse(400, false, $e->getMessage());
        }
    }
}
