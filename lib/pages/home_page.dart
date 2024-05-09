import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remove_background/data/remote/api.dart';
import 'package:remove_background/widgets/dashed_border.dart';
import 'package:screenshot/screenshot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loaded = false;
  bool removedbg = false;
  bool isLoading = false;
  bool isDownloading = false;

  Uint8List? image;
  String imagePath = '';

  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0.0,
        leading: const Icon(Icons.sort_rounded),
        centerTitle: true,
        title: const Text(
          "Fonni olib tashlash",
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          isDownloading
              ? const CircularProgressIndicator()
              : IconButton(
                  onPressed: downloadImage,
                  icon: const Icon(Icons.download),
                )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(14),
        child: DashedBorder(
          padding: const EdgeInsets.all(6),
          color: Colors.grey,
          radius: 12,
          child: removedbg
              ? Screenshot(
                  controller: screenshotController,
                  child: Image.memory(image!),
                )
              : loaded
                  ? GestureDetector(
                      onTap: pickImage,
                      child: Image.file(File(imagePath)),
                    )
                  : DashedBorder(
                      padding: const EdgeInsets.all(60),
                      color: Colors.grey,
                      radius: 12,
                      child: SizedBox(
                        width: 200,
                        height: 56,
                        child: MaterialButton(
                          color: Colors.amber,
                          onPressed: pickImage,
                          child: const Text("Rasm tanlang"),
                        ),
                      ),
                    ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 56,
        child: MaterialButton(
          color: Colors.amber,
          onPressed: loaded
              ? () async {
                  setState(() {
                    isLoading = true;
                  });
                  image = await ApiClient.removebg(imagePath);
                  if (image != null) {
                    removedbg = true;
                    isLoading = false;
                    setState(() {});
                  } else {
                    isLoading = false;
                    setState(() {});
                  }
                }
              : null,
          child: isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                )
              : const Text("Olib tashlash",
                  style: TextStyle(color: Colors.black45, fontSize: 16)),
        ),
      ),
    );
  }

  void pickImage() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (img != null) {
      imagePath = img.path;
      loaded = true;
      setState(() {});
    } else {}
  }

  void downloadImage() async {
    isDownloading = true;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final version = int.parse(androidInfo.version.release);

    var status = version >= 11
        ? await Permission.manageExternalStorage.request().isGranted
        : await Permission.storage.request().isGranted;

    var fileName = "${DateTime.now().microsecondsSinceEpoch}.png";
    if (status) {
      final directory = Directory("storage/emulated/0/removebg");

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      await screenshotController.captureAndSave(
        directory.path,
        delay: const Duration(milliseconds: 500),
        fileName: fileName,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Muvaffaqqiyatli saqlandi!")),
      );
    }

    isDownloading = false;
  }
}
