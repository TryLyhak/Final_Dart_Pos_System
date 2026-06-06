<?php
class CategoryModel
{
    private $conn;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }

    // Implement category-related database operations here
    public function getAll(): array
    {
        $result = $this->conn->query("SELECT id, category_name FROM categories ORDER BY id");
        $categories = [];
        while ($row = $result->fetch_assoc()) {
            $categories[] = $row;
        }
        return $categories;
    }

    // Get category by ID
    public function getById(int $id): ?array
    {
        $stmt = $this->conn->prepare("SELECT id, category_name FROM categories WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        return $stmt->get_result()->fetch_assoc();
    }

    // Create a new category
    public function create(array $data): bool
    {
        $stmt = $this->conn->prepare("INSERT INTO categories (category_name) VALUES (?)");
        $stmt->bind_param(
            "s",
            $data['category_name']
        );
        return $stmt->execute();
    }

    // Update an existing category
    public function update(int $id, array $data): bool
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
    public function delete(int $id): bool
    {
        $stmt = $this->conn->prepare("DELETE FROM categories WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        return $stmt->affected_rows > 0;
    }
}
