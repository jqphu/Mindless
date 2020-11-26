import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:mindless/model/app_state.dart';
import 'package:pedantic/pedantic.dart';

import 'task_row_item.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  SearchBar searchBar;

  // The optional add task.
  AddTask addTask;

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        centerTitle: true,
        title: Text('Search'),
        actions: [searchBar.getSearchAction(context)]);
  }

  void _resetSearch() {
    setState(() {
      addTask = null;
    });
  }

  void _onChanged(String newValue) {
    if (newValue == '') {
      _resetSearch();
      return;
    }

    setState(() {
      addTask = AddTask(taskName: newValue);
    });
  }

  _SearchPageState() {
    searchBar = SearchBar(
      inBar: false,
      closeOnSubmit: false,
      clearOnSubmit: false,
      hintText: 'Enter your task!',
      setState: setState,
      onClosed: _resetSearch,
      onCleared: _resetSearch,
      onSubmitted: (String submission) {
        // Do nothing :) - should handle this with onChanged and search on the fly
      },
      onChanged: _onChanged,
      buildDefaultAppBar: buildAppBar,
    );

    // Start with searching true.
    searchBar.isSearching.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: searchBar.build(context),
        body: SafeArea(
            child: Column(children: <Widget>[
          SizedBox(height: 10),
          if (addTask != null) addTask,
          if (addTask != null) Divider(color: Colors.grey),
          Center(child: Text('hello')),
        ])));
  }
}

class AddTask extends StatelessWidget {
  final String taskName;

  AddTask({@required this.taskName}) : assert(taskName != null);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        minimum: const EdgeInsets.only(
          left: 16,
          top: 8,
          bottom: 8,
          right: 8,
        ),
        child: Container(
            // TODO: Style this so it stands out.
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    taskName,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  )),
                  MaterialButton(
                    minWidth: 0,
                    onPressed: () async {
                      var provider =
                          Provider.of<AppStateModel>(context, listen: false);
                      var task = await provider.addTask(taskName);
                      provider.currentTask = task;

                      // TODO: Spinning pending wheel :)

                      // Created, back to home. Don't care when we finish with home, we are done with this route.
                      await Navigator.of(context).pushReplacementNamed('/home');
                    },
                    child: Icon(
                      Icons.add_box,
                      size: 30,
                      color: Colors.grey,
                      semanticLabel: 'Create',
                    ),
                  ),
                ],
              ),
            ])));
  }
}
