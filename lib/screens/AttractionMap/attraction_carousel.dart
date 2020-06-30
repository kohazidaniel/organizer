import 'dart:async';

import 'package:feledhaza/models/AttractionMap/attraction.dart';
import 'package:feledhaza/models/AttractionMap/attraction_repository.dart';
import 'package:feledhaza/screens/AttractionMap/attraction_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AttractionCarousel extends StatelessWidget {
  const AttractionCarousel(
      {Key key,
      @required this.attractions,
      @required this.mapController,
      @required this.removeAttractionCallback})
      : super(key: key);

  final List<Attraction> attractions;
  final Completer<GoogleMapController> mapController;
  final Function(String) removeAttractionCallback;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: SizedBox(
          height: 90.0,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: attractions.length,
              itemBuilder: (context, index) {
                Attraction currentAttraction = attractions[index];
                return SizedBox(
                  width: 340,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Card(
                      child: Center(
                        child: ListTile(
                          leading: Container(
                            child: AttractionImage(
                              imageUrl: currentAttraction.imageUrl,
                            ),
                          ),
                          title: Text(currentAttraction.name),
                          subtitle: Text(currentAttraction.address),
                          trailing: IconButton(
                            onPressed: () => {
                              showDialog(
                                context: context,
                                builder: (_) => new AlertDialog(
                                  content: RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: FlutterI18n.translate(
                                            context,
                                            'deletePlaceMessage',
                                          ),
                                        ),
                                        TextSpan(
                                          text: currentAttraction.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                        child: Text(
                                          FlutterI18n.translate(
                                            context,
                                            'cancel',
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }),
                                    FlatButton(
                                      child: Text(
                                        FlutterI18n.translate(
                                          context,
                                          'delete',
                                        ),
                                      ),
                                      onPressed: () {
                                        Provider.of<AttractionRepository>(
                                          context,
                                          listen: false,
                                        ).removeAttraction(
                                          currentAttraction.id,
                                        );
                                        removeAttractionCallback(
                                          currentAttraction.id,
                                        );
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                ),
                              ),
                            },
                            icon: Icon(FontAwesomeIcons.trash),
                            iconSize: 16.0,
                          ),
                          onTap: () => nextPosition(currentAttraction),
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }

  Future<void> nextPosition(Attraction attraction) async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(attraction.cameraPosition));
    controller.showMarkerInfoWindow(MarkerId('marker-' + attraction.name));
  }
}
