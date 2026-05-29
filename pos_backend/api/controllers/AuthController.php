<?php
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/models/user.php';
require_once dirname(__DIR__) . '/helpers/response.php';

class AuthController
{
    private $userModel;

    public function __construct()
    {
        $db              = new Database();
        $connection      = $db->connect();
        $this->userModel = new UserModel($connection);
    }

    // POST /login
    public function login(): void
    {
        $body = json_decode(file_get_contents('php://input'), true);

        // Validate JSON body exists
        if (!$body) {
            sendResponse(400, false, 'Invalid JSON body.');
        }

        $user_name  = trim($body['username'] ?? '');
        $password   = trim($body['password'] ?? '');

        // Validate required fields
        if (empty($user_name)) {
            sendResponse(400, false, 'Username is required.');
        }

        if (empty($password)) {
            sendResponse(400, false, 'Password is required.');
        }

        // Find user by username
        $user = $this->userModel->getUserByUsername($user_name);

        if (!$user) {
            sendResponse(401, false, 'Invalid username or password.');
        }

        // Verify password
        $isValidPassword = password_verify($password, $user['password']);
        if (!$isValidPassword) {
            $isValidPassword = $password === $user['password'];
        }

        if (!$isValidPassword) {
            sendResponse(401, false, 'Invalid username or password.');
        }

        // Build base64 token
        $payload = json_encode([
            'user_id' => $user['id'],
            'role'    => $user['role']
        ]);
        $token = base64_encode($payload);

        sendResponse(200, true, 'Login successful.', [
            'token' => $token,
            'user'  => [
                'id'   => $user['id'],
                'name' => $user['user_name'],
                'role' => $user['role']
            ]
        ]);
    }

    // POST /logout
    public function logout(): void
    {
        sendResponse(200, true, 'Logged out successfully.');
    }
}
