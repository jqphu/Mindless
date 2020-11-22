import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mindless/model/app_state.dart';

class TaskCurrent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, model, child) {
        if (model.currentTask == null) {
          return SizedBox.shrink();
        }

        return Container(
            height: MediaQuery.of(context).size.height / 15,
            child: Center(
                child: Text(model.currentTask.name,
                    style: TextStyle(fontSize: 30))));
      },
    );
  }
}
