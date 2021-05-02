/*FormField<String>(
                                  builder: (FormFieldState<String> state) {
                                    return InputDecorator(
                                      decoration: InputDecoration(
                                        labelStyle: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                        errorStyle: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 16.0),
                                        hintText: 'parent',
                                        labelText: 'Or select one here',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                      ),
                                      isEmpty: _dropDownValue == '',
                                      child: DropdownButton<String>(
                                        value: _dropDownValue,
                                        icon: const Icon(Icons.arrow_downward),
                                        iconSize: 8,
                                        elevation: 16,
                                        style: const TextStyle(
                                            color: Colors.deepPurple),
                                        underline: Container(
                                          height: 2,
                                          color: Colors.deepPurpleAccent,
                                        ),
                                        onChanged: (String? newValue) {
                                          print('changeed $newValue');
                                          setState(() {
                                            _dropDownValue = newValue!;
                                            state.didChange(newValue);
                                          });
                                        },
                                        items: ["ok", "ko"]
                                            .map<DropdownMenuItem<String>>(
                                                (e) => DropdownMenuItem<String>(
                                                      value: e,
                                                      child: Text(e),
                                                    ))
                                            .toList(),
                                      ),
                                    );
                                  },
                                ),*/
