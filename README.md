# Final Dart POS System

A console-based point-of-sale system built with a Dart frontend and a PHP/MySQL REST API backend.

## Features

- Role-based login for administrators and sales users
- Category and product management
- Product search and inventory tracking
- Order creation and order history
- MySQL database schema with seed data

## Project structure

```text
pos_backend/
├── Database/        # MySQL schema and seed data
└── api/              # PHP REST API

pos_frontend/         # Dart console application
├── bin/main.dart     # Application entry point
├── lib/              # Services, models, menus, and helpers
└── test/             # Dart tests
```

## Requirements

- PHP 8 or later with the `mysqli` extension
- MySQL or MariaDB
- Dart SDK 3.10 or later

## Backend setup

1. Create the database and seed the initial data:

   ```bash
   mysql -u root -p < pos_backend/Database/pos_db.sql
   ```

2. Update the connection values in `pos_backend/api/config/database.php` if your MySQL credentials differ from the development defaults.

3. Serve the API with PHP. From the repository root, for example:

   ```bash
   php -S localhost:8000 -t pos_backend/api
   ```

4. Confirm the API URL used by the Dart client in `pos_frontend/lib/services/api_services.dart`. The default client URL is `http://localhost/index.php`; change it if your PHP server uses another host, port, or path.

## Frontend setup and run

```bash
cd pos_frontend
dart pub get
dart run
```

The application starts with a login prompt. The SQL seed file contains development users for local testing; change these credentials before using the system outside a development environment.

## API routes

| Method | Route | Purpose |
| --- | --- | --- |
| `POST` | `/login` | Authenticate a user |
| `POST` | `/logout` | Log out |
| `GET/POST/PUT/DELETE` | `/categories` | Manage categories |
| `GET/POST/PUT/DELETE` | `/products` | Manage products |
| `GET/POST` | `/orders` | View and create orders |

Add `?id=<id>` to retrieve a single category, product, or order. Product search is available with `GET /products?search=<term>`.

## Development

Run the Dart test suite from `pos_frontend`:

```bash
dart test
```

## License

This project is intended for educational and local development use.