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
