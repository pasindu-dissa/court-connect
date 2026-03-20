import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart'; // Your API constants file

class ImageUploadService {
  
  Future<String?> pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    
    // 1. Pick Image from Gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null; // User canceled

    // 2. Prepare the Multipart Request
    var request = http.MultipartRequest(
      'POST', 
      Uri.parse('${ApiConstants.baseUrl}/upload')
    );

    // 3. Attach the file (Notice the field name is 'image' to match Node.js)
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    // 4. Send the request
    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData['imageUrl']; // Returns the Cloudinary URL!
      } else {
        print("Upload failed");
        return null;
      }
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}