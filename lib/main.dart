import 'package:camera/camera.dart';
import 'package:feledhaza/models/AttractionMap/attraction_repository.dart';
import 'package:feledhaza/models/EventList/event_model.dart';
import 'package:feledhaza/models/EventList/event_repository.dart';
import 'package:feledhaza/models/FriendList/friend_repository.dart';
import 'package:feledhaza/screens/AttractionMap/attraction_map.dart';
import 'package:feledhaza/screens/EventList/event_list.dart';
import 'package:feledhaza/screens/FriendList/friend_list.dart';
import 'package:feledhaza/screens/MainDrawerMenu/main_drawer.dart';
import 'package:feledhaza/screens/MainMenu/main_menu.dart';
import 'package:feledhaza/screens/Profile/profile.dart';
import 'package:feledhaza/sql.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
        useCountryCode: false,
        fallbackFile: 'en',
        basePath: 'assets/lang',
        forcedLocale: Locale('hu')),
  );

  WidgetsFlutterBinding.ensureInitialized();

  await flutterI18nDelegate.load(null);

  final cameras = await availableCameras();
  final camera = cameras.length > 0 ? cameras.first : null;

  final sql = Sql();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => EventModel()),
      Provider(create: (_) => AttractionRepository(sql: sql)),
      Provider(create: (_) => FriendRepository(sql: sql)),
      Provider(create: (_) => EventRepository(sql: sql)),
      Provider.value(value: camera),
    ],
    child: MyApp(flutterI18nDelegate),
  ));
}

class MyApp extends StatelessWidget {
  final FlutterI18nDelegate flutterI18nDelegate;

  MyApp(this.flutterI18nDelegate);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organiser',
      theme: ThemeData(
        primaryColor: Color(0xFF165b9a),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainMenu(),
        '/attractionmap': (context) => AttractionMap(),
        '/friendlist': (context) => FriendList(),
        '/eventlist': (context) => EventList(),
        '/profile': (context) => Profile(),
      },
      localizationsDelegates: [
        flutterI18nDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Organiser'.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w300),
          )),
      body: MainMenu(),
      drawer: MainDrawer(),
    );
  }
}
