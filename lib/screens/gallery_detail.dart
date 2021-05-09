import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

import 'package:exzip_manager/models/gallery.dart';
import 'package:exzip_manager/providers/gallery_provider.dart';
import 'package:exzip_manager/providers/tag_provider.dart';
import 'package:exzip_manager/screens/gallery_reader.dart';
import 'package:exzip_manager/widgets/DropDownField.dart';
import 'package:exzip_manager/widgets/TagPill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    double width = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10, left: 10),
          padding: EdgeInsets.all(8.0),
          height: 150,
          decoration: BoxDecoration(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(),
                  child: Image.asset(
                    widget._size == -1
                        ? "assets/icons/folder@4x.png"
                        : "assets/icons/zip@4x.png",
                    fit: BoxFit.contain,
                  ),
                ),
                flex: 2,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                      decoration: BoxDecoration(),
                      child: Text(
                        widget._gallery.name,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                      child: Text(
                          widget._size != -1
                              ? 'Size: ${(widget._size / 1000000).toStringAsFixed(0)} MB'
                              //TODO we shouldn't assume that
                              : "Folder",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic)),
                    ),
                  ],
                ),
                flex: 6,
              )
            ],
          ),
        ),
        //Display tags of gallery
        widget._gallery.tags.length >= 1
            ? Container(
                child: Stack(children: [
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    width: double.infinity,
                    height: ((widget._gallery.tags.length / ((width - 32) / 60))
                                .floor() +
                            1) *
                        38,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey[200]!,
                          style: BorderStyle.solid,
                          width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GridView.extent(
                      maxCrossAxisExtent: 64,
                      //TODO TROP GRAND A CHANGER ??
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 8,
                      childAspectRatio: 60 / 18,
                      children: widget._gallery.tags
                          .map((e) => TagPill(parent: e.parent, name: e.name))
                          .toList(),
                    ),
                  ),
                  Positioned(
                      left: 25,
                      top: 4,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        color: Colors.white,
                        child: Text(
                          'Tags',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(
                                  fontStyle: FontStyle.normal,
                                  fontSize: 10,
                                  color: Colors.grey),
                        ),
                      ))
                ]),
              )
            : Container(),
        Divider(),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 28.0, vertical: 15.0),
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
        Container(
            margin: EdgeInsets.symmetric(horizontal: 28.0, vertical: 15.0),
            child: DropDownField(
              controller: _childrenFieldController,
              enabled: true,
              strict: false,
              labelText: "Child tag",
              items: _parentFieldController.text == ''
                  ? []
                  : tgp.getChildrenOfParent(_parentFieldController.text),
            )),

        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 28.0, vertical: 15.0),
                child: ElevatedButton(
                    onPressed: () async {
                      //TODO try catch so we can display an error on fail
                      int id = await tgp.exist(_parentFieldController.text,
                          _childrenFieldController.text, true);
                      int tid = -1;
                      if (id > 0)
                        tid = await gp.tagGallery(widget._gallery.id, id);
                      print('TID: $tid  $id');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: tid > 0 ? Colors.green : Colors.red,
                          content: Text(tid > 0
                              ? 'Succefuly tagged gallery'
                              : 'Failed to tag gallery')));
                      setState(() {});
                    },
                    child: Text('Tag Gallery')),
              ),
            ],
          ),
        ),
        Divider(),
        Spacer(),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed(GalleryReaderScreen.routeName,
                arguments: widget._gallery.path);
          },
          child: Text('View Gallery'),
          style: ButtonStyle(),
        ),
        Spacer()
      ],
    );
  }
}

// Pour tagger on a besoin du tagprovider et galleryprovider
// verifie si le tag existe deja ? sinon on le crée (tag provider)
// on insere dans GallerieTags le couple gallery id et tag id
// si succes: on tag l'objet gallery correspondant et on le rearrange dans les listes
//
