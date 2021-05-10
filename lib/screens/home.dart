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
  }

  @override
  Widget build(BuildContext context) {
    _futureTp = Provider.of<TagProvider>(context, listen: false).initialize();
    _futureGp =
        Provider.of<GalleryProvider>(context, listen: false).initialize();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
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
                    : buildHomeGalleryList(galleryProvider);
              },
            );
          } else {
            return buildHomeGalleryList(galleryProvider);
          }
        },
      ),
    );
  }

  Widget buildHomeGalleryList(GalleryProvider gp) {
    return ListView(
      children: [
        ListTile(
            title: Text("NOT TAGGED",
                style: TextStyle(fontWeight: FontWeight.bold))),
        ...gp.nonTagged.map((e) => GalleryItem(gallery: e)),
        Divider(),
        ListTile(
            title:
                Text("TAGGED", style: TextStyle(fontWeight: FontWeight.bold))),
        ...gp.galleries.map((e) => GalleryItem(gallery: e)),
        Divider(),
      ],
    );
  }
}
