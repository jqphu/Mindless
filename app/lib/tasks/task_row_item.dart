import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';

import 'package:mindless/model/app_state.dart';
import 'package:mindless/model/task.dart';

final log = Logger('TaskRowItem');

class TaskRowItem extends StatefulWidget {
  /// The task to display.
  final Task task;

  /// Whether or not this task is the last item.
  ///
  /// This is used to ignore the bottom line separator if it is the last item.
  final bool isLastItem;

  TaskRowItem({required this.task, required this.isLastItem});

  @override
  _TaskRowItemState createState() {
    return _TaskRowItemState();
  }
}

class _TaskRowItemState extends State<TaskRowItem> {
  static const double rightOffset = 8;

  /// Whether or not we are editing this task.
  bool isEditing = false;

  /// Renaming task row controller.
  late TextEditingController _editingController;

  /// Listen to change of focus for editing controller.
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: widget.task.name);

    // Listener to close edit bar when focus changes.
    _focusNode.addListener(() {
      setState(() {
        if (!_focusNode.hasPrimaryFocus) {
          log.info('Focus has changed, no longer editing.');
          isEditing = false;
          // Reset the text name
          _editingController.text = widget.task.name;
        }
      });
    });
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(builder: (context, model, child) {
      var rowWidget;
      if (!isEditing) {
        rowWidget = InkWell(
          onTap: () {
            // Unfocus any editing.
            FocusScope.of(context).unfocus();
            model.setCurrentTask(widget.task);
          },
          child: Row(children: <Widget>[
            Expanded(
                child: Text(
              widget.task.name,
              style: TextStyle(
                color: Color.fromRGBO(0, 0, 0, 0.8),
                fontSize: 20,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
              ),
            )),
            MaterialButton(
              minWidth: 0,
              onPressed: () async {
                // Get the Box which is the row.
                var renderBox = context.findRenderObject() as RenderBox;

                // Position of the row itself.
                final position = renderBox.localToGlobal(Offset.zero);

                // Size of the row.
                final size = renderBox.size;
                await showMenu(
                    context: context,

                    // We use the distance from top to be the position of
                    // the row plus an offset. We use 3/4 of the height so
                    // it starts within the row (easy to tell which item
                    // we're modifying but near the bottom.)
                    //
                    // We use the full width as the size to push it to the
                    // right but use the edge inset from right to match the
                    // inset above.
                    position: RelativeRect.fromLTRB(size.width,
                        position.dy + (size.height * 3) / 4, rightOffset, 0),
                    items: [
                      PopupMenuItem<TaskRowOptionTypes>(
                          value: TaskRowOptionTypes.editName,
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 10),
                              Text('Edit name'),
                            ],
                          )),
                      PopupMenuItem<TaskRowOptionTypes>(
                          value: TaskRowOptionTypes.delete,
                          child: Row(
                            children: [
                              Icon(Icons.delete, semanticLabel: 'Delete'),
                              SizedBox(width: 10),
                              Text('Delete')
                            ],
                          )),
                    ]).then((taskRowOption) {
                  switch (taskRowOption) {
                    case TaskRowOptionTypes.delete:
                      log.info('Delete task');
                      model.deleteTask(widget.task);
                      break;
                    case TaskRowOptionTypes.editName:
                      log.info('Edit name');
                      isEditing = true;
                      break;
                    default:
                      log.info('Nothing selected.');
                  }
                });
              },
              child: Icon(
                Icons.more_vert,
                color: Colors.grey,
                semanticLabel: 'Options',
              ),
            ),
          ]),
        );
      } else {
        rowWidget = Row(children: <Widget>[
          Expanded(
              child: TextField(
            focusNode: _focusNode,
            autofocus: true,
            controller: _editingController,
            style: TextStyle(
              color: Color.fromRGBO(0, 0, 0, 0.8),
              fontSize: 20,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.normal,
            ),
          )),
          MaterialButton(
            minWidth: 0,
            onPressed: () async {
              log.info(
                  'Save button pressed for name edit with name "${_editingController.text}".');

              await model.renameTask(widget.task, _editingController.text);

              setState(() {
                isEditing = false;
              });
            },
            child: Icon(
              Icons.check_box,
              color: Colors.blue,
              semanticLabel: 'Save',
            ),
          ),
        ]);
      }

      final row = SafeArea(
          top: false,
          bottom: false,
          minimum: const EdgeInsets.only(
            left: 16,
            top: 8,
            bottom: 8,
            right: rightOffset,
          ),
          child: rowWidget);

      // Just return the row without the bottom line if it is the last item.
      if (widget.isLastItem) {
        return row;
      }

      return Column(
        children: <Widget>[
          row,
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            child: Container(height: 1, color: Color(0xFFD9D9D9)),
          ),
        ],
      );
    });
  }
}

// Type of operations on the task row.
enum TaskRowOptionTypes { delete, editName }
