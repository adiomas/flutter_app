import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'comment_list.dart';

import 'bloc/comment_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommentBloc>(
      create: (context) => CommentBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sqflite Tutorial',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
        ),
        home: CommentList(),
      ),
    );
  }
}
