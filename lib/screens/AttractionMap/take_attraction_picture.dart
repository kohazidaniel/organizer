import 'dart:io';

import 'package:camera/camera.dart';
import 'package:feledhaza/components/organizer_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:feledhaza/camera_manager.dart';
import 'package:provider/provider.dart';

class TakeAttractionPictureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CameraDescription>(
      builder: (context, camera, child) =>
          TakeAttractionPicture(camera: camera),
    );
  }
}

class TakeAttractionPicture extends StatefulWidget {
  final CameraDescription camera;

  TakeAttractionPicture({
    Key key,
    this.camera,
  }) : super(key: key);

  @override
  _TakeAttractionPictureState createState() => _TakeAttractionPictureState();
}

class _TakeAttractionPictureState extends State<TakeAttractionPicture> {
  Future<void> _initializeControllerFuture;
  CameraManager cameraManager;

  void initState() {
    super.initState();

    cameraManager = CameraManager(camera: widget.camera);

    _initializeControllerFuture = cameraManager.initialize();
  }

  @override
  void dispose() {
    cameraManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "takeAPicture")),
      ),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(cameraManager.cameraController);
          } else {
            return Center(child: Center(child: OrganizerProgressIndicator()));
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          try {
            final path = join(
              (await getApplicationDocumentsDirectory()).path,
              'tempAttractionPicture.png',
            );
            final file = File(path);
            if (file.existsSync()) {
              file.deleteSync();
            }

            await cameraManager.cameraController.takePicture(path);

            Navigator.pop(context, file);
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}
