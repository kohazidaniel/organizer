import 'package:contacts_service/contacts_service.dart';
import 'package:feledhaza/components/organizer_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class ContactChooser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'chooseAContact')),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: FutureBuilder<Iterable<Contact>>(
            future: ContactsService.getContacts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return ListView(
                  children: snapshot.data.map((contact) {
                    return ListTile(
                      leading: (contact.avatar.isNotEmpty)
                          ? CircleAvatar(
                              backgroundImage: MemoryImage(contact.avatar),
                            )
                          : CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                      title: Text(contact.displayName),
                      onTap: () {
                        Navigator.pop(context, contact);
                      },
                    );
                  }).toList(),
                );
              }
              return Center(child: OrganizerProgressIndicator());
            }),
      ),
    );
  }
}
