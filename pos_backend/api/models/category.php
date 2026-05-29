<?php
class CategoryModel
{
    private $conn;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }

    // Implement category-related database operations here
    public function getAllCategories(): array
    {
        $result = $this->conn->query("SELECT id, category_name FROM categories ORDER BY id");
        $categories = [];
        while ($row = $result->fetch_assoc()) {
            $categories[] = $row;
        }
        return $categories;
    }

    // Get category by ID
    public function getCategoryById(int $id): ?array
    {
        $stmt = $this->conn->prepare("SELECT id, category_name FROM categories WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        return $stmt->get_result()->fetch_assoc();
    }

    // Create a new category
    public function createCategory(array $data): bool
    {
        $stmt = $this->conn->prepare("INSERT INTO categories (category_name) VALUES (?)");
        $stmt->bind_param(
            "s",
            $data['category_name']
        );
        return $stmt->execute();
    }

    // Update an existing category
    public function updateCategory(int $id, array $data): bool
    {
        $stmt = $this->conn->prepare("UPDATE categories SET category_name = ? WHERE id = ?");
        $stmt->bind_param(
            "si",
            $data['category_name'],
            $id
        );
        return $stmt->execute();
    }

    // Delete a category
    public function deleteCategory(int $id): bool
    {
        $stmt = $this->conn->prepare("DELETE FROM categories WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        return $stmt->affected_rows > 0;
    }

    // Check if category name already exists (for create)
    public function categoryExists(string $name): bool
    {
        $stmt = $this->conn->prepare("SELECT id FROM categories WHERE category_name = ?");
        $stmt->bind_param("s", $name);
        $stmt->execute();
        return $stmt->get_result()->num_rows > 0;
    }

    // Check if category exists by ID (for update/delete)
    public function categoryExistsById(int $id): bool
    {
        $stmt = $this->conn->prepare("SELECT id FROM categories WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        return $stmt->get_result()->num_rows > 0;
    }

    // Check if category has products before allowing deletion
    public function hasProducts(int $id): bool
    {
        $stmt = $this->conn->prepare("SELECT COUNT(*) AS total FROM products WHERE category_id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        return $row['total'] > 0;
    }
}
