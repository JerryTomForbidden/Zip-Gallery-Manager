import 'package:exzip_manager/models/gallery.dart';
import 'package:exzip_manager/models/tag.dart';
import 'package:exzip_manager/screens/gallery_detail.dart';
import 'package:exzip_manager/widgets/TagPill.dart';
import 'package:flutter/material.dart';

class GalleryItem extends StatelessWidget {
  final Gallery gallery;
  List<TextSpan>? highlightName;

  GalleryItem({
    Key? key,
    required this.gallery,
    this.highlightName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = (highlightName != null)
        ? RichText(
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
                style: Theme.of(context).textTheme.caption,
                children: highlightName))
        : Text(
            gallery.name,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          );

    return Card(
      color: gallery.tags.length > 0 ? Colors.green[50] : Colors.red[50],
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: Image.asset(
              _getFileTypeAssetName(),
              fit: BoxFit.fill,
              height: 40,
            ),
            title: text,
            onTap: () {
              Navigator.of(context)
                  .pushNamed(GalleryDetailScreen.routeName, arguments: gallery);
            },
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _listOfPills(context, gallery.tags),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _listOfPills(BuildContext context, List<Tag> tags) {
    double width = MediaQuery.of(context).size.width;
    // -20 is padding/margin
    // -24 is ellipsis pill
    // 64 is size of one pill (60 + 2 padding x2)
    int nOfPills = ((width - 20 - 24) ~/ 64);

    if ((tags.length / nOfPills) > 1) {
      List<Widget> res = tags
          .getRange(0, nOfPills)
          .map((e) => Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              child: TagPill(parent: e.parent, name: e.name)))
          .toList();
      res.add(TagPill.ellipsis(context));
      return res;
    } else {
      return tags
          .map((e) => Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              child: TagPill(parent: e.parent, name: e.name)))
          .toList();
    }
  }

  String _getFileTypeAssetName() {
    if (gallery.name.lastIndexOf('.') > 0) {
      final String ext = gallery.name
        ..substring(gallery.name.lastIndexOf('.') + 1);
      return "assets/icons/zip@4x.png";
    } else
      return "assets/icons/folder@1x.png";
  }
}
