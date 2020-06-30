import 'package:feledhaza/components/organizer_progress_indicator.dart';
import 'package:feledhaza/models/AttractionMap/attraction.dart';
import 'package:feledhaza/models/AttractionMap/attraction_repository.dart';
import 'package:feledhaza/models/EventList/event_model.dart';
import 'package:feledhaza/models/EventList/event_repository.dart';
import 'package:feledhaza/screens/EventList/friends_multiselect.dart';
import 'package:feledhaza/models/FriendList/friend_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddEventModal extends StatefulWidget {
  @override
  _AddEventModalState createState() => _AddEventModalState();
}

class _AddEventModalState extends State<AddEventModal> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<Attraction> _attractions;
  List<Friend> _friends = [];
  String _dropdownValue;
  DateTime selectedDate = DateTime.now();

  @override
  void didChangeDependencies() {
    loadStateFromDB();
    super.didChangeDependencies();
  }

  Future<void> loadStateFromDB() async {
    _attractions =
        await Provider.of<AttractionRepository>(context).loadAttractions();
    _friends =
        await Provider.of<FriendRepository>(context, listen: false).load();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2050),
        locale: FlutterI18n.currentLocale(context),
        helpText: '');
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(5.0),
      children: <Widget>[
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  FlutterI18n.translate(context, 'addEventFrom.choosePlace'),
                  style: TextStyle(color: Colors.grey[600], fontSize: 16.0),
                ),
              ),
              FutureBuilder(
                  future: loadStateFromDB(),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return _attractions.isEmpty
                          ? Text(FlutterI18n.translate(
                              context, 'addEventFrom.noPlaces'))
                          : DropdownButton<String>(
                              isExpanded: true,
                              value: _dropdownValue,
                              icon: Icon(FontAwesomeIcons.caretDown),
                              iconSize: 16,
                              elevation: 16,
                              underline: Container(
                                height: 1,
                                color: Colors.grey[500],
                              ),
                              onChanged: (String newValue) {
                                setState(() {
                                  _dropdownValue = newValue;
                                });
                              },
                              items: _attractions
                                  .map((Attraction attraction) =>
                                      new DropdownMenuItem<String>(
                                          value: attraction.id,
                                          child: new Text(attraction.name)))
                                  .toList(),
                            );
                    } else {
                      return Center(
                        child: OrganizerProgressIndicator(),
                      );
                    }
                  }),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText:
                      FlutterI18n.translate(context, 'addEventFrom.eventTitle'),
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
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: FlutterI18n.translate(
                      context, 'addEventFrom.eventDescription'),
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
                padding: const EdgeInsets.only(top: 20.0),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    FlutterI18n.translate(context, 'addEventFrom.participant'),
                    style: TextStyle(color: Colors.grey[600], fontSize: 16.0),
                  ),
                ),
              ),
              FutureBuilder(
                  future: loadStateFromDB(),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        _friends.isNotEmpty) {
                      return Container(
                        width: double.maxFinite,
                        child: FriendsMultiSelect(
                          friends: _friends,
                        ),
                      );
                    } else {
                      return Text(
                        FlutterI18n.translate(
                          context,
                          'addEventFrom.noFriends',
                        ),
                      );
                    }
                  }),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  FlutterI18n.translate(context, "addEventFrom.selectDate"),
                  style: TextStyle(color: Colors.grey[600], fontSize: 16.0),
                ),
              ),
              InkWell(
                onTap: () => _selectDate(context),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      selectedDate.toString().split(" ").first,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                  child: Text(
                    FlutterI18n.translate(context, "cancel"),
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              FlatButton(
                child: Text(
                  FlutterI18n.translate(context, "save"),
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  if (_formKey.currentState.validate() &&
                      _attractions.isNotEmpty &&
                      Provider.of<EventModel>(context, listen: false)
                          .selectedFriendIds
                          .isNotEmpty) {
                    List<String> selectedFriendIds =
                        Provider.of<EventModel>(context, listen: false)
                            .selectedFriendIds;
                    Event newEvent = Event(
                        id: Uuid().v1(),
                        attractionId: _dropdownValue,
                        description: _descriptionController.value.text,
                        title: _titleController.value.text,
                        time: selectedDate,
                        invitedFriends: _friends
                            .where((friend) =>
                                selectedFriendIds.contains(friend.id))
                            .toList());

                    Provider.of<EventRepository>(context, listen: false)
                        .addEvent(newEvent, selectedFriendIds);
                    Navigator.of(context).pop(newEvent);
                  }
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
