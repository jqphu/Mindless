import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:mindless/model/app_state.dart';
import 'package:mindless/model/task.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  late SearchBar searchBar;

  // The optional add task.
  AddTask? addTask;

  List<Task> filteredTasks = [];

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
    var provider = Provider.of<AppStateModel>(context, listen: false);
    filteredTasks = provider.filterTasks(newValue);

    if (newValue == '') {
      _resetSearch();
      return;
    }

    setState(() {
      if (!provider.existsTask(newValue)) {
        addTask = AddTask(taskName: newValue);
      } else {
        addTask = null;
      }
    });
  }

  /// Get the widgets corresponding to the AddTask section.
  List<Widget> _getAddTaskWidgets() {
    return [
      SizedBox(height: 10),
      Text('Create Task', textAlign: TextAlign.left),
      addTask!,
      Divider(color: Colors.grey, thickness: 2.0),
    ];
  }

  List<Widget> _getStartTaskWidgets() {
    return [
      SizedBox(height: 10),
      // TODO: Spinning indicator when loading tasks.
      Text('Start Task'),
      Expanded(
          child: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) => StartTask(task: filteredTasks[index]),
      ))
    ];
  }

  // TODO: Trigger a search immediately.
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
          if (addTask != null) ..._getAddTaskWidgets(),
          if (filteredTasks.isNotEmpty) ..._getStartTaskWidgets(),
        ])));
  }
}

class AddTask extends StatelessWidget {
  final String taskName;

  AddTask({required this.taskName});

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
        child: InkWell(
            onTap: () async {
              var provider = Provider.of<AppStateModel>(context, listen: false);
              await provider.addTask(taskName);

              // TODO: Spinning pending wheel :)

              // Created, back to home. Don't care when we finish with home, we are done with this route.
              await Navigator.of(context).pushReplacementNamed('/home');
            },

            // TODO: Style this so it stands out.
            child: Row(children: <Widget>[
              Expanded(
                  child: Text(
                taskName,
                style: TextStyle(
                  fontSize: 20,
                ),
              )),
              Icon(
                Icons.add_box,
                size: 30,
                color: Colors.grey,
                semanticLabel: 'Create',
              ),
            ])));
  }
}

class StartTask extends StatelessWidget {
  final Task task;

  StartTask({required this.task});

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      SafeArea(
          top: false,
          bottom: false,
          minimum: const EdgeInsets.only(
            left: 16,
            top: 8,
            bottom: 8,
            right: 8,
          ),
          child: InkWell(
              onTap: () async {
                var provider =
                    Provider.of<AppStateModel>(context, listen: false);
                provider.setCurrentTask(task);

                // TODO: Spinning pending wheel :)

                // Created, back to home. Don't care when we finish with home, we are done with this route.
                await Navigator.of(context).pushReplacementNamed('/home');
              },

              // TODO: Style this so it stands out.
              child: Row(children: <Widget>[
                Expanded(
                    child: Text(
                  task.name,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                )),
              ]))),
      Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
        ),
        child: Container(height: 1, color: Color(0xFFD9D9D9)),
      )
    ]);
  }
}
