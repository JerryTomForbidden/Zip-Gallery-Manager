import 'dart:io';
import 'dart:async';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GalleryFiles {
  final bool isArchive;
  final List<dynamic> files;

  GalleryFiles({required this.isArchive, required this.files});
}

GalleryFiles getZipFileContentAsync(Archive _archive) {
  List<dynamic> res = [];
  print('in compute');
  _archive.files.sort((a, b) => a.name.compareTo(b.name));
  for (int i = 0; i < _archive.files.length; i++) {
    final element = _archive.files[i];
    final zc = element.content;
    res.add(zc);
  }
  print('out compute');
  return GalleryFiles(isArchive: true, files: res);
}

Future<GalleryFiles> loadArchive(String? path) async {
  final File f = File(path!);
  final FileStat fstat = await f.stat();
  if (fstat.type == FileSystemEntityType.directory) {
    List<File> images = [];
    await for (FileSystemEntity file
        in Directory(f.path).list(recursive: false, followLinks: false)) {
      final fname = file.path.substring(file.path.lastIndexOf('/') + 1);
      if (fname.lastIndexOf('.') > 0) {
        final String ext = fname.substring(fname.lastIndexOf('.') + 1);
        if (['jpeg', 'jpg', 'png', 'bmp'].contains(ext)) {
          images.add(file as File);
        }
      }
    }
    return GalleryFiles(isArchive: false, files: images);
  } else {
    final bytes = await f.readAsBytes();
    final _archive = ZipDecoder().decodeBytes(bytes);
    return compute(getZipFileContentAsync, _archive);
  }
}

class GalleryReaderScreen extends StatelessWidget {
  static String routeName = '/gallery-reader';

  @override
  Widget build(BuildContext context) {
    final String path = ModalRoute.of(context)!.settings.arguments as String;
    final Future<GalleryFiles>? _future = loadArchive(path);
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                    systemOverlayStyle: SystemUiOverlayStyle.dark,
                    title: Text(''),
                  ),
                  body: Center(child: CircularProgressIndicator()),
                )
              : GalleryReader(gf: snapshot.data as GalleryFiles),
    );
  }
}

class GalleryReader extends StatefulWidget {
  final GalleryFiles gf;

  const GalleryReader({Key? key, required this.gf}) : super(key: key);
  @override
  _GalleryReaderState createState() => _GalleryReaderState();
}

class _GalleryReaderState extends State<GalleryReader> {
  PageController _pageController = PageController(initialPage: 0);
  late int _currentPage = 1;
  late int _totalFiles = widget.gf.files.length;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text('$_currentPage / $_totalFiles'),
        centerTitle: true,
      ),
      body: Container(
        //constraints: BoxConstraints.expand(),
        child: PageView(
            children: widget.gf.files
                .map(
                  (e) => InteractiveViewer(
                    scaleEnabled: true,
                    minScale: 0.5,
                    maxScale: 2,
                    panEnabled: false,
                    child: widget.gf.isArchive
                        ? Image.memory(e, fit: BoxFit.fitWidth)
                        : Image.file(e, fit: BoxFit.fitWidth),
                  ),
                )
                .toList(),
            controller: _pageController,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value + 1;
              });
            }),
      ),
    );
  }
}
