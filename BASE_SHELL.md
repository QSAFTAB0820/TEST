# Task Manager - Base Shell Description

## Project Overview
A full-stack Task Manager application with JWT Authentication built with Django REST Framework and Flutter.

## Backend (Django)
- **Port**: 8000
- **API Base URL**: http://127.0.0.1:8000/

### Endpoints
- `POST /api/auth/register/` - User registration
- `POST /api/auth/login/` - User login (returns JWT tokens)
- `POST /api/auth/refresh/` - Token refresh
- `GET /api/auth/me/` - Get current user
- `GET/POST /api/tasks/tasks/` - List/Create tasks
- `PUT/DELETE /api/tasks/tasks/{id}/` - Update/Delete task

### Database
- SQLite3 (default Django DB)
- Tables: `accounts_user`, `accounts_passwordresettoken`, `task`

## Frontend (Flutter)
- **Platforms**: Android, Web
- **State Management**: Provider

### Features
- JWT Authentication with token storage (shared_preferences)
- Login/Register screens with validation
- Dashboard with Bottom Navigation (Home, Tasks, Profile)
- Task list with filters (status, priority)
- Task creation/editing with form validation

### Test Credentials
- Email: test@example.com
- Password: password123

## Running the Project

### Backend
```bash
cd django-project
python manage.py runserver 0.0.0.0:8000
```

### Frontend
```bash
cd flutter_app
flutter run
```