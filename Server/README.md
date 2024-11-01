# Face Recognition with FaceNet and YOLOv8 - Server Side

This Flask application integrates FaceNet and YOLOv8 for finding a person within an image of crowded place. It allows you to upload a person's image and then search for that person in another image. It can be developed further to be used for surveillance purposes.

## Installation
1. Install dependencies using pip:
""" pip install -r requirements.txt """

2. Run the Flask application:
""" python finde_person.py """

The application will be accessible at http://localhost:9001.

You can use ngrok to get an accessible address through the internet

## Usage
Upload a person's image using the /upload-person-image endpoint.
Search for the person in another image using the /search endpoint.

Make sure to have YOLOv8 weights (yolov8n-face.pt) in the project directory.

## Endpoints
- Upload Person Image:

    Endpoint: /upload-person-image
    Method: POST
- Search for Person:
    Endpoint: /search
    Method: POST

## Dependencies
Ultralytics YOLO
FaceNet PyTorch
Flask
Pillow
