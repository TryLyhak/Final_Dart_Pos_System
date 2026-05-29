<?php
class UserModel
{
    private $conn;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }



    // Get user by username (for authentication)
    public function getUserByUsername(string $username): ?array
    {
        $stmt = $this->conn->prepare("SELECT * FROM users WHERE user_name = ?");
        $stmt->bind_param("s", $username);
        $stmt->execute();
        return $stmt->get_result()->fetch_assoc();
    }

    // Get user by ID
    public function getUserById(int $id): ?array
    {
        $stmt = $this->conn->prepare("SELECT * FROM users WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        return $stmt->get_result()->fetch_assoc();
    }

    // Get all users (for admin management)
    public function getAllUsers(): array
    {
        $result = $this->conn->query("SELECT id, user_name AS username, role FROM users ORDER BY id");
        $users = [];
        while ($row = $result->fetch_assoc()) {
            $users[] = $row;
        }
        return $users;
    }

    // Check if user exists
    public function userExists(string $username): bool
    {
        $stmt = $this->conn->prepare("SELECT id FROM users WHERE user_name = ?");
        $stmt->bind_param("s", $username);
        $stmt->execute();
        return $stmt->get_result()->num_rows > 0;
    }

    // Create a new user
    public function createUser(array $data): bool
    {
        $stmt = $this->conn->prepare("INSERT INTO users (user_name, password, role) VALUES (?, ?, ?)");
        $stmt->bind_param(
            "sss",
            $data['user_name'],
            $data['password'],
            $data['role']
        );
        return $stmt->execute();
    }

    // Update an existing user
    public function updateUser(int $id, array $data): bool
    {
        $stmt = $this->conn->prepare("UPDATE users SET user_name = ?, password = ?, role = ? WHERE id = ?");
        $stmt->bind_param(
            "sssi",
            $data['user_name'],
            $data['password'],
            $data['role'],
            $id
        );
        return $stmt->execute();
    }

    // Delete a user
    public function deleteUser(int $id): bool
    {
        $stmt = $this->conn->prepare("DELETE FROM users WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        return $stmt->affected_rows > 0;
    }
}
