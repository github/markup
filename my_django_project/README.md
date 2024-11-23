# My Django Project

This is a simple Django project designed to test the `handle_post` view function, which handles file downloads based on specified subdirectory and filename.

## Project Structure

```
my_django_project
├── my_django_project
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   ├── views.py
│   └── wsgi.py
├── manage.py
└── README.md
```

## Requirements

- Python 3.x
- Django

## Setup Instructions

1. **Clone the repository:**
   ```
   git clone <repository-url>
   cd my_django_project
   ```

2. **Create a virtual environment:**
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows use `venv\Scripts\activate`
   ```

3. **Install dependencies:**
   ```
   pip install django
   ```

4. **Run the development server:**
   ```
   python manage.py runserver
   ```

5. **Access the application:**
   Open your web browser and navigate to `http://127.0.0.1:8000/`.

## Usage

To test the `handle_post` view, send a POST request to the appropriate URL with the required parameters (`subdir` and `filename`). The view will attempt to return the specified file as a downloadable attachment.

## License

This project is licensed under the MIT License.