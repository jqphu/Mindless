import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'mindless.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('[${record.level.name}][${record.loggerName}]: ${record.message}');
  });

  runApp(Mindless());
}
