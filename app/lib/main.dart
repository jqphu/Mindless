import 'package:flutter/material.dart';

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

class HabitsState extends State<Habits> {
  // TODO: Retrieve habits from database.
  final _habits = <String>["Wakeup early", "Meditate", "Exercise"];
  final _completed = Set<String>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  Widget _buildSuggestions() {
    return ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _habits.length,
        itemBuilder: (context, i) {
          return _buildRow(_habits[i]);
        },
        separatorBuilder: (context, i) {
          return Divider();
        });
  }

  Widget _buildRow(String habit) {
    final isCompleted = _completed.contains(habit);
    return ListTile(
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
            } else {
              _completed.add(habit);
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
