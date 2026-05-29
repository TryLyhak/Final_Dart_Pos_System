<?php
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/models/product.php';
require_once dirname(__DIR__) . '/models/category.php';
require_once dirname(__DIR__) . '/helpers/response.php';
require_once dirname(__DIR__) . '/middleware/auth.php';

class ProductController
{
    private $productModel;
    private $categoryModel;

    public function __construct()
    {
        $db = new Database();
        $conn = $db->connect();
        $this->productModel = new ProductModel($conn);
        $this->categoryModel = new CategoryModel($conn);
    }

    // GET /api/products — any authenticated user
    public function index(): void
    {
        requireAuth();
        $products = $this->productModel->getAllProducts();
        sendResponse(200, true, 'Products fetched.', $products);
    }

    // GET /api/products?id=X — any authenticated user
    public function show(): void
    {
        requireAuth();
        $id      = (int) ($_GET['id'] ?? 0);
        $product = $this->productModel->getProductById($id);

        if (!$product) {
            sendResponse(404, false, 'Product not found.');
        }

        sendResponse(200, true, 'Product found.', $product);
    }

    // GET /api/products?search=keyword — any authenticated user
    public function search(): void
    {
        requireAuth();
        $keyword  = trim($_GET['search'] ?? '');

        if (empty($keyword)) {
            sendResponse(400, false, 'Search keyword is required.');
        }

        $products = $this->productModel->searchProducts($keyword);
        sendResponse(200, true, 'Search results.', $products);
    }

    // POST /api/products — admin only
    public function store(): void
    {
        requireRole('admin');
        $body = json_decode(file_get_contents('php://input'), true);

        $product_name   = trim($body['product_name']        ?? '');
        $price          = (float) ($body['price']   ?? 0);
        $stock          = (int)   ($body['stock']   ?? 0);
        $categoryId     = (int)   ($body['category_id'] ?? 0);

        // Validate required fields
        if (empty($product_name) || $price <= 0 || $stock <= 0 || $categoryId <= 0) {
            sendResponse(400, false, 'Name, valid price, stock, and category_id are required.');
        }

        // Check category exists
        if (!$this->categoryModel->categoryExists($categoryId)) {
            sendResponse(404, false, 'Category not found.');
        }

        $created = $this->productModel->createProduct([
            'product_name'   => $product_name,
            'price'          => $price,
            'stock'          => $stock,
            'category_id'    => $categoryId,
        ]);

        $created
            ? sendResponse(201, true,  'Product created.')
            : sendResponse(500, false, 'Failed to create product.');
    }

    // PUT /api/products?id=X — admin only
    public function update(): void
    {
        requireRole('admin');
        $id   = (int) ($_GET['id'] ?? 0);
        $body = json_decode(file_get_contents('php://input'), true);

        $product_name   = trim($body['product_name']        ?? '');
        $price          = (float) ($body['price']   ?? 0);
        $stock          = (int)   ($body['stock']   ?? 0);
        $categoryId     = (int)   ($body['category_id'] ?? 0);

        // Validate required fields
        if (empty($product_name) || $price <= 0 || $stock <= 0 || $categoryId <= 0) {
            sendResponse(400, false, 'Name, valid price, stock, and category_id are required.');
        }

        // Check product exists
        if (!$this->productModel->productExists($id)) {
            sendResponse(404, false, 'Product not found.');
        }

        // Check category exists
        if (!$this->categoryModel->categoryExists($categoryId)) {
            sendResponse(404, false, 'Category not found.');
        }

        $updated = $this->productModel->updateProduct($id, [
            'product_name'   => $product_name,
            'price'          => $price,
            'stock'          => $stock,
            'category_id'    => $categoryId,
        ]);

        $updated
            ? sendResponse(200, true,  'Product updated.')
            : sendResponse(500, false, 'Failed to update product.');
    }

    // DELETE /api/products?id=X — admin only
    public function destroy(): void
    {
        requireRole('admin');
        $id = (int) ($_GET['id'] ?? 0);

        // Check product exists
        if (!$this->productModel->productExists($id)) {
            sendResponse(404, false, 'Product not found.');
        }

        $deleted = $this->productModel->deleteProduct($id);

        $deleted
            ? sendResponse(200, true,  'Product deleted.')
            : sendResponse(500, false, 'Failed to delete product.');
    }
}
