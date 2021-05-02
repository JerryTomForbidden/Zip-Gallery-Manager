import 'dart:async';

import 'package:exzip_manager/helpers/db_helper.dart';
import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  test('Should initialize a valid database', () async {
    sql.Database db = await DBHelper.initialize();
    expect(db.isOpen, true);

    await db.close();
  });
}
