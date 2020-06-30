import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String dropdownValue;

  @override
  void didChangeDependencies() {
    setState(() {
      dropdownValue = FlutterI18n.currentLocale(context).toString();
    });
    super.didChangeDependencies();
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
          FlutterI18n.translate(context, "drawerMenuItems.profile"),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                FlutterI18n.translate(context, 'selectLanguage'),
              ),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: dropdownValue,
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                  FlutterI18n.refresh(context, Locale(newValue));
                });
              },
              items: <String>['en', 'hu']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child:
                      Text(FlutterI18n.translate(context, 'locale_' + value)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
