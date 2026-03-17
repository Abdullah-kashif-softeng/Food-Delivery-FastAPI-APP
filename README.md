# 🍔 Food Delivery App

A full-stack food delivery application built with Python (FastAPI) + Next.js + PostgreSQL. 
Built with a focus on Object Oriented Programming, clean architecture, and production-ready practices.

## 📋 Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Features](#features)
- [OOP Design](#oop-design)
- [API Endpoints](#api-endpoints)
- [Project Structure](#project-structure)
- [Git Flow](#git-flow)
- [Getting Started](#getting-started)
- [Environment Variables](#environment-variables)
- [Docker Setup](#docker-setup)
- [CI/CD](#cicd)

---

## 🧾 Overview

A production-grade food delivery platform where:
- **Customers** can browse restaurants, place orders and track deliveries
- **Riders** can accept deliveries and update order status
- **Restaurants** can manage their menu and incoming orders
- **Admins** can manage the entire platform

Built from scratch with a focus on learning and applying core + intermediate
Python concepts including OOP, async programming, type hints, decorators and more.

---

## 🛠 Tech Stack

### Backend
| Technology | Purpose |
|---|---|
| Python 3.12 | Core language |
| FastAPI | REST API framework |
| PostgreSQL | Primary database |
| asyncpg | Async PostgreSQL driver |
| SQLAlchemy | ORM (Phase 3+) |
| Pydantic v2 | Data validation and schemas |
| JWT (PyJWT) | Authentication tokens |
| bcrypt | Password hashing |
| Loguru | Logging |
| python-dotenv | Environment variables |
| pytest | Testing |

### Frontend
| Technology | Purpose |
|---|---|
| Next.js 14 | React framework |
| TypeScript | Type safety |
| Tailwind CSS | Styling |

### DevOps
| Technology | Purpose |
|---|---|
| Docker | Containerization |
| Docker Compose | Multi-container setup |
| GitHub Actions | CI/CD pipeline |

---

## 🏗 Architecture

This project is built in phases — starting simple and refactoring to production grade:
```
Phase 1 — Pure Python OOP
Pure Python classes, services, async database connection.
No framework yet. Focus on mastering OOP and Python concepts.

Phase 2 — FastAPI Layer
Add REST API endpoints on top of existing services.
JWT authentication, Pydantic schemas, proper HTTP responses.

Phase 3 — Refactor to Proper Structure
Introduce Repository pattern, ABCs, dependency injection.
Split services into schemas + repositories + services.

Phase 4 — Production Ready
Full Docker setup, CI/CD pipeline, tests, logging.
```

### Current Phase Structure
```
backend/
├── models/          ← OOP classes (what things ARE)
├── services/        ← Business logic (what things DO)
├── database/        ← PostgreSQL connection
└── main.py          ← Entry point
```

---

## ✨ Features

### Authentication
- [x] User registration with password hashing (bcrypt)
- [x] Login with JWT token generation
- [x] JWT token validation and refresh
- [x] Role-based access (Customer, Rider, Admin)

### Users
- [x] Customer registration and profile management
- [x] Rider registration with vehicle details
- [x] Profile updates
- [x] Address management for customers

### Restaurants
- [x] Restaurant registration and profile
- [x] Menu management (add, update, remove items)
- [x] Restaurant search and filtering
- [x] Opening hours management

### Menu
- [x] Add and update menu items
- [x] Category management
- [x] Item availability toggling
- [x] Price management

### Orders
- [x] Place orders with multiple items
- [x] Real-time order status tracking
- [x] Order history for customers
- [x] Order management for restaurants
- [x] Rider assignment

### Payments
- [x] Payment processing
- [x] Multiple payment methods (cash, card)
- [x] Payment status tracking
- [x] Refund handling

### Notifications
- [x] Order confirmation notifications
- [x] Status update notifications
- [x] Rider assignment notifications

---

## 🧠 OOP Design

This project heavily uses Object Oriented Programming principles:

### Inheritance
```python
User (base class)
├── Customer    ← adds delivery address, order history
└── Rider       ← adds vehicle info, availability status
```

### Key Python Concepts Used
| Concept | Where Used |
|---|---|
| Classes & `__init__` | Every model |
| Inheritance | Customer, Rider extend User |
| `@property` | Computed fields, validation |
| `@staticmethod` | Utility methods |
| `@classmethod` | Factory methods |
| Magic methods | `__str__`, `__repr__`, `__eq__` |
| Abstract Base Classes | Base service, base repository |
| Enums | OrderStatus, PaymentStatus, UserRole |
| Type hints | Every function and parameter |
| `async/await` | All DB and service calls |
| Decorators | Auth, logging, validation |
| List comprehensions | Data filtering and mapping |
| Dict operations | Data transformation |
| Custom exceptions | Error hierarchy |
| Context managers | DB sessions |
| Dataclasses | Value objects |

---

## 🔐 Authentication Flow
```
1. User registers    → password hashed with bcrypt → saved to DB
2. User logs in      → password verified → JWT token generated
3. Request comes in  → JWT token validated → user identity confirmed
4. Role checked      → Customer / Rider / Admin → access granted or denied
```

### JWT Token Structure
```json
{
  "sub": "user_id",
  "role": "customer",
  "exp": 1234567890,
  "iat": 1234567890
}
```

---

## 📡 API Endpoints

### Auth
```
POST   /api/v1/auth/register     ← register new user
POST   /api/v1/auth/login        ← login, returns JWT
POST   /api/v1/auth/refresh      ← refresh JWT token
POST   /api/v1/auth/logout       ← logout
```

### Users
```
GET    /api/v1/users/me          ← get current user profile
PUT    /api/v1/users/me          ← update profile
DELETE /api/v1/users/me          ← delete account
```

### Restaurants
```
GET    /api/v1/restaurants       ← list all restaurants
GET    /api/v1/restaurants/{id}  ← get single restaurant
POST   /api/v1/restaurants       ← create restaurant
PUT    /api/v1/restaurants/{id}  ← update restaurant
DELETE /api/v1/restaurants/{id}  ← delete restaurant
```

### Menu
```
GET    /api/v1/restaurants/{id}/menu        ← get menu
POST   /api/v1/restaurants/{id}/menu        ← add item
PUT    /api/v1/restaurants/{id}/menu/{id}   ← update item
DELETE /api/v1/restaurants/{id}/menu/{id}   ← remove item
```

### Orders
```
GET    /api/v1/orders            ← get my orders
POST   /api/v1/orders            ← place new order
GET    /api/v1/orders/{id}       ← get order details
PUT    /api/v1/orders/{id}       ← update order status
DELETE /api/v1/orders/{id}       ← cancel order
```

### Payments
```
POST   /api/v1/payments          ← process payment
GET    /api/v1/payments/{id}     ← get payment status
POST   /api/v1/payments/refund   ← request refund
```

---

## 📁 Project Structure
```
## Project Structure

food_delivery/
│
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── cd.yml
│
├── backend/
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── restaurant.py
│   │   ├── menu_item.py
│   │   ├── order.py
│   │   └── payment.py
│   │
│   ├── services/
│   │   ├── __init__.py
│   │   ├── user_service.py
│   │   ├── restaurant_service.py
│   │   ├── menu_service.py
│   │   ├── order_service.py
│   │   ├── payment_service.py
│   │   └── notification_service.py
│   │
│   ├── database/
│   │   ├── __init__.py
│   │   └── db.py
│   │
│   ├── main.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── .env.example
│
├── frontend/
│   └── (Next.js — Phase 2)
│
├── docker-compose.yml
├── .gitignore
└── README.md

---

## 🌿 Git Flow
```
main                    ← production only, protected
└── develop             ← integration branch
    ├── feature/setup
    ├── feature/database
    ├── feature/users
    ├── feature/restaurants
    ├── feature/menu
    ├── feature/orders
    ├── feature/payment
    └── feature/notifications
```

### Commit Message Format
```
feat:     new feature
fix:      bug fix
refactor: code restructure
docs:     documentation
chore:    config, dependencies
test:     adding tests
```

---

## 🚀 Getting Started

### Prerequisites
- Python 3.12+
- PostgreSQL 16+
- Node.js 18+ (for frontend)
- Docker (optional)

### Local Setup
```bash
# Clone the repo
git clone https://github.com/yourusername/food_delivery.git
cd food_delivery/backend

# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Activate (Mac/Linux)
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Copy env file and fill in your values
cp .env.example .env

# Run the app
python main.py
```

---

## 🔑 Environment Variables
```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=food_delivery
DB_USER=postgres
DB_PASSWORD=

# App
APP_NAME=FoodDelivery
APP_ENV=development
APP_PORT=8000
DEBUG=True

# Security
SECRET_KEY=
JWT_ALGORITHM=HS256
JWT_EXPIRE_MINUTES=30
```

---

## 🐳 Docker Setup
```bash
# Build and run everything
docker-compose up --build

# Run in background
docker-compose up -d

# Stop everything
docker-compose down
```

---

## ⚙️ CI/CD

GitHub Actions pipeline runs on every push:
```
Push to feature/* → run tests → lint check
Push to develop   → run tests → build docker image
Push to main      → run tests → build → deploy
```

---

## 👨‍💻 Author

