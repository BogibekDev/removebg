import 'package:http/http.dart' as http;

class ApiClient {
  static final baseUrl = Uri.parse("https://api.remove.bg/v1.0/removebg/");
  static int count = -1;
  static String apiKey = "JP3ND9oYLTNR75UfCvr5LPNK";

  // static const apiKey = "4aF1bvwUic4GUTxqQaEPbFX2";
  // static const apiKey = "JP3ND9oYLTNR75UfCvr5LPNK";
  // static const apiKey = "tAv5jeTt9vwpcUCsVw8BK33h";
  // static const apiKey = "w854BzGZsFqdmgaVWmeBv3Cb";
  // static const apiKey = "J5VMxXvtE6w12GNqyRKcTgpC";
  // static const apiKey = "STVmhhpeGaVuNm7xgy6r4XxL";
  // static const apiKey = "xSTFq2eRw8wJsuXpVpD2QRk6";

  static List<String> apiKeyList = [
    "4aF1bvwUic4GUTxqQaEPbFX2",
    "JP3ND9oYLTNR75UfCvr5LPNK",
    "tAv5jeTt9vwpcUCsVw8BK33h",
    "w854BzGZsFqdmgaVWmeBv3Cb",
    "J5VMxXvtE6w12GNqyRKcTgpC",
    "STVmhhpeGaVuNm7xgy6r4XxL",
    "xSTFq2eRw8wJsuXpVpD2QRk6",
  ];

  static removebg(String imagePath) async {
    var request = http.MultipartRequest("POST", baseUrl);
    request.headers.addAll({"X-Api-Key": apiKey});
    request.files
        .add(await http.MultipartFile.fromPath("image_file", imagePath));
    final response = await request.send();

    if (response.statusCode == 200) {
      http.Response img = await http.Response.fromStream(response);
      return img.bodyBytes;
    } else {
      if (response.statusCode == 402) {
        count++;
        changeApikey();
        removebg(imagePath);
      }
      return null;
    }
  }

  static void changeApikey() {
    apiKey = apiKeyList[count];
  }
}
