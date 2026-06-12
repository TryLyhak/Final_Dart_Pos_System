<?php
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/models/product.php';
require_once dirname(__DIR__) . '/helpers/response.php';


class ProductController
{
    private $productModel;

    public function __construct()
    {
        $db                 = new Database();
        $conn               = $db->connect();
        $this->productModel = new ProductModel($conn);
    }

    // GET /products — return all products
    public function getProducts(): void
    {
        $products = $this->productModel->getAll();
        sendResponse(200, true, 'Products fetched.', $products);
    }

    // GET /products?id=X — return single product
    public function getProductById(): void
    {
        $id      = (int) ($_GET['id'] ?? 0);
        $product = $this->productModel->getById($id);
        if (!$product) {
            sendResponse(404, false, 'Product not found.');
        }
        sendResponse(200, true, 'Product found.', $product);
    }

    public function searchProduct(): void
    {
        $keyword  = trim($_GET['search'] ?? '');
        $products = $this->productModel->search($keyword);
        if (!$products) {
            sendResponse(404, false, 'No products found.');
        }
        sendResponse(200, true, 'Search results.', $products);
    }

    // POST /products — create product
    public function createProduct(): void
    {

        $body        = json_decode(file_get_contents('php://input'), true);
        $categoryId  = $body['category_id']  ?? 0;
        $productName = $body['product_name'] ?? '';
        $price       = $body['price']        ?? 0;
        $stock       = $body['stock']        ?? 0;

        $created = $this->productModel->create([
            'category_id'  => (int)   $categoryId,
            'product_name' => $productName,
            'price'        => (float) $price,
            'stock'        => (int)   $stock,
        ]);

        $created
            ? sendResponse(201, true,  'Product created.')
            : sendResponse(500, false, 'Failed to create product.');
    }

    // PUT /products?id=X — update product
    public function updateProduct(): void
    {
        $id          = (int) ($_GET['id'] ?? 0);
        $body        = json_decode(file_get_contents('php://input'), true);
        $categoryId  = $body['category_id']  ?? 0;
        $productName = $body['product_name'] ?? '';
        $price       = $body['price']        ?? 0;
        $stock       = $body['stock']        ?? 0;

        $updated = $this->productModel->update($id, [
            'category_id'  => (int)   $categoryId,
            'product_name' => $productName,
            'price'        => (float) $price,
            'stock'        => (int)   $stock,
        ]);

        $updated
            ? sendResponse(200, true,  'Product updated.')
            : sendResponse(500, false, 'Failed to update product.');
    }

    // DELETE /products?id=X — delete product
    public function deleteProductById(): void
    {
        $id = (int) ($_GET['id'] ?? 0);
        if ($id <= 0) {
            sendResponse(400, false, 'Invalid product ID.');
        }

        $deleted = $this->productModel->delete($id);

        $deleted
            ? sendResponse(200, true,  'Product deleted.')
            : sendResponse(500, false, 'Failed to delete product.');
    }
}
