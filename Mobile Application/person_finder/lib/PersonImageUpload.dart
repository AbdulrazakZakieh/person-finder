import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart';
import 'package:person_finder/TargetPageAPI.dart';

class PersonImageUpload extends StatefulWidget {
  @override
  _PersonImageUploadState createState() => _PersonImageUploadState();
}

class _PersonImageUploadState extends State<PersonImageUpload> {
  File? _selectedImage;
  bool _showNext = false;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      uploadImage(pickedFile, context).then((value) => {
            setState(() {
              _selectedImage = File(pickedFile.path);
              _showNext = value;
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

  Future<bool> uploadImage(XFile? file, BuildContext context) async {
    var uri = Uri.parse(
        "https://f5f0-78-184-164-78.ngrok-free.app/upload-person-image");
    // File file = File(image!.path);
    // open a bytestream
    var stream = new http.ByteStream(file!.openRead().cast<List<int>>());
    // get file length
    var length = await file.length();
    var multipartFile = http.MultipartFile('person_image', stream, length,
        filename: basename(file.path));
    // create multipart request
    var request = new http.MultipartRequest("POST", uri);
    request.files.add(multipartFile);
    var response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      // show error message
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('Failed to upload the image',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
                content: Text('Please try again later'),
              ),
          barrierDismissible: true);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Person image upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedImage == null
                ? Text('No Image Selected')
                : Image.file(
                    _selectedImage!,
                    height: 200.0,
                  ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _showImagePickerOptions(context),
              child: Text('Upload an image of the person you are looking for'),
            ),
            _showNext
                ? ElevatedButton.icon(
                    label: Text("Next"),
                    icon: const Icon(Icons.arrow_right),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => TargetPageAPI()),
                      );
                    },
                  )
                : Center()
          ],
        ),
      ),
    );
  }
}
