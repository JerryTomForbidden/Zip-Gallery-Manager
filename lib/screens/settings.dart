import 'dart:io';

import 'package:exzip_manager/providers/pref_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static String routeName = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void>? _futurePref;
  bool _scanFolders = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _futurePref =
          Provider.of<PrefProvider>(context, listen: false).loadPrefs();
    });
  }

  Future<String?> _selectFolder() async {
    String? gpath = await FilePicker.platform.getDirectoryPath();
    return gpath!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Consumer<PrefProvider>(
        builder: (context, pref, child) {
          return Column(
            children: [
              FutureBuilder(
                future: _futurePref,
                builder: (context, snapshot) {
                  return snapshot.connectionState == ConnectionState.waiting
                      ? ListTile(
                          title: Text('Select your path'),
                          subtitle: Text('loading...'),
                          onTap: () {},
                        )
                      : ListTile(
                          title: Text('Select your path'),
                          subtitle: Text(
                            pref.path.isEmpty
                                ? '<no path selected>'
                                : pref.path,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () async {
                            final p = await _selectFolder();
                            await pref.setPath(p!);
                          },
                        );
                },
              ),
              SwitchListTile(
                title: Text('Scan folders as gallery'),
                subtitle: Text(
                  'Only direct pictures will be scanned. No subfolder scan.',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                value: pref.scanFolders,
                onChanged: (value) {
                  setState(() {
                    _scanFolders = value;
                    pref.setScanFolders(value);
                  });
                },
              ),
              SwitchListTile(
                title: Text('Only allow archive files'),
                subtitle: Text('(zip, rar, *.gz, ...)'),
                value: pref.onlyArchiveFiles,
                onChanged: null,
              )
            ],
          );
        },
      ),
    );
  }
}
