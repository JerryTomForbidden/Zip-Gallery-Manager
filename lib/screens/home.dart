import 'package:exzip_manager/models/gallery.dart';
import 'package:exzip_manager/models/tag.dart';
import 'package:exzip_manager/providers/gallery_provider.dart';
import 'package:exzip_manager/providers/pref_provider.dart';
import 'package:exzip_manager/providers/tag_provider.dart';
import 'package:exzip_manager/widgets/GalleryItem.dart';
import 'package:exzip_manager/widgets/mydrawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<int>? _futureGp;
  Future<void>? _futureTp;
  Future<void>? _futureProviders;

  bool _searchMode = false;
  List<Tag> _searchTags = [];
  List<String> _searchKeys = [];
  TextEditingController _searchController = TextEditingController();

  void _handleSearchTextChange() {
    final text = _searchController.text;
    if (_searchMode) {
      RegExp splitSpaceNoQuotes = RegExp(
        "\\s(?=(?:[^'\"`]*(['\"`])[^'\"`]*\\1)*[^'\"`]*\$)",
        //"[^\s\"\']+|\"([^\"]*)\"|\'([^\']*)\'",
        multiLine: true,
      );
      // need closing quotes or regexp will be in a difficult state
      if ((text.indexOf('"') >= 0 && '\"'.allMatches(text).length % 2 == 0) ||
          (text.indexOf("'") >= 0 && '\''.allMatches(text).length % 2 == 0) ||
          ((text.indexOf('"') < 0) && (text.indexOf("'") < 0))) {
        _searchKeys = _searchController.text
            .replaceAll(splitSpaceNoQuotes, '\n')
            .split('\n');
        List<String> tagKeys =
            _searchKeys.where((element) => element.indexOf(':') > 0).toList();
        _searchKeys.removeWhere(
            (element) => element.indexOf(':') > 0 || element.length <= 3);

        _searchTags.clear();
        tagKeys.forEach((element) {
          final List<String> splits = element.split(':');
          //length has to be 2 (parentTag:childtag)
          //remove quotes from both
          if (splits.length == 2) {
            final parent =
                splits[0].replaceAll("'", "").replaceAll('"', '').trim();
            final child =
                splits[1].replaceAll("'", "").replaceAll('"', '').trim();
            //print('tag in search => $parent:$child');
            _searchTags.add(Tag(id: -1, name: child, parent: parent));
          }
        });
        _searchKeys.forEach((element) {
          element = element.replaceAll("'", "").replaceAll('"', '').trim();
        });
      } else {
        //difficult state
        //maybe show controller error
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /*WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      print('defining futures (home screen)');

      _futureTp = Provider.of<TagProvider>(context, listen: false).initialize();
      _futureGp =
          Provider.of<GalleryProvider>(context, listen: false).initialize();
    });*/
    _searchController.addListener(_handleSearchTextChange);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    return Future.delayed(Duration(seconds: 1), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _futureTp = Provider.of<TagProvider>(context, listen: false).initialize();
    _futureGp =
        Provider.of<GalleryProvider>(context, listen: false).initialize();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !_searchMode,
        title: _searchMode
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 45.0),
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(fillColor: Colors.white),
                ),
              )
            : Text('Home'),
        actions: [
          IconButton(
            icon: Icon(
                _searchMode ? Icons.close_outlined : Icons.search_outlined),
            onPressed: () {
              setState(() {
                _searchMode = !_searchMode;
                if (!_searchMode) {
                  _searchController.clear();
                  _searchTags.clear();
                  _searchKeys.clear();
                }
              });
            },
          )
        ],
      ),
      drawer: MyDrawer(),
      body: Consumer3<GalleryProvider, TagProvider, PrefProvider>(
        builder: (context, galleryProvider, tagProvider, prefProvider, child) {
          if (galleryProvider.pathHaveChanged) {
            return FutureBuilder(
              future: Future.wait([_futureTp!, _futureGp!]),
              builder: (context, snapshot) {
                return snapshot.connectionState == ConnectionState.waiting
                    ? Center(
                        child: Text("LOADING..."),
                      )
                    : buildHomeGalleryList(
                        galleryProvider, _refresh, _searchMode);
              },
            );
          } else {
            return buildHomeGalleryList(galleryProvider, _refresh, _searchMode);
          }
        },
      ),
    );
  }

  Widget buildHomeGalleryList(
      GalleryProvider gp, Function _refresh, bool searchMode) {
    return RefreshIndicator(
      onRefresh: () => _refresh(),
      child: searchMode
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                ListTile(
                  title: Text(
                    "RESULTS :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...filterSearchResult(_searchTags, _searchKeys,
                    [...gp.galleries, ...gp.nonTagged])
              ],
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                ListTile(
                    title: Text("NOT TAGGED",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                ...gp.nonTagged.map((e) => GalleryItem(gallery: e)),
                Divider(),
                ListTile(
                    title: Text("TAGGED",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                ...gp.galleries.map((e) => GalleryItem(gallery: e)),
                Divider(),
              ],
            ),
    );
  }
}

List<GalleryItem> filterSearchResult(
    List<Tag> _searchTags, List<String> _searchKeys, List<Gallery> galleries) {
  List<GalleryItem> searchResult = [];
  galleries.forEach((element) {
    bool isValid = true;
    for (int i = 0; i < _searchTags.length; i++) {
      bool tagFound = false;
      for (int j = 0; j < element.tags.length; j++) {
        if (element.tags[j].name == _searchTags[i].name &&
            element.tags[j].parent == _searchTags[i].parent) {
          tagFound = true;
        }
      }

      if (!tagFound) {
        isValid = false;
        break;
      } else
        continue;
    }
    if (isValid) {
      if (_searchKeys.length > 0) {
        RegExp rx = RegExp(
            "(" + _searchKeys.join('|').trim().toLowerCase() + ")",
            multiLine: true);
        if (rx.allMatches(element.name.toLowerCase()).length > 0) {
          final posToHighlights = rx
              .allMatches(element.name.toLowerCase())
              .map((e) => [e.start, e.end])
              .toList();

          int lastPos = 0;
          List<TextSpan> formattedName = [];
          //Highlighting the name
          for (int i = 0; i < posToHighlights.length; i++) {
            final p = posToHighlights[i];
            if (p[0] == 0) {
              formattedName.add(TextSpan(
                text: element.name.substring(p[0], p[1]),
                style: TextStyle(backgroundColor: Colors.yellow),
              ));
            } else {
              formattedName
                  .add(TextSpan(text: element.name.substring(lastPos, p[0])));
              formattedName.add(TextSpan(
                text: element.name.substring(p[0], p[1]),
                style: TextStyle(backgroundColor: Colors.yellow),
              ));
            }
            lastPos = p[1];

            if (i == posToHighlights.length - 1 &&
                p[1] != element.name.length) {
              formattedName.add(TextSpan(
                  text: element.name.substring(lastPos, element.name.length)));
            }
          }
          searchResult.add(GalleryItem(
            gallery: element,
            highlightName: formattedName,
          ));
        }
      } else if (_searchTags.length > 0) {
        searchResult.add(GalleryItem(gallery: element));
      }
    }
  });
  return searchResult;
}
