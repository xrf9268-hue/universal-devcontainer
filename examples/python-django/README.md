# Python Django Example

Full-featured web framework for building robust web applications with Python 3.12 and Claude Code.

## 🚀 Quick Start

```bash
cd examples/python-django
code .  # Reopen in container

# Create Django project (first time only)
django-admin startproject myproject .
python manage.py migrate

# Run development server
python manage.py runserver 0.0.0.0:8000
```

Visit http://localhost:8000

## 📦 Stack

- **Python 3.12** - Latest Python
- **Django 5.0** - High-level web framework
- **Django REST Framework** - Powerful API toolkit
- **SQLite** - Default database (easily switch to PostgreSQL)

## 🛠️ Common Commands

```bash
# Start project (first time)
django-admin startproject myproject .

# Create app
python manage.py startapp myapp

# Database migrations
python manage.py makemigrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Run server
python manage.py runserver 0.0.0.0:8000

# Django shell
python manage.py shell
```

## 🤖 Claude Code Examples

**Create a new Django app:**
```
Claude, create a new Django app called 'blog' with Post and Comment models
```

**Add REST API:**
```
Claude, create a REST API for the Blog app using Django REST Framework
```

**Add authentication:**
```
Claude, implement user authentication with JWT tokens
```

**Database optimization:**
```
Claude, add database indexes and optimize queries for the blog posts
```

## 🎯 Project Structure

```
python-django/
├── .devcontainer/
│   └── devcontainer.json
├── myproject/              # Created by django-admin
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── myapp/                  # Your apps
│   ├── models.py
│   ├── views.py
│   └── urls.py
├── manage.py
├── requirements.txt
└── README.md
```

## 🎯 Next Steps

1. Create your first app: `python manage.py startapp blog`
2. Define models in `models.py`
3. Create views and URLs
4. Add Django admin interface
5. Add Django REST Framework for APIs
6. Deploy with Gunicorn + Nginx

## 📚 Features

✅ **Batteries included** - ORM, auth, admin, templates
✅ **Scalable** - From MVPs to large applications
✅ **Secure** - Built-in protection against common vulnerabilities
✅ **Admin interface** - Auto-generated admin panel
✅ **ORM** - Powerful database abstraction

Happy coding! 🚀
