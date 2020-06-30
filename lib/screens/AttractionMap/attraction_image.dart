import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AttractionImage extends StatefulWidget {
  final String imageUrl;
  AttractionImage({@required this.imageUrl});
  @override
  _AttractionImageState createState() => _AttractionImageState();
}

class _AttractionImageState extends State<AttractionImage> {
  File image;

  @override
  initState() {
    super.initState();
    initImage();
  }

  Future<void> initImage() async {
    final path = join(
      (await getApplicationDocumentsDirectory()).path,
      widget.imageUrl,
    );
    final file = File(path);
    if (file.existsSync()) {
      setState(() {
        image = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return image?.existsSync() == true
        ? Image(
            image: Image.memory(
            image.readAsBytesSync(),
          ).image)
        : Icon(Icons.error);
  }
}
