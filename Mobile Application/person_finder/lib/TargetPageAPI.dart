import 'dart:io';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart';

class TargetPageAPI extends StatefulWidget {
  @override
  _TargetPageAPIState createState() => _TargetPageAPIState();
}

class _TargetPageAPIState extends State<TargetPageAPI> {
  File? _selectedImage;
  bool _showImage = false;
  GlobalKey imageKey = GlobalKey();
  double scaleFactor = 1.0;
  _TargetPageAPIState() {}
  double x = -1, y = -1, x2 = -1, y2 = -1;
  int orgHeight = 640, orgWidth = 640;
  String? result;
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      uploadImage(pickedFile, context).then((value) => {
            setState(() {
              x = value['x'];
              y = value['y'];
              x2 = value['x2'];
              y2 = value['y2'];
              _selectedImage = File(pickedFile.path);
              if (x != -1 && x2 != -1 && y != -1 && y2 != -1) {
                _showImage = true;
                decodeImageFromList(_selectedImage!.readAsBytesSync())
                    .then((im) => {
                          setState(() {
                            orgHeight = im.height;
                            orgWidth = im.width;
                          })
                        });
              } else {
                x = 1;
                y = 1;
                x2 = 2;
                y2 = 2;
                _showImage = true;
              }
            })
          });
    }
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                _pickImage(context, ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                _pickImage(context, ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> uploadImage(
      XFile? file, BuildContext context) async {
    var uri = Uri.parse("https://f5f0-78-184-164-78.ngrok-free.app/search");
    // File file = File(image!.path);
    var stream = new http.ByteStream(file!.openRead().cast<List<int>>());
    var length = await file.length();
    var multipartFile = http.MultipartFile('image', stream, length,
        filename: basename(file.path));
    var request = new http.MultipartRequest("POST", uri);
    request.files.add(multipartFile);
    var response = await request.send();

    if (response.statusCode == 200) {
      Map<String, dynamic> xyxy =
          jsonDecode(await response.stream.bytesToString());
      return xyxy;
    } else {
      Map<String, dynamic> xyxy =
          jsonDecode(await response.stream.bytesToString());
      return xyxy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image to search in upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _showImage
                  ? _selectedImage == null
                      ? const Text('No image selected.')
                      : renderBoxesOnImage(_selectedImage!, x, y, x2, y2)
                  : _selectedImage == null
                      ? const Text('No image selected.')
                      : Image.file(_selectedImage!),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _showImagePickerOptions(context),
              child: Text('Search within an image'),
            ),
          ],
        ),
      ),
    );
  }

  // adapted from https://github.com/AneeqMalik/flutter_pytorch/blob/66b1bbffc15ff4ddca2577a0ec5d43ffc671ea66/lib/flutter_pytorch.dart#L324
  Widget renderBoxesOnImage(File _image, x, y, x2, y2,
      {Color boxColor = Colors.green}) {
    return LayoutBuilder(builder: (context, constraints) {
      double factorX = constraints.maxWidth;
      double factorY = constraints.maxHeight;

      double scaleX = factorX / orgWidth;
      double scaleY = factorY / orgHeight;

      return Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: factorX,
            height: factorY,
            child: Container(
                child: Image.file(
              _image,
              width: factorX,
              height: factorY,
              fit: BoxFit.fill,
            )),
          ),
          Positioned(
            left: x * scaleX,
            top: y * scaleY,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: (x2 - x) * scaleX,
                  height: (y2 - y) * scaleY,
                  decoration: BoxDecoration(
                      border: Border.all(color: boxColor, width: 3),
                      borderRadius: BorderRadius.all(Radius.circular(2))),
                  child: Container(),
                ),
              ],
            ),
          )
        ],
      );
    });
  }
}
