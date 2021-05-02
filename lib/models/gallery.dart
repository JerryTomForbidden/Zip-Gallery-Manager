import 'package:exzip_manager/models/tag.dart';

class Gallery {
  final int id;
  final String name;
  final String path;
  final List<Tag> tags;

  Gallery({
    required this.id,
    required this.name,
    required this.path,
    required this.tags,
  });
}
