<?php
require_once dirname(__DIR__) . '/helpers/response.php';
function requireAuth(): array
{
    $headers     = getallheaders();
    $authHeader  = $headers['Authorization'] ?? '';

    // Check if Bearer token exists
    if (!str_starts_with($authHeader, 'Bearer ')) {
        sendResponse(401, false, 'Unauthorized: No token provided.');
    }

    // Extract token after "Bearer "
    $token   = substr($authHeader, 7);
    $decoded = base64_decode($token);
    $payload = json_decode($decoded, true);

    // Validate token payload
    if (!$payload || empty($payload['user_id'])) {
        sendResponse(401, false, 'Unauthorized: Invalid token.');
    }

    return $payload; // ['user_id' => ..., 'role' => ...]
}

function requireRole(string $role): array
{
    $payload = requireAuth();

    if ($payload['role'] !== $role) {
        sendResponse(403, false, 'Forbidden: Insufficient permissions.');
    }

    return $payload;
}
