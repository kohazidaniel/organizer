import 'dart:async';

import 'package:feledhaza/models/AttractionMap/attraction.dart';
import 'package:feledhaza/models/AttractionMap/attraction_repository.dart';
import 'package:feledhaza/screens/AttractionMap/attraction_carousel.dart';
import 'package:feledhaza/screens/AttractionMap/attraction_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AttractionMap extends StatefulWidget {
  @override
  State<AttractionMap> createState() => AttractionMapState();
}

class AttractionMapState extends State<AttractionMap> {
  Completer<GoogleMapController> _mapController = Completer();
  String _mapStyle;
  Set<Marker> _markers = Set();
  List<Attraction> _attractions = [];
  LatLng _selectedPoint;

  static final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(46.71213, 19.84458),
    zoom: 13.75,
  );

  @override
  initState() {
    super.initState();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    _loadAttractions().whenComplete(() => _initMarkers());
  }

  Future<void> _loadAttractions() async {
    _attractions = await Provider.of<AttractionRepository>(
      context,
      listen: false,
    ).loadAttractions();
  }

  void _initMarkers() {
    setState(() {
      _markers = _attractions
          .map(
            (Attraction attraction) => Marker(
              markerId: MarkerId(attraction.id + '-marker'),
              position: attraction.cameraPosition.target,
              infoWindow: InfoWindow(
                title: attraction.name,
                snippet: attraction.address,
              ),
            ),
          )
          .toSet();
    });
  }

  void _removeAttractionCallback(String attractionId) {
    setState(() {
      _attractions.removeWhere((attraction) => attraction.id == attractionId);
      _markers.removeWhere(
        (marker) => marker.markerId == MarkerId(attractionId + '-marker'),
      );
    });
  }

  void _selectNewAttraction(LatLng point) {
    this.setState(() {
      _markers.add(Marker(
        markerId: MarkerId('new-marker'),
        position: point,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
      _selectedPoint = point;
    });
  }

  void _resetSelectedPoint() {
    this.setState(() {
      _markers
          .removeWhere((marker) => marker.markerId == MarkerId('new-marker'));
      _selectedPoint = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialPosition,
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
                controller.setMapStyle(_mapStyle);
              },
              compassEnabled: false,
              zoomControlsEnabled: false,
              markers: _markers,
              onLongPress: (LatLng point) => _selectNewAttraction(point)),
          SafeArea(
            child: _attractions.isEmpty
                ? SizedBox(
                    height: 90,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        child: Center(
                          child: Text(
                            FlutterI18n.translate(
                              context,
                              'addPlaceTip',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  )
                : AttractionCarousel(
                    attractions: _attractions,
                    mapController: _mapController,
                    removeAttractionCallback: _removeAttractionCallback,
                  ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
          overlayOpacity: 0.0,
          elevation: 8.0,
          backgroundColor: Theme.of(context).primaryColor,
          animatedIcon: AnimatedIcons.menu_close,
          curve: Curves.bounceIn,
          visible: _selectedPoint != null,
          children: [
            SpeedDialChild(
                child: Icon(Icons.delete),
                backgroundColor: Theme.of(context).primaryColor,
                label: FlutterI18n.translate(context, 'cancel'),
                labelStyle: TextStyle(fontSize: 14.0),
                onTap: () => _resetSelectedPoint()),
            SpeedDialChild(
              child: Icon(Icons.add_location),
              backgroundColor: Theme.of(context).primaryColor,
              label: FlutterI18n.translate(context, 'add'),
              labelStyle: TextStyle(fontSize: 14.0),
              onTap: () => showDialog(
                context: context,
                builder: (_) => new AttractionFormDialog(_selectedPoint),
              ).then((newAttraction) {
                _resetSelectedPoint();
                if (newAttraction != null) {
                  setState(() {
                    _attractions.add(newAttraction);
                    _markers.add(Marker(
                      markerId: MarkerId(newAttraction.id + '-marker'),
                      position: newAttraction.cameraPosition.target,
                      icon: BitmapDescriptor.defaultMarker,
                    ));
                  });
                }
              }),
            ),
          ]),
    );
  }
}
