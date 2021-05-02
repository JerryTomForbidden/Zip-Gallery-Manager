import 'package:exzip_manager/screens/settings.dart';
import 'package:exzip_manager/screens/tags.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(),
          Expanded(
              child: ListView(
            children: [
              buildDrawerItem(
                  context: context,
                  iconData: Icons.tag,
                  title: 'Tags',
                  routeName: TagsScreen.routeName),
              buildDrawerItem(
                  context: context,
                  iconData: Icons.settings,
                  title: 'Settings',
                  routeName: SettingsScreen.routeName),
              Divider(),
            ],
          ))
        ],
      ),
    );
  }

  Container buildDrawerItem({
    BuildContext? context,
    IconData? iconData,
    String? title,
    String? routeName,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: ListTile(
          leading: Icon(iconData),
          title: Text(title!),
          onTap: () {
            Navigator.of(context!).pushNamed(routeName!);
          },
        ),
      ),
    );
  }
}
