import 'package:exzip_manager/models/gallery.dart';
import 'package:exzip_manager/screens/gallery_detail.dart';
import 'package:exzip_manager/widgets/tagpill.dart';
import 'package:flutter/material.dart';

class GalleryItem extends StatelessWidget {
  final Gallery gallery;

  const GalleryItem({
    Key? key,
    required this.gallery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: gallery.tags.length > 0 ? Colors.green[50] : Colors.red[50],
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: Image.asset(
              'assets/icons/zip1.png',
              fit: BoxFit.cover,
              height: 40,
            ),
            title: Text(
              gallery.name,
              maxLines: 3,
            ),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(GalleryDetailScreen.routeName, arguments: gallery);
            },
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ...gallery.tags.map((e) => TagPill(
                      parent: e.parent,
                      name: e.name,
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
