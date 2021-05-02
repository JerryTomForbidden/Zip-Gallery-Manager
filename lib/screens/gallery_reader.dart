import 'dart:io';
import 'dart:async';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

List<dynamic> getZipFileContentAsync(Archive _archive) {
  List<dynamic> res = [];
  print('in compute');
  _archive.files.sort((a, b) => a.name.compareTo(b.name));
  for (int i = 0; i < _archive.files.length; i++) {
    final element = _archive.files[i];
    final zc = element.content;
    res.add(zc);
  }
  print('out compute');
  return res;
}

Future<List<dynamic>> loadArchive(String? path) async {
  final File f = File(path!);
  final FileStat fstat = await f.stat();
  if (fstat.type == FileSystemEntityType.directory) {
    List images = [];
    await for (FileSystemEntity file
        in Directory(f.path).list(recursive: false, followLinks: false)) {
      final fname = file.path.substring(file.path.lastIndexOf('/') + 1);
      if (fname.lastIndexOf('.') > 0) {
        final String ext = fname.substring(fname.lastIndexOf('.') + 1);
        if (['jpeg', 'jpg', 'png', 'bmp'].contains(ext)) {
          images.add(file);
        }
      }
    }
    return images;
  } else {
    final bytes = await f.readAsBytes();
    final _archive = ZipDecoder().decodeBytes(bytes);
    return compute(getZipFileContentAsync, _archive);
  }
}

class GalleryReaderScreen extends StatefulWidget {
  static String routeName = '/gallery-reader';

  @override
  _GalleryReaderScreenState createState() => _GalleryReaderScreenState();
}

class _GalleryReaderScreenState extends State<GalleryReaderScreen> {
  Future<List<dynamic>>? _future;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PageController? _pageController = PageController(initialPage: 0);
    final String path = ModalRoute.of(context)!.settings.arguments as String;

    _future = loadArchive(path);

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: Text(''),
        ),
        body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) => SafeArea(
            child: Container(
                constraints: BoxConstraints.expand(),
                child: snapshot.connectionState == ConnectionState.waiting
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : PageView(
                        children: (snapshot.data as List<dynamic>)
                            .map(
                              (e) => Center(
                                child: InteractiveViewer(
                                  scaleEnabled: true,
                                  minScale: 0.5,
                                  maxScale: 2,
                                  panEnabled: false,
                                  boundaryMargin: EdgeInsets.all(15),
                                  child: Image.file(
                                    e,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        controller: _pageController,
                        onPageChanged: (value) {
                          //setState(() {});
                        },
                      )),
          ),
        ));
  }
}
