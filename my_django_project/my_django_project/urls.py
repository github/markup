from django.urls import path
from .views import handle_post

urlpatterns = [
    path('handle_post/', handle_post, name='handle_post'),
]