import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

import 'package:exzip_manager/models/gallery.dart';
import 'package:exzip_manager/providers/gallery_provider.dart';
import 'package:exzip_manager/providers/tag_provider.dart';
import 'package:exzip_manager/screens/gallery_reader.dart';
import 'package:exzip_manager/widgets/DropDownField.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GalleryDetailScreen extends StatefulWidget {
  static String routeName = '/gallery-detail';

  @override
  _GalleryDetailScreenState createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends State<GalleryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final Gallery _gallery =
        ModalRoute.of(context)!.settings.arguments as Gallery;

    Future<int> _fileInit() async {
      File f = File(_gallery.path);

      RandomAccessFile res = await f.open(mode: FileMode.read);

      int length = await res.length();
      res.close();
      return length;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _gallery.name,
          maxLines: 1,
        ),
      ),
      body: Container(
          child: FutureBuilder(
        future: _fileInit(),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : GalleryDetail(
                    gallery: _gallery,
                    size: snapshot.hasData ? snapshot.data as int : -1,
                  ),
      )),
    );
  }
}

class GalleryDetail extends StatefulWidget {
  const GalleryDetail({Key? key, required Gallery gallery, required int size})
      : _gallery = gallery,
        _size = size,
        super(key: key);

  final Gallery _gallery;
  final int _size;

  @override
  _GalleryDetailState createState() => _GalleryDetailState();
}

class _GalleryDetailState extends State<GalleryDetail> {
  late TextEditingController _parentFieldController = TextEditingController();
  late TextEditingController _childrenFieldController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TagProvider tgp = Provider.of<TagProvider>(context, listen: false);
    GalleryProvider gp = Provider.of<GalleryProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget._size != -1
            ? '${(widget._size / 1000000).toStringAsFixed(0)}'
            : "-1"),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          child: DropDownField(
            controller: _parentFieldController,
            enabled: true,
            strict: false,
            labelText: "Parent tag",
            items: tgp.parents,
            onValueChanged: (value) {
              setState(() {});
            },
          ),
        ),
        DropDownField(
          controller: _childrenFieldController,
          enabled: true,
          strict: false,
          labelText: "Child tag",
          items: _parentFieldController.text == ''
              ? []
              : tgp.getChildrenOfParent(_parentFieldController.text),
        ),
        TextButton(
            onPressed: () async {
              int id = await tgp.exist(_parentFieldController.text,
                  _childrenFieldController.text, true);
              int tid = await gp.tagGallery(widget._gallery.id, id);
            },
            child: Text('Tag gallery')),
        TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(GalleryReaderScreen.routeName,
                  arguments: widget._gallery.path);
            },
            child: Text('View Gallery'))
      ],
    );
  }
}

// Pour tagger on a besoin du tagprovider et galleryprovider
// verifie si le tag existe deja ? sinon on le crée (tag provider)
// on insere dans GallerieTags le couple gallery id et tag id
// si succes: on tag l'objet gallery correspondant et on le rearrange dans les listes
//
