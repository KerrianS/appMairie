import 'package:flutter/material.dart';
import 'package:mairie_ipad/view/home.dart';

import 'package:mairie_ipad/view/project/project_list.dart';
import 'package:mairie_ipad/view/project/project_photo.dart';
import 'package:mairie_ipad/view/project/project_task.dart';

import 'package:mairie_ipad/view/subproject/subproject_list.dart';

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
        '/projectPhoto': (context) => ProjectListScreen(),
        '/projectTask': (context) => ProjectTaskScreen(),
        '/subprojects': (context) => SubProjectListScreen(),
      },
    );
  }
}
