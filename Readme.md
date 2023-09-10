# Image Annotation Tool - User Guide

This Image Annotation Tool allows you to annotate images using various tools. Follow these step-by-step instructions to use the GUI effectively.

## Step 1: Running the Application

1. Ensure you have Python 3.x installed on your computer.

2. Open a terminal or command prompt and navigate to the directory containing the code.

3. Run the application using the following command:

   ```
   python image_annotation_tool.py
   ```

4. The Image Annotation Tool window should appear.

## Step 2: Loading an Image

1. Click the "Load Image" button to open a file dialog.

2. Browse your computer and select an image file. Supported formats include .png, .jpg, .jpeg, .gif, .bmp, .ppm, and .pgm.

3. Click "Open" in the file dialog to load the selected image into the tool.

## Step 3: Selecting an Annotation Tool

The Image Annotation Tool provides four annotation tools. Select the one you want to use:

- **Mark Tool**: Use this tool to mark rectangles on the image.

- **Draw Tool**: Use this tool to draw freehand on the image.

- **Outline Tool**: Use this tool to create an outline around objects in the image.

- **Brush Tool**: Use this tool to brush over the image.

## Step 4: Adjusting Brush Width (Optional)

If you're using the "Brush Tool," you can adjust the brush width using the slider provided. Move the slider left or right to change the width.

## Step 5: Annotating the Image

Depending on the selected tool, use the following actions to annotate the image:

- **Marking Rectangles**: Click and drag to mark rectangles on the image.

- **Drawing**: Click and drag to draw freehand on the image.

- **Outlining**: Click and drag to create outlines around objects.

- **Brushing**: Click and drag to brush over the image.

## Step 6: Saving Annotations

To save your annotations, follow these steps:

- **Saving a Selected Region**:
  - Use the "Mark Tool" to draw a rectangle around the region you want to save.
  - Right-click inside the rectangle.
  - A file dialog will open for you to specify the location and format (default is .png) to save the selected region.

- **Saving the Annotated Image**:
  - Click the "Save Annotated Image" button.
  - A file dialog will open for you to specify the location and format (default is .png) to save the entire annotated image.

