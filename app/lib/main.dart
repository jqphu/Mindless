import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' as foundation;
import 'package:logger/logger.dart';

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

Future<http.Response> habitHttpRequest(String habit, bool markHabit) {
  var endpoint;
  if (foundation.kReleaseMode) {
    endpoint = "https://jqphu.dev";
  } else {
    // TODO: Different port depending on Android vs Web
    endpoint = "http://10.0.2.2";
  }
  var habitAction;
  if (markHabit) {
    habitAction = "mark";
  } else {
    habitAction = "unmark";
  }

  final habitEndpoint = endpoint + "/mindless/api/habit/" + habitAction;
  final fullRequestPath = habitEndpoint + "/" + habit;
  logger.d("Making http request to: " + fullRequestPath);
  return http.get(fullRequestPath);
}

class HabitsState extends State<Habits> {
  // TODO: Retrieve habits from database.
  final _habits = <String>["WakeupEarly", "Meditate", "Exercise"];
  final _completed = Set<String>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  Widget _buildSuggestions() {
    return ReorderableListView(
        children: List.generate(_habits.length, (index) {
          return _buildRow(_habits[index]);
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

  Widget _buildRow(String habit) {
    final isCompleted = _completed.contains(habit);
    return ListTile(
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
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mindless')),
      body: _buildSuggestions(),
    );
  }
}

class Habits extends StatefulWidget {
  @override
  HabitsState createState() => new HabitsState();
}
