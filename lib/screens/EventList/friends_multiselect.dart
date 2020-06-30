import 'package:feledhaza/models/EventList/event_model.dart';
import 'package:feledhaza/models/FriendList/friend_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsMultiSelect extends StatefulWidget {
  final List<Friend> friends;
  final bool preview;

  FriendsMultiSelect({@required this.friends, this.preview = false});

  @override
  _FriendsMultiSelectState createState() => _FriendsMultiSelectState();
}

class _FriendsMultiSelectState extends State<FriendsMultiSelect> {
  List<String> selectedFriendIds = [];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        alignment: AlignmentDirectional.centerStart,
        height: 55,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.friends.length,
          itemBuilder: (context, index) {
            Friend currentFriend = widget.friends[index];
            bool isSelected =
                Provider.of<EventModel>(context).checkForId(currentFriend.id);

            return InkWell(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              onTap: () => widget.preview
                  ? {}
                  : {
                      if (isSelected)
                        setState(() {
                          Provider.of<EventModel>(context, listen: false)
                              .removeId(currentFriend.id);
                        })
                      else
                        setState(() {
                          Provider.of<EventModel>(context, listen: false)
                              .addId(currentFriend.id);
                        })
                    },
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Icon(Icons.person),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected && !widget.preview
                                  ? Colors.blue
                                  : Colors.transparent,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: isSelected && !widget.preview
                                  ? Icon(
                                      Icons.check,
                                      size: 10.0,
                                      color: Colors.white,
                                    )
                                  : Container(
                                      width: 10.0,
                                      height: 10.0,
                                    ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Text(
                      currentFriend.name.split(" ")[1],
                      style: TextStyle(fontSize: 12.0),
                    )
                  ],
                ),
              ),
            );
          },
          shrinkWrap: true,
        ),
      ),
    );
  }
}
