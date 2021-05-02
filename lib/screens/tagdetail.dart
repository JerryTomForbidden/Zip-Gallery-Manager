import 'package:exzip_manager/models/gallery.dart';
import 'package:exzip_manager/providers/gallery_provider.dart';
import 'package:exzip_manager/providers/tag_provider.dart';
import 'package:exzip_manager/screens/gallery_detail.dart';
import 'package:exzip_manager/screens/tags.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagDetailScreen extends StatelessWidget {
  static String routeName = '/tag-detail';

  Future<void> _deleteThisParentTag(BuildContext context) async {
    print('on _delete');
    Navigator.of(context).pop();
  }

  Future<void> _deleteChildTag(BuildContext context) async {}

  @override
  Widget build(BuildContext context) {
    final parent = ModalRoute.of(context)!.settings.arguments as String;
    final TagProvider tg = Provider.of<TagProvider>(context, listen: false);
    final GalleryProvider gp =
        Provider.of<GalleryProvider>(context, listen: false);
    final List<String> children = tg.getChildrenOfParent(parent);

    return Scaffold(
      appBar: AppBar(
        title: Text(parent),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Deleting the group tag : $parent'),
                    content: Text(
                        "Deleting this group tag will untag all galleries associated. This action is not reversible. Do you wish to continue?"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('NO')),
                      TextButton(
                          onPressed: () async {
                            print('on before _delete');
                            Navigator.of(context).pop();
                            await _deleteThisParentTag(context);
                          },
                          child: Text('YES')),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final List<Gallery> galleries =
              gp.getGalleriesWithTag(parent, children[index]);
          return ChildrenTagDetail(
              child: children[index], galleries: galleries);
        },
        itemCount: children.length,
      ),
    );
  }
}

class ChildrenTagDetail extends StatefulWidget {
  const ChildrenTagDetail({
    Key? key,
    required this.child,
    required this.galleries,
  }) : super(key: key);

  final String child;
  final List<Gallery> galleries;

  @override
  _ChildrenTagDetailState createState() => _ChildrenTagDetailState();
}

class _ChildrenTagDetailState extends State<ChildrenTagDetail> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.child),
            subtitle: Text('Contains ${widget.galleries.length} galleries'),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          AnimatedContainer(
            curve: Curves.easeIn,
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: (!_expanded) ? 0 : 5,
            child: Divider(),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: (!_expanded) ? 0 : widget.galleries.length * 20,
            child: ListView(
              children: [
                ...widget.galleries.map((e) => Container(
                      margin: EdgeInsets.symmetric(vertical: 2),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pushNamed(
                            GalleryDetailScreen.routeName,
                            arguments: e),
                        child: Text(
                          e.name,
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.blueAccent,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ))
              ],
            ),
          )
        ],
      ),
      elevation: 1,
      margin: EdgeInsets.fromLTRB(5, 8, 5, 0),
      color: Color(0xAAFAFAFE),
    );
  }
}
