<?php
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/models/category.php';
require_once dirname(__DIR__) . '/helpers/response.php';

class CategoryController
{
    private $categoryModel;

    public function __construct()
    {
        $db                  = new Database();
        $conn                = $db->connect();
        $this->categoryModel = new CategoryModel($conn);
    }
    // GET /categories — return all categories
    public function getAllCategories(): void
    {
        $categories = $this->categoryModel->getAll();
        sendResponse(200, true, 'Categories fetched.', $categories);
    }

    // GET /categories?id=X — return single category
    public function getCategoryById(): void
    {
        $id       = (int) ($_GET['id'] ?? 0);
        $category = $this->categoryModel->getById($id);

        if (!$category) {
            sendResponse(404, false, 'Category not found.');
        }
        sendResponse(200, true, 'Category found.', $category);
    }

    // POST /categories — create category
    public function createCategory(): void
    {
        $body         = json_decode(file_get_contents('php://input'), true);
        $categoryName = $body['category_name'] ?? '';

        $created = $this->categoryModel->create([
            'category_name' => $categoryName,
        ]);

        $created
            ? sendResponse(201, true,  'Category created.')
            : sendResponse(500, false, 'Failed to create category.');
    }

    // PUT /categories?id=X — update category
    public function updateCategory(): void
    {
        $id           = (int) ($_GET['id'] ?? 0);
        $body         = json_decode(file_get_contents('php://input'), true);
        $categoryName = $body['category_name'] ?? '';

        $updated = $this->categoryModel->update($id, [
            'category_name' => $categoryName,
        ]);

        $updated
            ? sendResponse(200, true,  'Category updated.')
            : sendResponse(500, false, 'Failed to update category.');
    }

    // DELETE /categories?id=X — delete category
    public function deleteCategoryById(): void
    {
        $id      = (int) ($_GET['id'] ?? 0);
        $deleted = $this->categoryModel->delete($id);
        $deleted
            ? sendResponse(200, true,  'Category deleted.')
            : sendResponse(500, false, 'Failed to delete category.');
    }
}
