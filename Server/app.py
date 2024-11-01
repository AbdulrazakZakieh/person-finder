from ultralytics import YOLO
from PIL import Image
from io import BytesIO
import os
from facenet_pytorch import InceptionResnetV1
import torch
import torchvision.transforms as transforms 
from PIL import Image
from flask import Flask, g, request, jsonify, make_response
import json

print("Loading FaceNet...")
resnet = InceptionResnetV1(pretrained='vggface2').eval() 
print("FaceNet loaded")
print("Loading YOLOv8 Face...")
yoloModel = YOLO('yolov8n-face.pt')  
print("YOLOv8 Face loaded")

preprocess = transforms.Compose([
    transforms.Resize((160, 160)),
    transforms.ToTensor(),
])

def getEmbedding(imageFile):
    input_tensor = preprocess(imageFile)
    input_batch = input_tensor.unsqueeze(0)
    return resnet(input_batch)

app = Flask(__name__)

person_image_embedding = None

@app.route('/upload-person-image', methods=['POST'])
def uploadPersonImage():
    global person_image_embedding
    if 'person_image' not in request.files:
        return make_response(jsonify({'success': False, 'message': 'No image uploaded'}), 400)
    person_image = request.files['person_image']
    image_path = "temp_image.jpg"
    person_image.save(image_path)
    person_image = Image.open(image_path)
    try:
        person_image_embedding = getEmbedding(person_image)
    except Exception as e:
        print(e)
        return make_response(jsonify({'success': False, 'message': 'error in server'}), 400)
    return make_response(jsonify({'success': True, 'message': "Process successfully"}), 200)

@app.route('/search', methods=['POST'])
def search():
    global person_image_embedding
    if 'image' not in request.files:
        return make_response(jsonify({'success': False, 'message': 'No image uploaded'}), 400)

    if person_image_embedding is None:
        return make_response(jsonify({'success': False, 'message': 'Please upload the person\'s image first using /upload-person-image end point'}), 400)
     
    image = request.files['image']
    image_path = "temp_image.jpg"
    image.save(image_path)
    print('Detecting faces')
    result = yoloModel(image_path)   
    print("Faces detected")
    img = Image.open(image_path)
    i = 0
    minDisance = 2
    detectedBox = None
    for box in result[0]:
        x, y, x2, y2 = box.boxes.xyxy[0].tolist()
        cropped_img = img.crop((x, y, x2, y2))
        embeddings = getEmbedding(cropped_img)  
        distance = (person_image_embedding - embeddings).norm()
        print("Distance " + str(i) + ":",distance)
        if distance < 1 and distance < minDisance:
            minDisance = distance
            detectedBox = box.boxes.xyxy[0]
        i = i + 1

    if minDisance < 1 and detectedBox != None:
        x, y, x2, y2 = detectedBox.tolist()
        return make_response(jsonify({'success': True,   'x': x, 'y': y, 'x2': x2, 'y2': y2}), 200)
    else:
        x = -1.0
        y = x
        x2 = x
        y2 = x
        return make_response(jsonify({'success': True,  'x': x, 'y': y, 'x2': x2, 'y2': y2,'message': "Person not found"}), 400)

if __name__ == '__main__':
    app.run(debug=True, port = 9001)

    
