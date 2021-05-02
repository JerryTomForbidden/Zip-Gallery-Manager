import 'package:flutter/foundation.dart';

class Tag {
  final int id;
  final String parent;
  final String name;

  Tag({
    required this.id,
    required this.parent,
    required this.name,
  });

  @override
  String toString() {
    // TODO: implement toString
    return '$parent:$name';
  }
}
