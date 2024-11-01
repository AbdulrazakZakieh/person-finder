![image](https://github.com/user-attachments/assets/958cf520-efb9-4481-be39-439d40deb2e7)

# Person Finder
This project utilizes computer vision and deep learning models to facilitate person identification using a mobile
application. The usage scenarios encompass a parent seeking their child amidst a large gathering or an individual
trying to locate a friend within a densely populated place. This task requires the combination of two tasks, face
detection, and face verification, which we describe in the next sections. 

## Face Detection
Face detection is the process of detecting faces within an image. YOLO (You Only Look Once) model is an object
detection deep learning model, where it detects objects, not faces. One approach to detect a face is using YOLO and
detecting persons only, then cropping the face. This approach is time-consuming and not straightforward. Another
and better approach is training the YOLO model to detect faces only instead of objects, which was done in YOLO
Face [3]. YOLO Face is a YOLO model (tweaked slightly) trained on a face detection dataset called WIDER
FACE [6].

## Face Verification
The process of verifying whether two images belong to the same person or not is called verification [4]. FaceNet
is a deep convolutional neural network that maps an image to 128 bytes that represents the image in the Euclidean
space [5]. As a result, measuring the Euclidean distance between the embeddings of two images yields an effective
way to do the face verification task.

## Project Structure
This project is based on making the deep neural network models run on the cloud (on a server), and the mobile
application (as a client) will send requests to the server and receive a result. Figure 1 shows the architecture of
the developed system, where the application sends the image of the person we are looking for, and then sends an
image to search within it. The server will be returning the bounding box of the person, if found. The server stores
the FaceNet embedding of the image of the person we are looking for, then upon receiving an image to search for
that person within, it detects all the faces in that image using YOLOv8 Face and calculates its embedding using 
FaceNet. After calculating the embeddings for each of the detected faces, the distances between each detected face
and the person we are looking for are calculated as the norm of the difference of their corresponding embeddings.
The returned bounding box is the one corresponding to the shortest distance to the person we are looking for while
achieving a minimum threshold. This process is described in Figure 2.

![Architecture](https://github.com/user-attachments/assets/332ab6ea-17db-4560-a36e-942219943620)

Figure 1. Architecture of Person Finder.

![Person Finder Server](https://github.com/user-attachments/assets/e93552e3-6b27-4b8f-8c3a-433e77b64701)

Figure 2. The process of searching for the required face on the server.

The mobile application, which was developed using Flutter, prompts the user first to upload an image of the
person they are looking for where it will be sent to the server using the "/upload-person-image" endpoint. Afterward,
the user can upload a photo to search for the person within it, which will be sent to the server using "/search" endpoint
and the returned result will contain the bounding box in JavaScript Object Notation (JSON), if founded. Upon
receiving the bounding box, the application will transform it by scaling it to fit the displayed image. The reason
for scaling the bounding box is that YOLO will return the bounding box related to the original image size, and
the image we display is relative to the phone or tablet screen.

The server side was coded using Python, where Flask was used to create the application
programming interfaces (APIs) and Pytorch was used to run the deep learning models. The server has two endpoints
and runs on a port we define . To test on you local machine, you can use ngrok [2] to let the mobile application access the API.
The mobile application was developed using Flutter 3.13.0. The part of the code that draws the bounding box after scaling it
properly was adopted from renderBoxesOnImage method in [1] and changed to fit our application.

## References
[1] 2024. flutter_pytorch/lib/flutter_pytorch.dart at 66b1bbffc15ff4ddca2577a0ec5d43ffc671ea66 · AneeqMalik/flutter_pytorch. https:
//github.com/AneeqMalik/flutter_pytorch/blob/66b1bbffc15ff4ddca2577a0ec5d43ffc671ea66/lib/flutter_pytorch.dart#L324.
[2] 2024. ngrok | Unified Application Delivery Platform for Developers. https://ngrok.com/.
[3] Weijun Chen, Hongbo Huang, Shuai Peng, Changsheng Zhou, and Cuiping Zhang. 2021. YOLO-face: a real-time face detector. The
Visual Computer 37 (2021), 805–813.
[4] Marios Savvides, BVK Vijaya Kumar, and Pradeep Khosla. 2002. Face verification using correlation filters. 3rd IEEE Automatic
Identification Advanced Technologies (2002), 56–61.
[5] Florian Schroff, Dmitry Kalenichenko, and James Philbin. 2015. Facenet: A unified embedding for face recognition and clustering. In
Proceedings of the IEEE conference on computer vision and pattern recognition. 815–823.
[6] Shuo Yang, Ping Luo, Chen-Change Loy, and Xiaoou Tang. 2016. Wider face: A face detection benchmark. In Proceedings of the IEEE
conference on computer vision and pattern recognition. 5525–5533.
