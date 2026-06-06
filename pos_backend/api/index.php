<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/helpers/response.php';
require_once __DIR__ . '/controllers/AuthController.php';
require_once __DIR__ . '/controllers/CategoryController.php';
require_once __DIR__ . '/controllers/ProductController.php';
require_once __DIR__ . '/controllers/OrderController.php';

// Parse URI
$rawUri   = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$rawUri   = rtrim($rawUri, '/');
$rawUri   = str_replace('/index.php', '', $rawUri);
$basePath = '/Dart_POS_Final/pos_backend/api';
$uri      = '/' . trim(str_replace($basePath, '', $rawUri), '/');
$method   = $_SERVER['REQUEST_METHOD'];

// ── AUTH ROUTES ───────────────────────────────
if ($uri === '/login'  && $method === 'POST') {
    (new AuthController())->login();
}
if ($uri === '/logout' && $method === 'POST') {
    (new AuthController())->logout();
}

// ── CATEGORY ROUTES ───────────────────────────
if ($uri === '/categories') {
    $ctrl = new CategoryController();
    if ($method === 'GET' && isset($_GET['id'])) {
        $ctrl->getCategoryById();
    } elseif ($method === 'GET') {
        $ctrl->getAllCategories();
    } elseif ($method === 'POST') {
        $ctrl->createCategory();
    } elseif ($method === 'PUT') {
        $ctrl->updateCategory();
    } elseif ($method === 'DELETE') {
        $ctrl->deleteCategoryById();
    } else {
        sendResponse(405, false, 'Method not allowed.');
    }
}

// ── PRODUCT ROUTES ────────────────────────────
if ($uri === '/products') {
    $ctrl = new ProductController();
    if ($method === 'GET' && isset($_GET['search'])) {
        $ctrl->searchProduct();
    } elseif ($method === 'GET' && isset($_GET['id'])) {
        $ctrl->getProductById();
    } elseif ($method === 'GET') {
        $ctrl->getProducts();
    } elseif ($method === 'POST') {
        $ctrl->createProduct();
    } elseif ($method === 'PUT') {
        $ctrl->updateProduct();
    } elseif ($method === 'DELETE') {
        $ctrl->deleteProductById();
    } else {
        sendResponse(405, false, 'Method not allowed.');
    }
}

// ── ORDER ROUTES ──────────────────────────────
if ($uri === '/orders') {
    $ctrl = new OrderController();
    if ($method === 'GET' && isset($_GET['id'])) {
        $ctrl->getOrderById();
    } elseif ($method === 'GET') {
        $ctrl->getOrders();
    } elseif ($method === 'POST') {
        $ctrl->createOrder();
    } else {
        sendResponse(405, false, 'Method not allowed.');
    }
}

sendResponse(404, false, 'Route not found.');
