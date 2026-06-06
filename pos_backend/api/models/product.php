<?php
class ProductModel
{
    private $conn;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }
    // get all products
    public function getAll(): array
    {
        $result   = $this->conn->query(
            "SELECT p.id, p.category_id, c.category_name,
                    p.product_name, p.price, p.stock, p.created_at
            FROM products p
            JOIN categories c ON p.category_id = c.id
            ORDER BY p.id"
        );
        $products = [];
        while ($row = $result->fetch_assoc()) {
            $products[] = $row;
        }
        return $products;
    }

    // get product by ID
    public function getById(int $id): ?array
    {
        $stmt = $this->conn->prepare("SELECT p.id, p.category_id, c.category_name,
                    p.product_name, p.price, p.stock, p.created_at
            FROM products p
            JOIN categories c ON p.category_id = c.id
            WHERE p.id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        return $stmt->get_result()->fetch_assoc();
    }

    // Search products by name
    public function search(string $query): array
    {
        $stmt = $this->conn->prepare(
            "SELECT p.id, 
                    p.product_name, p.price, p.stock, c.category_name, p.created_at
            FROM products p
            JOIN categories c ON p.category_id = c.id
            WHERE p.product_name LIKE CONCAT('%', ?, '%')
            ORDER BY p.product_name"
        );
        $stmt->bind_param("s", $query);
        $stmt->execute();
        $result   = $stmt->get_result();
        $products = [];
        while ($row = $result->fetch_assoc()) {
            $products[] = $row;
        }
        return $products;
    }

    // Create a new product
    public function create(array $data): bool
    {
        $stmt = $this->conn->prepare("INSERT INTO products (product_name, price, stock, category_id) VALUES (?, ?, ?, ?)");
        $stmt->bind_param(
            "sdii",
            $data['product_name'],
            $data['price'],
            $data['stock'],
            $data['category_id']
        );
        return $stmt->execute();
    }

    // Update an existing product
    public function update(int $id, array $data): bool
    {
        $stmt = $this->conn->prepare("UPDATE products SET product_name = ?, price = ?, stock = ?, category_id = ? WHERE id = ?");
        $stmt->bind_param(
            "sdiii",
            $data['product_name'],
            $data['price'],
            $data['stock'],
            $data['category_id'],
            $id
        );
        return $stmt->execute();
    }

    // Delete a product
    public function delete(int $id): bool
    {
        $stmt = $this->conn->prepare("DELETE FROM products WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        return $stmt->affected_rows > 0;
    }

    // Deduct stock for a product (used when creating an order)
    public function deductStock(int $id, int $quantity): bool
    {
        $stmt = $this->conn->prepare("UPDATE products SET stock = stock - ? WHERE id = ? AND stock >= ?");
        $stmt->bind_param("iii", $quantity, $id, $quantity);
        $stmt->execute();
        return $stmt->affected_rows > 0;
    }
    // Check if product has sufficient stock
    public function hasSufficientStock(int $id, int $quantity): bool
    {
        $stmt = $this->conn->prepare("SELECT stock FROM products WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $result = $stmt->get_result();
        if ($result->num_rows === 0) {
            return false; // Product not found
        }
        $row = $result->fetch_assoc();
        return  $row && (int) $row['stock'] >= $quantity;
    }
}
