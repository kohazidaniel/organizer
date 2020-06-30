import 'package:flutter/material.dart';

class EventModel with ChangeNotifier {
  List<String> _selectedFriendIds = [];

  get selectedFriendIds => _selectedFriendIds;

  bool checkForId(String id) {
    return _selectedFriendIds.indexOf(id) != -1;
  }

  void addId(id) {
    _selectedFriendIds.add(id);
    notifyListeners();
  }

  void removeId(id) {
    _selectedFriendIds.remove(id);
    notifyListeners();
  }

  void resetSelectedFriendsIds() {
    _selectedFriendIds = [];
    notifyListeners();
  }
}
