<?php
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/models/category.php';
require_once dirname(__DIR__) . '/helpers/response.php';
require_once dirname(__DIR__) . '/middleware/auth.php';
class CategoryController
{
    private $categoryModel;

    public function __construct()
    {
        $db     = new Database();
        $conn   = $db->connect();
        $this->categoryModel  = new CategoryModel($conn);
    }

    // GET /api/categories — any authenticated user
    public function index(): void
    {
        $categories = $this->categoryModel->getAllCategories();
        sendResponse(200, true, 'Categories retrieved successfully.', $categories);
    }

    // GET /api/categories?id=X — any authenticated user
    public function show(): void
    {
        requireAuth();
        $id = (int)($_GET['id'] ?? 0);
        $category = $this->categoryModel->getCategoryById($id);
        if (!$category) {
            sendResponse(404, false, 'Category not found.');
        } else {
            sendResponse(200, true, 'Category retrieved successfully.', $category);
        }
    }

    // POST /api/categories — admin only
    public function store(): void
    {
        requireRole('admin');
        $body = json_decode(file_get_contents('php://input'), true);
        $name = trim($body['category_name'] ?? $body['name'] ?? '');
        if (empty($name)) {
            sendResponse(400, false, 'Category name is required.');
        }
        if ($this->categoryModel->categoryExists($name)) {
            sendResponse(409, false, 'Category name already exists.');
        }
        $created = $this->categoryModel->createCategory([
            'category_name' => $name
        ]);
        $created
            ? sendResponse(201, true, 'Category created successfully.')
            : sendResponse(500, false, 'Failed to create category.');
    }

    // PUT /api/categories?id=X — admin only
    public function update(): void
    {
        requireRole('admin');
        $id   = (int) ($_GET['id'] ?? 0);
        $body = json_decode(file_get_contents('php://input'), true);
        $name = trim($body['category_name'] ?? $body['name'] ?? '');

        // Validate input
        if (empty($name)) {
            sendResponse(400, false, 'Category name is required.');
        }

        // Check category exists
        if (!$this->categoryModel->categoryExistsById($id)) {
            sendResponse(404, false, 'Category not found.');
        }

        $updated = $this->categoryModel->updateCategory($id, [
            'category_name' => $name
        ]);

        $updated
            ? sendResponse(200, true,  'Category updated.')
            : sendResponse(500, false, 'Failed to update category.');
    }

    // DELETE /api/categories?id=X — admin only
    public function destroy(): void
    {
        requireRole('admin');
        $id = (int) ($_GET['id'] ?? 0);

        // Check category exists
        if (!$this->categoryModel->categoryExistsById($id)) {
            sendResponse(404, false, 'Category not found.');
        }

        // Prevent delete if category has products
        if ($this->categoryModel->hasProducts($id)) {
            sendResponse(
                409,
                false,
                'Cannot delete: category still has products. ' .
                    'Remove or reassign products first.'
            );
        }

        $deleted = $this->categoryModel->deleteCategory($id);

        $deleted
            ? sendResponse(200, true,  'Category deleted.')
            : sendResponse(500, false, 'Failed to delete category.');
    }
}
