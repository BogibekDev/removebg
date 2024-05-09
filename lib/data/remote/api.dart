import 'dart:typed_data';

import 'package:http/http.dart' as http;

class ApiClient {
  static final baseUrl = Uri.parse("https://api.remove.bg/v1.0/removebg/");
  static const apiKey = "vBAJmkA9Zv3dLPdivoZAuVpA";

  static removebg(String imagePath) async {
    var request = http.MultipartRequest("POST", baseUrl);
    request.headers.addAll({"X-Api-Key": apiKey});
    request.files.add(await http.MultipartFile.fromPath("image_file", imagePath));
    final response = await request.send();

    if (response.statusCode == 200) {
      http.Response img = await http.Response.fromStream(response);
      print(img.bodyBytes.toString());
      return img.bodyBytes;
    } else {
      var some  = await http.Response.fromStream(response);
      print("${some.body}");
      return null;
    }
  }
}
