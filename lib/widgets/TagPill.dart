import 'package:flutter/material.dart';

class TagPill extends StatelessWidget {
  final String parent;
  final String name;
  //TODO we may need the Tag object as a whole
  //cause we should display only the name, and put the background color to the parent tag color (when feature will be added)
  const TagPill({Key? key, required this.parent, required this.name})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[350]!, width: 0.5),
          borderRadius: BorderRadius.circular(15),
          color: Color(0xFFEDF7E9)),
      alignment: Alignment.center,
      width: 60,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          '$name',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .subtitle2!
              .copyWith(color: Colors.grey[400]),
        ),
      ),
    );
  }

  static ellipsis(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[350]!, width: 0.5),
          borderRadius: BorderRadius.circular(15),
          color: Color(0xFFEDF7E9)),
      alignment: Alignment.center,
      width: 20,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          '...',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .subtitle2!
              .copyWith(color: Colors.grey[400]),
        ),
      ),
    );
  }
}
