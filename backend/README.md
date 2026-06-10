# Broast Meshwar — Laravel API

JSON REST API under `/api/v1`. Responses use a fixed envelope:

```json
{
  "status": true,
  "message": "",
  "data": {}
}
```

## Requirements

- PHP 8.2+
- Composer
- SQLite (default) or MySQL

## Setup

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
touch database/database.sqlite   # if using sqlite and file is missing
php artisan migrate --seed
php artisan serve
```

### Seeded accounts

| Role     | Email                       | Password  |
|----------|-----------------------------|-----------|
| Admin    | admin@broastmeshwar.test    | password  |
| Customer | customer@broastmeshwar.test | password  |

## Authentication (Sanctum)

1. `POST /api/v1/auth/login` or `POST /api/v1/auth/register` with JSON body.
2. Use the returned `token` as `Authorization: Bearer <token>` on protected routes.

## CORS

Set `CORS_ALLOWED_ORIGINS` in `.env` to a comma-separated list of frontend origins (see `config/cors.php`).

## Windows / OneDrive and `bootstrap/cache`

If `php artisan` fails with *bootstrap/cache must be present and writable*, OneDrive can make `is_writable()` fail. Create a junction to a local folder (run **cmd.exe as Administrator** if required):

```bat
rmdir /s /q bootstrap\cache
mkdir C:\Temp\broast_meshwar_bootstrap_cache
mklink /J bootstrap\cache C:\Temp\broast_meshwar_bootstrap_cache
```

## Modules

Code lives under `app/Modules/{Auth,Users,Restaurants,Products,Cart,Orders,Payments}/` with thin controllers, form requests, resources, services, and repositories.

## Main endpoints (summary)

| Area        | Methods | Path |
|-------------|---------|------|
| Auth        | POST    | `/api/v1/auth/register`, `/auth/login` |
| Auth        | POST/GET| `/api/v1/auth/logout`, `/auth/user` (auth) |
| Users       | CRUD    | `/api/v1/users` (admin list; auth) |
| Restaurants | GET     | `/api/v1/restaurants`, `/restaurants/{restaurant}` |
| Restaurants | CUD     | `/api/v1/restaurants` (admin + auth) |
| Products    | GET     | `/api/v1/products`, `/products/{product}` |
| Products    | CUD     | `/api/v1/products` (admin + auth) |
| Cart        | *       | `/api/v1/cart`, `/cart/items`, … (auth) |
| Orders      | GET/POST| `/api/v1/orders`, `/orders/{order}` (auth) |
| Orders      | PATCH   | `/api/v1/orders/{order}/status` (admin) |
| Payments    | POST    | `/api/v1/orders/{order}/payments/intent` (auth) |
| Payments    | GET     | `/api/v1/orders/{order}/payments` (auth) |
| Webhook     | POST    | `/api/v1/payments/webhook` (stub) |

List endpoints support `page`, `per_page`, `sort`, `direction`, and `filter[...]` query parameters where implemented.
