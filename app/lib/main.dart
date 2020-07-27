import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' as foundation;
import 'package:logger/logger.dart';
import 'dart:convert';

var logger = Logger(printer: PrettyPrinter());

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      home: Habits(),
    );
  }
}

void habitHttpRequest(String habit, bool markHabit) async {
  var endpoint;
  if (foundation.kReleaseMode) {
    endpoint = "https://jqphu.dev";
  } else {
    // TODO: Different port depending on Android vs Web
    endpoint = "http://10.0.2.2";
  }

  final habitEndpoint = endpoint + "/mindless/api/habit";
  logger.d("Making http request to: " +
      habitEndpoint +
      " with habit string " +
      habit +
      " and should_mark " +
      markHabit.toString());

  final response = await http.post(habitEndpoint,
      body: jsonEncode({
        "name": habit,
        "should_mark": markHabit,
      }));

  final body = jsonDecode(response.body);

  logger.d(
      "Response from request was:  status: ${response.statusCode}, body: " +
          body.toString());
}

class HabitsState extends State<Habits> {
  // TODO: Retrieve habits from database.
  final _habits = <String>["WakeupEarly", "Meditate", "Exercise"];
  final _completed = Set<String>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  Widget _buildSuggestions(BuildContext context) {
    return ReorderableListView(
        children: List.generate(_habits.length, (index) {
          return _buildRow(context, index);
        }),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }

            final String item = _habits.removeAt(oldIndex);
            _habits.insert(newIndex, item);
          });
        });
  }

  Widget _buildRow(BuildContext context, int index) {
    String habit = _habits[index];
    final isCompleted = _completed.contains(habit);
    return Dismissible(
        // Duplicate the key since we don't care if this is a dismissable widget or a list tile wideget.
        key: ValueKey(habit),
        onDismissed: (direction) {
          // Remove item from the list
          setState(() {
            _habits.removeAt(index);
          });

          // Show a snackbar. This snackbar could also contain "Undo" actions.
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text("$habit dismissed")));
        },
        background: Container(color: Colors.red),
        child: ListTile(
            key: ValueKey(habit),
            title: Text(
              habit,
              style: _biggerFont,
            ),
            trailing: Icon(
              isCompleted ? Icons.done : Icons.done_outline,
              color: isCompleted ? Colors.red : null,
            ),
            onTap: () {
              setState(() {
                if (isCompleted) {
                  _completed.remove(habit);
                  habitHttpRequest(habit, false);
                } else {
                  _completed.add(habit);
                  // TODO: Don't ignore the result.
                  habitHttpRequest(habit, true);
                }
              });
            }));
  }

  // Add a habit to the list and update the state.
  void _addHabitItem(String habit_name) {
    logger.d("Add habit with name: ${habit_name}");
    // Only add the task if the user actually entered something
    if (habit_name.length > 0) {
      setState(() => _habits.insert(_habits.length, habit_name));
    }
  }

  // Push the add habit button. This will bring up a navigation menu and allow the user to add a habit.
  void _pushAddHabitScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
        // MaterialPageRoute will automatically animate the screen entry, as well
        // as adding a back button to close it
        new MaterialPageRoute(builder: (context) {
      return new Scaffold(
          appBar: new AppBar(title: new Text('Add a new habit')),
          body: new TextField(
            autofocus: true,
            onSubmitted: (val) {
              _addHabitItem(val);
              Navigator.pop(context); // Close the add todo screen
            },
            decoration: new InputDecoration(
                hintText: 'Enter something to do...',
                contentPadding: const EdgeInsets.all(16.0)),
          ));
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mindless')),
      body: Builder(builder: (BuildContext context) {
        return _buildSuggestions(context);
      }),
      floatingActionButton: new FloatingActionButton(
          onPressed: _pushAddHabitScreen,
          tooltip: 'Add a habit',
          child: new Icon(Icons.add)),
    );
  }
}

class Habits extends StatefulWidget {
  @override
  HabitsState createState() => new HabitsState();
}
