import 'package:flutter/material.dart';

class OrganizerProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
      valueColor:
          new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
    ));
  }
}
