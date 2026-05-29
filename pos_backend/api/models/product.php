<?php
class ProductModel
{
    private $conn;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }

    // get all products
    public function getAllProducts(): array
    {
        $result = $this->conn->query("SELECT id, product_name, price, stock, category_id FROM products ORDER BY id");
        $products = [];
        while ($row = $result->fetch_assoc()) {
            $products[] = $row;
        }
        return $products;
    }

    // get product by ID
    public function getProductById(int $id): ?array
    {
        $stmt = $this->conn->prepare("SELECT id, product_name, price, stock, category_id FROM products WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        return $stmt->get_result()->fetch_assoc();
    }

    // Search products by namw
    public function searchProducts(string $query): array
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
    public function createProduct(array $data): bool
    {
        $stmt = $this->conn->prepare("INSERT INTO products (product_name, price, stock, category_id) VALUES (?, ?, ?, ?)");
        $stmt->bind_param(
            "sdis",
            $data['product_name'],
            $data['price'],
            $data['stock'],
            $data['category_id']
        );
        return $stmt->execute();
    }

    // Update an existing product
    public function updateProduct(int $id, array $data): bool
    {
        $stmt = $this->conn->prepare("UPDATE products SET product_name = ?, price = ?, stock = ?, category_id = ? WHERE id = ?");
        $stmt->bind_param(
            "sdisi",
            $data['product_name'],
            $data['price'],
            $data['stock'],
            $data['category_id'],
            $id
        );
        return $stmt->execute();
    }

    // Delete a product
    public function deleteProduct(int $id): bool
    {
        $stmt = $this->conn->prepare("DELETE FROM products WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        return $stmt->affected_rows > 0;
    }


    // Check if product exists
    public function productExists(int $id): bool
    {
        $stmt = $this->conn->prepare(
            "SELECT COUNT(*) AS total
            FROM products
            WHERE id = ?"
        );
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $result = $stmt->get_result();
        $row    = $result->fetch_assoc();
        return (int) $row['total'] > 0;
    }

    // Deduct stock for a product (used when creating an order)
    public function deductStock(int $product_id, int $quantity): bool
    {
        $stmt = $this->conn->prepare("UPDATE products SET stock = stock - ? WHERE id = ? AND stock >= ?");
        $stmt->bind_param("iii", $quantity, $product_id, $quantity);
        return $stmt->execute() && $stmt->affected_rows > 0;
    }

    // Check if product has sufficient stock
    public function hasSufficientStock(int $product_id, int $quantity): bool
    {
        $stmt = $this->conn->prepare("SELECT stock FROM products WHERE id = ?");
        $stmt->bind_param("i", $product_id);
        $stmt->execute();
        $result = $stmt->get_result();
        if ($result->num_rows === 0) {
            return false; // Product not found
        }
        $row = $result->fetch_assoc();
        return  $row && (int) $row['stock'] >= $quantity;
    }
}
