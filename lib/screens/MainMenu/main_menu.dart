import 'package:flutter_i18n/flutter_i18n.dart';
import "package:collection/collection.dart";
import 'package:table_calendar/table_calendar.dart';
import 'package:feledhaza/models/EventList/event_repository.dart';
import 'package:feledhaza/screens/MainDrawerMenu/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  Map<DateTime, List> _events = Map();
  List _selectedEvents = [];
  CalendarController _calendarController;

  @override
  void initState() {
    _calendarController = CalendarController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    initStateFromDB();
    super.didChangeDependencies();
  }

  Future<void> initStateFromDB() async {
    List<Event> eventList = await Provider.of<EventRepository>(
      context,
      listen: false,
    ).loadEventList();

    groupBy(eventList, (Event event) => event.time.toString().split(' ').first)
        .forEach((key, value) {
      List<String> eventTitleList = [];
      value.forEach((event) {
        eventTitleList.add(event.title);
      });
      _events[DateTime.parse(key)] = eventTitleList;
    });
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedEvents = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Organiser'.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w300),
          )),
      drawer: MainDrawer(),
      body: WillPopScope(
        onWillPop: () async => false,
        child: Column(
          children: <Widget>[
            TableCalendar(
                calendarController: _calendarController,
                locale: FlutterI18n.currentLocale(context).toString(),
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  todayColor: Theme.of(context).primaryColor,
                  selectedColor:
                      Theme.of(context).primaryColor.withOpacity(0.75),
                ),
                headerStyle: HeaderStyle(formatButtonVisible: false),
                events: _events,
                onDaySelected: _onDaySelected),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedEvents.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 340,
                    child: Card(
                      elevation: 3.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        title: Text(
                          _selectedEvents[index].toString(),
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
