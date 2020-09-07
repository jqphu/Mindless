// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'model/user.dart';

import 'package:Shrine/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // mandatory when awaiting on main

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('name');
  final id = prefs.getInt('id');
  final username = prefs.getString('username');
  final user = User(username, name, id);
  final taskName = prefs.getString('cur_task_name');
  var startedTime;
  if (taskName != null) {
    startedTime = DateTime.parse(prefs.getString('cur_task_start_time'));
  }

  runApp(ShrineApp(name == null ? null : user,
      taskName == null ? [null, null] : [taskName, startedTime]));
}
