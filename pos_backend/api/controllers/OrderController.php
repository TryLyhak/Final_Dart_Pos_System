<?php
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/models/order.php';
require_once dirname(__DIR__) . '/models/product.php';
require_once dirname(__DIR__) . '/helpers/response.php';

class OrderController
{
    private $orderModel;
    private $productModel;

    public function __construct()
    {
        $db = new Database();
        $connection = $db->connect();
        $this->orderModel = new OrderModel($connection);
        $this->productModel = new ProductModel($connection);
    }

    public function getOrders(): void
    {
        $orders = $this->orderModel->getAllOrders();
        sendResponse(200, true, 'Orders fetched.', $orders);
    }


    public function getOrderById(): void
    {
        $id = (int) ($_GET['id'] ?? ($_GET['order_id'] ?? 0));
        $order = $this->orderModel->getOrderById($id);

        if (!$order) {
            sendResponse(404, false, 'Order not found.');
            return;
        }
        $order['items'] = $this->orderModel->getOrderItems($id);
        sendResponse(200, true, 'Order found.', $order);
    }

    public function createOrder(): void
    {
        $body = json_decode(file_get_contents('php://input'), true);
        $items = $body['items'] ?? [];
        $userId = (int) ($body['user_id'] ?? 0);

        if (empty($items) || $userId === 0) {
            sendResponse(400, false, 'Invalid order payload or missing user ID.');
            return;
        }

        $connection = $this->orderModel->getConn();
        $connection->begin_transaction();

        try {
            $total = 0.0;
            $validatedProducts = []; // Cache to prevent fetching products twice

            // Loop 1: Validate everything first
            foreach ($items as $item) {
                $productId = (int) ($item['product_id'] ?? 0);
                $quantity  = (int) ($item['quantity']   ?? 0);

                if ($quantity <= 0) {
                    throw new Exception("Invalid quantity for product ID $productId.");
                }
                $product = $this->productModel->getById($productId);

                if (!$product) {
                    throw new Exception("Product ID $productId not found.");
                }
                if (!$this->productModel->hasSufficientStock($productId, $quantity)) {
                    throw new Exception(
                        "Insufficient stock for '{$product['product_name']}'. " .
                            "Available: {$product['stock']}."
                    );
                }
                $price = (float) $product['price'];
                $total += $price * $quantity;

                // Save the data for the insertion loop
                $validatedProducts[] = [
                    'product_id' => $productId,
                    'quantity'   => $quantity,
                    'unit_price' => $price,
                    'subtotal'   => $price * $quantity
                ];
            }

            // Step 2: Create the main order record
            $orderId = $this->orderModel->createOrder([
                'user_id' => $userId,
                'total'   => $total
            ]);

            // Loop 3: Process insertion and stock deduction instantly from cache
            foreach ($validatedProducts as $p) {
                $this->orderModel->addOrderItem($orderId, [
                    'product_id' => $p['product_id'],
                    'quantity'   => $p['quantity'],
                    'unit_price' => $p['unit_price'],
                    'subtotal'   => $p['subtotal']
                ]);

                $this->productModel->deductStock($p['product_id'], $p['quantity']);
            }

            $connection->commit();
            sendResponse(201, true, 'Order placed successfully.', [
                'order_id' => $orderId,
                'total'    => number_format($total, 2, '.', '')
            ]);
        } catch (Exception $e) {
            $connection->rollback();
            sendResponse(400, false, $e->getMessage());
        }
    }
}
