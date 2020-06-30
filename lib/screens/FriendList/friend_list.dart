import 'package:contacts_service/contacts_service.dart';
import 'package:feledhaza/models/FriendList/friend_repository.dart';
import 'package:feledhaza/screens/FriendList/contant_chooser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class FriendList extends StatefulWidget {
  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  List<Friend> friendList = [];

  @override
  void initState() {
    loadFriendList();
    super.initState();
  }

  void loadFriendList() async {
    var friendListFromDb =
        await Provider.of<FriendRepository>(context, listen: false).load();
    this.setState(() {
      friendList = friendListFromDb;
    });
  }

  void chooseAContact(BuildContext context) async {
    if (await Permission.contacts.request().isGranted) {
      Contact contact = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ContactChooser()),
      );

      Friend newFriend = Friend(
          id: contact.identifier,
          email: contact.emails.first.value,
          name: contact.familyName + " " + contact.givenName,
          phone: contact.phones.first.value);

      Provider.of<FriendRepository>(context, listen: false)
          .addFriend(newFriend);
      this.setState(() {
        friendList.add(newFriend);
      });
    } else {
      openAppSettings();
    }
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
          FlutterI18n.translate(context, "drawerMenuItems.friendList"),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () => chooseAContact(context),
          )
        ],
        centerTitle: true,
      ),
      body: Container(
        child: friendList.isNotEmpty
            ? ListView.builder(
                itemCount: friendList.length,
                itemBuilder: (context, index) {
                  Friend currentFriend = friendList[index];
                  return Dismissible(
                    background: Container(color: Colors.red[500]),
                    direction: DismissDirection.endToStart,
                    key: Key(currentFriend.id),
                    onDismissed: (direction) {
                      setState(() {
                        friendList.removeAt(index);
                      });
                      Provider.of<FriendRepository>(context, listen: false)
                          .removeFriend(currentFriend);
                      Scaffold.of(context).hideCurrentSnackBar();
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(currentFriend.name +
                              " " +
                              FlutterI18n.translate(context, "removed"))));
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Icon(Icons.person),
                      ),
                      contentPadding: EdgeInsets.all(10.0),
                      title: Text(currentFriend.name),
                      subtitle: Text(
                          currentFriend.phone + "\n" + currentFriend.email),
                    ),
                  );
                })
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.userFriends,
                      size: 48.0,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    SizedBox(height: 10),
                    Text(
                      FlutterI18n.translate(context, 'addSomeFriends'),
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.withOpacity(0.75)),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
