import 'package:exzip_manager/models/tag.dart';
import 'package:exzip_manager/providers/tag_provider.dart';
import 'package:exzip_manager/screens/tagdetail.dart';
import 'package:exzip_manager/widgets/DropDownField.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagsScreen extends StatefulWidget {
  static String routeName = '/tags';

  @override
  _TagsScreenState createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _dropDownValue;
  TextEditingController? _tagNameController = TextEditingController();
  TextEditingController? _tagParentController = TextEditingController();

  void _addNewTag(String parent, String name) {}

  @override
  Widget build(BuildContext context) {
    print('building tagss...');
    TagProvider tg = Provider.of<TagProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text('Tags'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    height: 400,
                    child: Column(
                      children: [
                        Text('Add a new tag'),
                        Consumer<TagProvider>(
                            builder: (context, tgp, child) => Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      DropDownField(
                                          controller: _tagParentController,
                                          value: _dropDownValue,
                                          required: true,
                                          strict: false,
                                          labelText:
                                              'Add a new parent tag or select one..',
                                          items: tgp.parents,
                                          setter: (dynamic newValue) {
                                            _dropDownValue = newValue;
                                          }),
                                      TextFormField(
                                        // The validator receives the text that the user has entered.
                                        controller: _tagNameController,
                                        decoration: InputDecoration(
                                          labelText: 'Tag name',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Validate returns true if the form is valid, or false otherwise.
                                          if (_formKey.currentState!
                                              .validate()) {
                                            // If the form is valid, display a snackbar. In the real world,
                                            // you'd often call a server or save the information in a database.
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'Processing Data')));
                                            tgp.insert(
                                                _tagParentController!
                                                    .value.text,
                                                _tagNameController!.value.text);

                                            _tagNameController =
                                                TextEditingController();
                                            _tagParentController =
                                                TextEditingController();
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: Text('Submit'),
                                      ),
                                    ],
                                  ),
                                )),
                      ],
                    )),
              ),
            );
          },
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final String parent = tg.parents[index];
          final List<String> childs = tg.getChildrenOfParent(parent);

          return ListTile(
            title: Text(parent),
            subtitle: Text('${childs.length} child tag(s)'),
            onTap: () => Navigator.of(context)
                .pushNamed(TagDetailScreen.routeName, arguments: parent),
          );
        },
        itemCount: tg.parents.length,
      ),
    );
  }
}