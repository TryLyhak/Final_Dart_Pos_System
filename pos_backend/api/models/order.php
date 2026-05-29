<?php
class OrderModel
{
    private $conn;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }

    // get all orders
    public function getAllOrders(): array
    {
        $result = $this->conn->query("SELECT id, user_id, total, created_at FROM orders ORDER BY id");
        $orders = [];
        while ($row = $result->fetch_assoc()) {
            $orders[] = $row;
        }
        return $orders;
    }

    // get orders by user ID
    public function getOrdersByUserId(int $userId): array
    {
        $stmt = $this->conn->prepare("SELECT id, user_id, total, created_at FROM orders WHERE user_id = ?");
        $stmt->bind_param("i", $userId);
        $stmt->execute();
        $result = $stmt->get_result();
        $orders = [];
        while ($row = $result->fetch_assoc()) {
            $orders[] = $row;
        }
        return $orders;
    }

    // create a new order and return its ID
    public function createOrder(array $data): int
    {
        $stmt = $this->conn->prepare("INSERT INTO orders (user_id, total) VALUES (?, ?)");
        $stmt->bind_param(
            "id",
            $data['user_id'],
            $data['total']
        );
        $stmt->execute();
        return (int) $this->conn->insert_id;
    }

    // get order items for a specific order
    public function getOrderItems(int $orderId): array
    {
        $stmt = $this->conn->prepare(
            "SELECT oi.id, oi.product_id, oi.quantity, oi.unit_price, oi.subtotal, p.product_name
             FROM order_items oi
             JOIN products p ON oi.product_id = p.id
             WHERE oi.order_id = ?"
        );
        $stmt->bind_param("i", $orderId);
        $stmt->execute();
        $result = $stmt->get_result();
        $items  = [];
        while ($row = $result->fetch_assoc()) {
            $items[] = $row;
        }
        return $items;
    }

    // add an item to an order
    public function addOrderItem(int $orderId, array $data): bool
    {
        $stmt = $this->conn->prepare("INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (?, ?, ?, ?, ?)");
        $stmt->bind_param(
            "iiddd",
            $orderId,
            $data['product_id'],
            $data['quantity'],
            $data['unit_price'],
            $data['subtotal']
        );
        return $stmt->execute();
    }

    // Get the database connection (for transaction management in controller)
    public function getConn()
    {
        return $this->conn;
    }
}
