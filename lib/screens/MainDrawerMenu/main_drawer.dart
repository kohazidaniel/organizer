import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class MainDrawer extends StatelessWidget {
  MainDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "drawerMenuItems.attractions"),
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.popAndPushNamed(context, '/attractionmap');
            },
            leading: Icon(Icons.place),
          ),
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "drawerMenuItems.friendList"),
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.popAndPushNamed(context, '/friendlist');
            },
            leading: Icon(Icons.people),
          ),
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "drawerMenuItems.events"),
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.popAndPushNamed(context, '/eventlist');
            },
            leading: Icon(Icons.event),
          ),
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "drawerMenuItems.profile"),
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.popAndPushNamed(context, '/profile');
            },
            leading: Icon(Icons.person),
          ),
        ],
      ),
    ));
  }
}
