import 'package:feledhaza/models/EventList/event_model.dart';
import 'package:feledhaza/models/EventList/event_repository.dart';
import 'package:feledhaza/screens/EventList/add_event_modal.dart';
import 'package:feledhaza/screens/EventList/friends_multiselect.dart';
import 'package:feledhaza/screens/EventList/remove_event_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class EventList extends StatefulWidget {
  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  List<Event> _eventList = [];

  @override
  void initState() {
    loadEventList();
    super.initState();
  }

  void loadEventList() async {
    var eventList = await Provider.of<EventRepository>(context, listen: false)
        .loadEventList();
    this.setState(() {
      _eventList = eventList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          FlutterI18n.translate(context, "drawerMenuItems.events"),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.calendarPlus),
              onPressed: () => {
                    showDialog(
                        context: context,
                        builder: (_) => new AddEventModal()).then((newEvent) {
                      Provider.of<EventModel>(context, listen: false)
                          .resetSelectedFriendsIds();
                      setState(() {
                        if (newEvent != null) _eventList.add(newEvent);
                      });
                    })
                  })
        ],
        centerTitle: true,
      ),
      body: _eventList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.calendar,
                    size: 48.0,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  SizedBox(height: 10),
                  Text(
                    FlutterI18n.translate(context, 'addNewEvents'),
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.withOpacity(0.75)),
                  )
                ],
              ),
            )
          : ListView.builder(
              itemCount: _eventList.length,
              itemBuilder: (context, index) {
                Event currentEvent = _eventList[index];
                return SizedBox(
                  height: 170,
                  child: Card(
                    child: InkWell(
                      onLongPress: () => showDialog(
                          context: context,
                          builder: (context) {
                            return RemoveEventDialog(currentEvent);
                          }).then((eventId) => {
                            if (eventId != null)
                              setState(() {
                                _eventList.removeWhere(
                                    (event) => event.id == eventId);
                              })
                          }),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      currentEvent.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      currentEvent.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(currentEvent.time
                                    .toUtc()
                                    .toString()
                                    .split(' ')
                                    .first),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  FlutterI18n.translate(
                                      context, 'invitedFriends'),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                            FriendsMultiSelect(
                              friends: currentEvent.invitedFriends,
                              preview: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
    );
  }
}
