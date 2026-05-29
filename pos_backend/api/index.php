<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/helpers/response.php';
require_once __DIR__ . '/middleware/auth.php';
require_once __DIR__ . '/controllers/AuthController.php';
require_once __DIR__ . '/controllers/CategoryController.php';
require_once __DIR__ . '/controllers/ProductController.php';
require_once __DIR__ . '/controllers/OrderController.php';

// Parse URI — support PATH_INFO and remove index.php or script folder prefixes
if (!empty($_SERVER['PATH_INFO'])) {
    $uri = $_SERVER['PATH_INFO'];
} else {
    $rawUri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
    $rawUri = rtrim($rawUri, '/');
    $scriptName = str_replace('\\', '/', $_SERVER['SCRIPT_NAME']);
    $scriptDir = rtrim(str_replace('\\', '/', dirname($scriptName)), '/');
    $cleanUri = $rawUri;
    if (strpos($cleanUri, $scriptName) === 0) {
        $cleanUri = substr($cleanUri, strlen($scriptName));
    } elseif (strpos($cleanUri, $scriptDir) === 0) {
        $cleanUri = substr($cleanUri, strlen($scriptDir));
    }
    $cleanUri = str_replace('/index.php', '', $cleanUri);
    $uri = '/' . trim($cleanUri, '/');
}
$uri = $uri === '' ? '/' : $uri;
$method = $_SERVER['REQUEST_METHOD'];

if ($uri === '/debug' && $method === 'GET') {
    sendResponse(200, true, 'debug route', [
        'uri' => $uri,
        'request_uri' => $_SERVER['REQUEST_URI'],
        'script_name' => $_SERVER['SCRIPT_NAME'],
        'path_info' => $_SERVER['PATH_INFO'] ?? null,
        'method' => $method
    ]);
}

// ================================================
// AUTH ROUTES
// ================================================
if ($uri === '/login') {
    if ($method === 'POST') {
        (new AuthController())->login();
    }
    sendResponse(405, false, 'Method not allowed. Use POST for /login.');
}

if ($uri === '/logout') {
    if ($method === 'POST') {
        (new AuthController())->logout();
    }
    sendResponse(405, false, 'Method not allowed. Use POST for /logout.');
}

// ================================================
// CATEGORY ROUTES
// ================================================
if ($uri === '/categories') {
    $ctrl = new CategoryController();

    if ($method === 'GET' && isset($_GET['id'])) {
        $ctrl->show();
    } elseif ($method === 'GET') {
        $ctrl->index();
    } elseif ($method === 'POST') {
        $ctrl->store();
    } elseif ($method === 'PUT') {
        $ctrl->update();
    } elseif ($method === 'DELETE') {
        $ctrl->destroy();
    } else {
        sendResponse(405, false, 'Method not allowed.');
    }
}

// ================================================
// PRODUCT ROUTES
// ================================================
if ($uri === '/products') {
    $ctrl = new ProductController();

    if ($method === 'GET' && isset($_GET['search'])) {
        $ctrl->search();
    } elseif ($method === 'GET' && isset($_GET['id'])) {
        $ctrl->show();
    } elseif ($method === 'GET') {
        $ctrl->index();
    } elseif ($method === 'POST') {
        $ctrl->store();
    } elseif ($method === 'PUT') {
        $ctrl->update();
    } elseif ($method === 'DELETE') {
        $ctrl->destroy();
    } else {
        sendResponse(405, false, 'Method not allowed.');
    }
}

// ================================================
// ORDER ROUTES
// ================================================
if ($uri === '/orders') {
    $ctrl = new OrderController();

    if ($method === 'GET' && isset($_GET['id'])) {
        $ctrl->show();
    } elseif ($method === 'GET') {
        $ctrl->index();
    } elseif ($method === 'POST') {
        $ctrl->store();
    } else {
        sendResponse(405, false, 'Method not allowed.');
    }
}

// ================================================
// 404 — No route matched
// ================================================
sendResponse(404, false, 'Route not found.');
