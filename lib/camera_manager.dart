import 'package:camera/camera.dart';

class CameraManager {
  CameraController _cameraController;
  Future<void> _initializeControllerFuture;
  final CameraDescription camera;

  CameraManager({this.camera});

  Future<void> initialize() async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _cameraController.initialize();
    await _initializeControllerFuture;
  }

  CameraController get cameraController => _cameraController;

  void dispose() {
    _cameraController.dispose();
  }
}
