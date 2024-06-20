import 'package:flutter/material.dart';
import 'package:mairie_ipad/view/project_list.dart';
import 'package:mairie_ipad/view/project_task.dart';

import 'package:mairie_ipad/view/subproject/subproject_list.dart';
import 'package:mairie_ipad/view/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mairie d\'Alès',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      routes: {
        '/': (context) => HomeScreen(),
        '/projects': (context) => ProjectListScreen(),
        '/projectTask': (context) => ProjectTaskScreen(),
        '/subprojects': (context) => SubProjectListScreen(),
      },
    );
  }
}
