import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appbar
      appBar: AppBar(
        title: Text('We Chat'),
        leading: Icon(
          CupertinoIcons.home,
        ),
        //search & more vertical dots
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))
        ],
      ),

      //add floating action button
      floatingActionButton: Icon(
        Icons.add_comment_rounded,
        color: Colors.blue,
      ),
    );
  }
}
