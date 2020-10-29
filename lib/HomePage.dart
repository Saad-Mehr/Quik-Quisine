import 'package:flutter/material.dart';
import 'package:quikquisine490/calendar.dart';
import 'package:quikquisine490/main.dart';
import 'recipes.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Main Menu',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        appBar: AppBar(
            title: Text('Main Menu'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            )),
        body: BodyLayout(),
      ),
    );
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _myListView(context);
  }
}

// replace this function with the code in the examples
Widget _myListView(BuildContext context) {
  return ListView(
    children: <Widget>[
      ListTile(
        title: Text('Recipes'),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => recipePage()),
          );
        },
      ),
      ListTile(
        title: Text('Meal Planner'),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          );
        },
      ),
      ListTile(
        title: Text('Profile'),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          print('Moon');
        },
      ),
      ListTile(
        title: Text('Logout'),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Myapp()),
          );
        },
      ),
    ],
  );
}
