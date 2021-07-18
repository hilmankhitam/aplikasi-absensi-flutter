import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController controller;

  Future<void> initializeCamera() async {
    var cameras = await availableCameras();
    controller = CameraController(cameras[1], ResolutionPreset.medium);
    await controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<File> takePicture() async {
    Directory root = await getTemporaryDirectory();
    String directoryPath = '${root.path}/Guided_Camera';
    await Directory(directoryPath).create(recursive: true);
    String filePath = '$directoryPath/${DateTime.now()}.jpg';

    try {
      await controller.takePicture(filePath);
    } catch (e) {
      return null;
    }

    return File(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
          future: initializeCamera(),
          builder: (_, snapshot) =>
              (snapshot.connectionState == ConnectionState.done)
                  ? Stack(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width /
                                  controller.value.aspectRatio,
                              child: CameraPreview(controller),
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              margin: EdgeInsets.only(top: 50),
                              child: RaisedButton(
                                onPressed: () async {
                                  if (!controller.value.isTakingPicture) {
                                    File result = await takePicture();
                                    Navigator.pop(context, result);
                                  }
                                },
                                shape: CircleBorder(),
                                color: Colors.blue,
                                child: Icon(Icons.camera, color: Colors.white,),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Center(
                      child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator()),
                    )),
    );
  }
}
