from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django import http
import os
from pathlib import Path

@csrf_exempt
def handle_post(request):
    if request.method == 'POST':
        """Get a downloadable attachment given path to a file"""
        local_volume_path = Path("/root/my_django_project/files")
        subdir = request.POST['subdir']
        filename = request.POST['filename']

        if filename is None or filename == '':
            return JsonResponse({'error': 'filename is a required field.'}, status=400)

        if subdir is None or subdir == '':
            return JsonResponse({'error': 'subdir is a required field.'}, status=400)

        # Remove fwd slash in the front
        subdir = subdir.lstrip('/')

        if not os.path.isdir(local_volume_path / subdir):
            return JsonResponse({'error': 'This subdirectory does not exist.'}, status=404)

        if not (local_volume_path / subdir / filename).exists():
            return JsonResponse({'error': 'File does not exist.'}, status=404)

        try:
            return http.FileResponse(
                open(local_volume_path / subdir / filename, 'rb'),
                filename=filename,
                as_attachment=True)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Invalid method'}, status=405)