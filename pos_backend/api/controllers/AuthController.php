<?php
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/models/user.php';
require_once dirname(__DIR__) . '/helpers/response.php';

class AuthController
{
    private $userModel;

    public function __construct()
    {
        $db            = new Database();
        $conn          = $db->connect();
        $this->userModel = new UserModel($conn);
    }
    // POST /login — verify credentials + return token
    public function login(): void
    {
        $body     = json_decode(file_get_contents('php://input'), true);
        $username = trim($body['username'] ?? '');
        $password = trim($body['password'] ?? '');
        $user = $this->userModel->getUserByUsername($username);
        if (!$user) {
            sendResponse(401, false, 'Invalid username or password.');
        }
        // Plain text password check — matches your DB
        if ($user['password'] !== $password) {
            sendResponse(401, false, 'Invalid username or password.');
        }
        sendResponse(200, true, 'Login successful.', [
            'user'  => [
                'id'       => $user['id'],
                'username' => $user['user_name'],
                'role'     => $user['role']
            ]
        ]);
    }
    public function logout(): void
    {
        sendResponse(200, true, 'Logged out successfully.');
    }
}
