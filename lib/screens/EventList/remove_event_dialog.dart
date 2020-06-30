import 'package:feledhaza/models/EventList/event_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

class RemoveEventDialog extends StatelessWidget {
  final Event event;
  RemoveEventDialog(this.event);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text(FlutterI18n.translate(context, 'delete')),
      content: RichText(
        text: TextSpan(
          style: TextStyle(
              fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black),
          children: <TextSpan>[
            TextSpan(
              text: FlutterI18n.translate(
                context,
                'deleteEventMessage',
              ),
            ),
            TextSpan(
              text: event.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: new Text(FlutterI18n.translate(context, 'cancel')),
        ),
        new FlatButton(
          onPressed: () {
            Provider.of<EventRepository>(context, listen: false)
                .removeEvent(event.id);
            Navigator.of(context).pop(event.id);
          },
          child: new Text(FlutterI18n.translate(context, 'delete')),
        ),
      ],
    );
  }
}
