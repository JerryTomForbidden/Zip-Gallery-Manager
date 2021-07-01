import 'dart:io';

import 'package:exzip_manager/helpers/db_helper.dart';
import 'package:exzip_manager/models/gallery.dart';
import 'package:exzip_manager/models/tag.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

class GalleryProvider with ChangeNotifier {
  static String dbname = 'exzip.db';
  bool didLoad = false;
  bool initialized = false;
  List<Gallery> _galleries = [];
  List<Gallery> _nonTagged = [];

  final bool pathHaveChanged;
  final String path;
  final bool scanFolders;
  final bool onlyArchiveFiles;

  GalleryProvider({
    required this.path,
    required this.pathHaveChanged,
    required this.scanFolders,
    required this.onlyArchiveFiles,
  });

  set galleries(List<Gallery> g) {
    _galleries = g;
  }

  set nonTagged(List<Gallery> nt) {
    _nonTagged = nt;
  }

  List<Gallery> get galleries {
    return [..._galleries];
  }

  List<Gallery> get nonTagged {
    return [..._nonTagged];
  }

  List<Gallery> getGalleriesWithTag(String parent, String childName) {
    List<Gallery> res = [];
    for (int i = 0; i < this.galleries.length; i++) {
      final gallery = this.galleries[i];
      if (gallery.tags.indexWhere((element) =>
              element.parent == parent && element.name == childName) !=
          -1) {
        res.add(gallery);
      }
    }
    return res;
  }

  // maybe do this when user change the path ???
  Future<void> cleanDatabase() async {}

  Future<int> initialize() async {
    List<Gallery> _newGalleries = [];
    List<FileSystemEntity> res = [];
    if (path.isEmpty) {
      return -1;
    }
    try {
      print('initializing...');
      final tg = await DBHelper.getAllTaggedGalleries();
      final ntg = await DBHelper.getAllNonTaggedGalleries();

      await for (var file
          in Directory(path).list(recursive: false, followLinks: false)) {
        final String fname =
            file.path.substring(file.path.lastIndexOf('/') + 1);

        bool proceed = false;
        //check si on a une extension et qu'on est pas un fichier/dossier caché
        if (fname.lastIndexOf('.') > 0) {
          final String ext = fname.substring(fname.lastIndexOf('.') + 1);
          //TODO regexp cause we need to ensure that we're at end of fname
          if (onlyArchiveFiles) {
            if (['zip', 'rar', 'gz'].contains(ext))
              proceed = true;
            else
              proceed = false;
          } else
            proceed = true;
        } else {
          //si pas d'ext probablement un dossier ou un fichier sans extension (peut etre une archive)
          //dart:io pour determiner exactement
          if (scanFolders) proceed = true;
        }

        if (!proceed) continue;
        // present dans la bdd
        if (tg.firstWhereOrNull((g) {
                  return g.name == fname;
                }) !=
                null ||
            ntg.firstWhereOrNull((g) {
                  return g.name == fname;
                }) !=
                null) {
        } else {
          // non present dans la BDD

          int id = await DBHelper.insert('Galleries', {
            'name': fname,
            'path': file.path,
          });
          _newGalleries
              .add(Gallery(id: id, name: fname, path: file.path, tags: []));
        }
      }
      _galleries = [...tg];
      _nonTagged = [...ntg, ..._newGalleries];
      initialized = true;
      //pathHaveChanged = false;
      notifyListeners();
      return res.length;
    } catch (e) {
      print('error ${e.toString()}');
      return -1;
    }
  }

  Future<int> tagGallery(int galleryId, int tagId) async {
    try {
      //TODO: Check first if gallery exist in provider!
      //TODO: which OP should we do first (DataBase? ProviderClass?)
      //TODO: Provider first (check if gallery exist on tagged or non-tagged, then DataBase, and add to tagged)
      int id = await DBHelper.insert("GalleriesTags", {
        "galleryId": galleryId,
        "tagId": tagId,
      });

      //success
      if (id > 0) {
        final Tag tag = (await DBHelper.getTag(tagId))!;
        // if it is inside tagged array, we add the tag to its list
        if (_galleries
                .where((element) => element.id == galleryId)
                .firstOrNull !=
            null) {
          _galleries
              .where((element) => element.id == galleryId)
              .first
              .tags
              .add(tag);
          notifyListeners();
        } else {
          Gallery? tmp = _nonTagged
              .where((element) => element.id == galleryId)
              .firstOrNull;
          if (tmp != null) {
            _nonTagged.removeWhere((element) => element.id == galleryId);
            tmp.tags.add(tag);
            _galleries.add(tmp);
            notifyListeners();
          } else {
            print('error: trying to tagged a gallery that exist nowhere');
            print('error: please see code and revert the DB operation');
            return -1;
          }
        }
        return id;
      } else
        return -1;
    } catch (e) {
      return -1;
    }
  }
}
