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
        $result = $this->conn->query("SELECT id, user_id, total, status, created_at FROM orders ORDER BY id");
        $orders = [];
        while ($row = $result->fetch_assoc()) {
            $orders[] = $row;
        }
        return $orders;
    }

    public function getOrderById(int $orderId): ?array
    {
        $stmt = $this->conn->prepare(
            "SELECT id, user_id, total, status, created_at FROM orders WHERE id = ?"
        );
        $stmt->bind_param("i", $orderId);
        $stmt->execute();

        return $stmt->get_result()->fetch_assoc();
    }
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

    public function getOrderItems(int $orderId): array
    {
        $stmt = $this->conn->prepare(
            "SELECT id, order_id, product_id, product_name, quantity, unit_price, subtotal
             FROM order_items
             WHERE order_id = ?"
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

    public function addOrderItem(int $orderId, array $data): bool
    {
        $stmt = $this->conn->prepare("INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->bind_param(
            "iisidd",
            $orderId,
            $data['product_id'],
            $data['product_name'],
            $data['quantity'],
            $data['unit_price'],
            $data['subtotal']
        );
        return $stmt->execute();
    }

    public function getConn()
    {
        return $this->conn;
    }
}
