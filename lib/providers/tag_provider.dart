import 'package:exzip_manager/helpers/db_helper.dart';
import 'package:exzip_manager/models/tag.dart';
import 'package:flutter/foundation.dart';

class TagProvider with ChangeNotifier {
  static String dbname = 'exzip.db';
  bool initialized = false;
  List<Tag> _tags = [];

  List<Tag> get tags {
    return [..._tags];
  }

  List<String> get parents {
    Set<String>? _set = Set();
    this.tags.forEach((element) {
      _set.add(element.parent);
    });
    return _set.toList();
  }

  List<String> getChildrenOfParent(String parent) {
    Set<String>? _set = Set();
    this.tags.forEach((element) {
      if (element.parent == parent) {
        _set.add(element.name);
      }
    });
    return _set.toList();
  }

  TagProvider();

  Future<void> initialize() async {
    _tags = await DBHelper.getAlltags();

    initialized = true;
    notifyListeners();
  }

  // USERS ADDED TAGS
  Future<int> insert(String parent, String name) async {
    try {
      // INSERT PARENT in ParentTags
      // Then INSERT TAG(parent, name) in Tags
      // we may inserting something that's already exist here
      await DBHelper.insert("ParentTags", {'name': parent});

      int id = await DBHelper.insert("Tags", {'parent': parent, 'name': name});

      //REINITIALISER LES TAGS
      await initialize();

      notifyListeners();
      return id;
    } catch (e) {
      return -1;
    }
  }

  /// return Tag Id if exists or -1
  Future<int> exist(String parent, String name, [bool create = false]) async {
    bool _exist = false;
    int _id = -1;
    if (parent.isEmpty || name.isEmpty) {
      return -1;
    }
    for (int i = 0; i < _tags.length; i++) {
      if (_tags[i].name == name && _tags[i].parent == parent) {
        _id = _tags[i].id;
        _exist = true;
        break;
      }
    }

    if (!_exist && create) {
      //check if parent exist in DB or create it before inserting new Tag
      try {
        _id = await insert(parent, name);
        return _id;
      } catch (e) {
        _id = -1;
        return _id;
      }
    } else {
      return _id;
    }
  }
}
