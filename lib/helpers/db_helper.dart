import 'dart:async';

import 'package:exzip_manager/models/gallery.dart';
import 'package:exzip_manager/models/tag.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DBHelper {
  /*static String _createString = """
    --
    --
    PRAGMA foreign_keys = off;
    BEGIN TRANSACTION;

    -- Table : Galleries
    CREATE TABLE Galleries (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT NOT NULL, path TEXT NOT NULL);

    -- Table : GalleriesTags
    CREATE TABLE GalleriesTags (galleryId INT REFERENCES Galleries (id) NOT NULL, tagId INT REFERENCES Tags (id) NOT NULL, UNIQUE (galleryId, tagId));

    -- Table : ParentTags
    CREATE TABLE ParentTags (name TEXT PRIMARY KEY ASC NOT NULL);

    -- Table : Tags
    CREATE TABLE Tags (parent TEXT REFERENCES ParentTags (name) NOT NULL, name TEXT NOT NULL, id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, UNIQUE (parent, id));

    COMMIT TRANSACTION;
    PRAGMA foreign_keys = on;

  """;*/

  static List<String> _createList = [
    "CREATE TABLE Galleries (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT NOT NULL, path TEXT NOT NULL);",
    "CREATE TABLE GalleriesTags (galleryId INT REFERENCES Galleries (id) NOT NULL, tagId INT REFERENCES Tags (id) NOT NULL, UNIQUE (galleryId, tagId));",
    "CREATE TABLE ParentTags (name TEXT PRIMARY KEY ASC NOT NULL, color TEXT NOT NULL);",
    "CREATE TABLE Tags (parent TEXT REFERENCES ParentTags (name) NOT NULL, name TEXT NOT NULL, id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, UNIQUE (parent, name));",
  ];

  static String _getAllTaggedGalleries = """
  SELECT Galleries.id as id, Galleries.name as name, Galleries.path as path, Tags.parent as parent, Tags.name as tagname, Tags.id as tId
  FROM Galleries
  INNER JOIN GalleriesTags on GalleriesTags.galleryId = Galleries.id
  INNER JOIN Tags on Tags.id = GalleriesTags.tagId
  ORDER BY Galleries.id ASC
  """;

  static String _getAllNonTaggedGalleries = """
  SELECT Galleries.id as id, Galleries.name as name, Galleries.path as path
  FROM Galleries
  LEFT JOIN GalleriesTags on GalleriesTags.galleryId = Galleries.id
  WHERE GalleriesTags.galleryId IS NULL
  ORDER BY Galleries.id ASC
  """;

  static String _getAllTags = """
  SELECT id, parent,
       name
  FROM Tags
  ORDER BY parent ASC
  """;

  static String _getAllParentTags = """
  SELECT name as parent, color
  FROM ParentTags
  """;

  static Future<sql.Database> initialize() async {
    try {
      final dbPath = await sql.getDatabasesPath();
      final db = await sql.openDatabase(
        path.join(dbPath, 'exzip.db'),
        onCreate: (db, version) async {
          for (int i = 0; i < _createList.length; i++) {
            await db.execute(_createList[i]);
          }
          return;
        },
        version: 1,
      );
      return db;
    } catch (e) {
      print('error ${e.toString()}');
      return throw (e as Error);
    }
  }

  static Future<int> insert(String table, Map<String, Object> data) async {
    late sql.Database sqldb;
    try {
      sqldb = await initialize();
      final id = await sqldb.insert(table, data,
          conflictAlgorithm: sql.ConflictAlgorithm.ignore);
      await sqldb.close();
      return id;
    } catch (e) {
      if (sqldb != null) {
        await sqldb.close();
      }
      return -1;
    }
  }

  // un problème avec cett fonction
  static Future<List<Gallery>> getAllTaggedGalleries() async {
    final sqldb = await initialize();
    // Get all galleries that are tagged
    final g = await sqldb.rawQuery(_getAllTaggedGalleries);
    List<Gallery> res = [];
    List<Tag> currTag = [];
    int currentId = -1;
    for (int i = 0; i < g.length; i++) {
      if (currentId != g[i]['id'] as int && currentId != -1) {
        currentId = g[i]['id'] as int;
        res.add(Gallery(
            id: g[i - 1]['id'] as int,
            name: g[i - 1]['name'] as String,
            path: g[i - 1]['path'] as String,
            tags: currTag));

        currTag = [];
        currTag.add(Tag(
            id: g[i]['tId'] as int,
            name: g[i]['tagname'] as String,
            parent: g[i]['parent'] as String));
      } else if (currentId == -1) {
        currentId = g[i]['id'] as int;
        currTag.add(Tag(
            id: g[i]['tId'] as int,
            name: g[i]['tagname'] as String,
            parent: g[i]['parent'] as String));
      } else {
        currTag.add(Tag(
            id: g[i]['tId'] as int,
            name: g[i]['tagname'] as String,
            parent: g[i]['parent'] as String));
      }
    }
    if (g.length > 1) {
      res.add(Gallery(
          id: g[g.length - 1]['id'] as int,
          name: g[g.length - 1]['name'] as String,
          path: g[g.length - 1]['path'] as String,
          tags: currTag));
    }
    await sqldb.close();
    return res;
  }

  static Future<List<Gallery>> getAllNonTaggedGalleries() async {
    final sqldb = await initialize();
    // Get all galleries that are tagged
    List<Gallery> res = [];
    final g = await sqldb.rawQuery(_getAllNonTaggedGalleries);
    g.forEach((element) {
      res.add(Gallery(
          id: element['id'] as int,
          name: element['name'] as String,
          path: element['path'] as String,
          tags: []));
    });
    await sqldb.close();
    return res;
  }

  static Future<List<Tag>> getAlltags() async {
    List<Tag> res = [];
    try {
      final sqldb = await initialize();

      final tags = await sqldb.rawQuery(_getAllTags);

      for (int i = 0; i < tags.length; i++) {
        res.add(Tag(
            id: tags[i]['id'] as int,
            parent: tags[i]['parent'] as String,
            name: tags[i]['name'] as String));
      }
      return res;
    } catch (e) {
      return res;
    }
  }

  static Future<Tag?> getTag(int tagId) async {
    String _getTag = """
                      SELECT parent, name, id
                      FROM Tags
                      WHERE Tags.id = $tagId
                      """;
    final sqldb = await initialize();
    final tags = await sqldb.rawQuery(_getTag);
    if (tags.first.isNotEmpty) {
      return Tag(
          id: tags.first['id'] as int,
          name: tags.first['name'] as String,
          parent: tags.first['parent'] as String);
    } else
      return null;
  }
}
