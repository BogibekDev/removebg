import 'dart:io';

import 'package:before_after/before_after.dart';
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
  var value = 0.5;

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
          "Remove Background",
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
      body: Center(
        child: removedbg
            ? BeforeAfter(
                key: UniqueKey(),
                value: value,
                before: Image.file(File(imagePath)),
                after: Screenshot(
                  key: UniqueKey(),
                  controller: screenshotController,
                  child: Image.memory(key: UniqueKey(), image!),
                ),
                onValueChanged: (value) {
                  setState(() {
                    this.value = value;
                  });
                },
              )
            : loaded
                ? GestureDetector(
                    onTap: pickImage,
                    child: Image.file(key: UniqueKey(), File(imagePath)),
                  )
                : DashedBorder(
                    padding: const EdgeInsets.all(60),
                    color: Colors.grey,
                    radius: 12,
                    child: SizedBox(
                      width: 200,
                      height: 56,
                      child: MaterialButton(
                        color: Colors.greenAccent,
                        onPressed: pickImage,
                        child: const Text("Remove Background"),
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: SizedBox(
        height: 56,
        child: MaterialButton(
          color: Colors.greenAccent,
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
              : const Text("Remove Background",
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

    var perm = await Permission.storage.request();
    var fileName = "${DateTime.now().microsecondsSinceEpoch}.png";
    if (perm.isGranted) {
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
        const SnackBar(
          content: Text("Successfully downloaded"),
        ),
      );
    }
    isDownloading = false;
  }
}
