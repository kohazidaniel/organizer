import 'dart:io';

import 'package:feledhaza/models/AttractionMap/attraction.dart';
import 'package:feledhaza/models/AttractionMap/attraction_repository.dart';
import 'package:feledhaza/screens/AttractionMap/take_attraction_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AttractionFormDialog extends StatefulWidget {
  final LatLng _selectedPoint;
  AttractionFormDialog(this._selectedPoint);
  @override
  _AttractionFormDialogState createState() => _AttractionFormDialogState();
}

class _AttractionFormDialogState extends State<AttractionFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  AnimationController _controller;
  Animation<double> _animation;

  File image;

  @override
  initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this, value: 0.1);
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.elasticInOut);
    _controller.forward();

    initImage();
  }

  Future<void> initImage() async {
    final path = join(
      (await getApplicationDocumentsDirectory()).path,
      'tempAttractionPicture.png',
    );
    final file = File(path);
    if (file.existsSync()) {
      setState(() {
        image = file;
      });
    }
  }

  Future<void> renameImage(String newName) async {
    final path = join(
      (await getApplicationDocumentsDirectory()).path,
      'tempAttractionPicture.png',
    );
    final newPath = join(
      (await getApplicationDocumentsDirectory()).path,
      newName,
    );
    final file = File(path);
    if (file.existsSync()) {
      file.rename(newPath);
    }
  }

  void setImage(File newImage) {
    setState(() {
      image = newImage;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
        scale: _animation,
        alignment: Alignment.center,
        child: SimpleDialog(
          contentPadding: EdgeInsets.all(10),
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: FlutterI18n.translate(
                        context, 'addAttractionForm.name'),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return FlutterI18n.translate(
                          context, 'addAttractionForm.missingField');
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: FlutterI18n.translate(
                        context, 'addAttractionForm.address'),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return FlutterI18n.translate(
                          context, 'addAttractionForm.missingField');
                    }
                    return null;
                  },
                ),
                Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                            color: Colors.grey[100],
                            height: 125,
                            alignment: Alignment.center,
                            child: image?.existsSync() == true
                                ? Image(
                                    image: Image.memory(
                                    image.readAsBytesSync(),
                                    fit: BoxFit.cover,
                                  ).image)
                                : IconButton(
                                    onPressed: () async {
                                      File newImage = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TakeAttractionPictureScreen(),
                                        ),
                                      );
                                      setImage(newImage);
                                    },
                                    icon: Icon(Icons.add_a_photo),
                                    color: Colors.grey[700],
                                  )),
                      ],
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      textColor: Theme.of(context).primaryColor,
                      child: Text(FlutterI18n.translate(context, 'cancel')),
                    ),
                    FlatButton(
                      onPressed: () {
                        if (_formKey.currentState.validate() &&
                            image?.existsSync() == true) {
                          String uuid = Uuid().v1();

                          Attraction newAttraction = Attraction(
                            cameraPosition: CameraPosition(
                              target: widget._selectedPoint,
                              zoom: 19.0,
                            ),
                            id: uuid,
                            name: _nameController.value.text,
                            imageUrl: "$uuid-image.png",
                            address: _addressController.value.text,
                          );

                          Provider.of<AttractionRepository>(
                            context,
                            listen: false,
                          ).addAttraction(newAttraction);

                          renameImage("$uuid-image.png");

                          Navigator.of(context).pop(newAttraction);
                        }
                      },
                      textColor: Theme.of(context).primaryColor,
                      child: Text(FlutterI18n.translate(context, 'save')),
                    ),
                  ],
                ),
              ]),
            ),
          ],
        ));
  }
}
