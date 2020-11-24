import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:quikquisine490/user.dart';
//test email test@gmail.com
//test token KV7aSwEfxti-X2Mr6LxJ

Map<String, String> get headers => {
  "X-User-Email": UserList[0],
  "X-User-Token": UserList[2],
};

Future<List> getData() async{
  String url = 'https://quik-quisine.herokuapp.com/api/v1/users/users/' + UserList[3].toString();
  http.Response response = await http.get(url,headers: headers);
  var parsedJson = jsonDecode(response.body);
  var data = parsedJson['data'];
  List temp = [data['email'],data['username'],data['first_name'],data['last_name']];
  return temp;
}

class profile extends StatefulWidget {
  @override
  getUserInfoState createState() =>
      new getUserInfoState();
}

class getUserInfoState extends State<profile> {
  Future<List> user;


  @override
  void initState() {
   user = getData();
  }
  @override
  Widget build(BuildContext context) {
     initState();
     return MaterialApp(
       title: 'Profile',
       theme: ThemeData(
         primarySwatch: Colors.blue,
       ),
       home: Scaffold(
         appBar: AppBar(
           title: Text('Profile'),
             leading: IconButton(
               icon: Icon(Icons.arrow_back),
               onPressed: () => Navigator.pop(context, false),
             )
         ),
         body: Center(
           child: FutureBuilder<List>(
             future: user,
             builder: (context, snapshot) {
               if (snapshot.hasData) {
                 return ListView(
                   children: <Widget>[
                     ListTile(
                      leading: GestureDetector(
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                        ),
                      ),
                       title: Text("Username: " + snapshot.data[1],
                         style: const TextStyle(
                         fontWeight: FontWeight.w500,
                         fontSize: 24.0,
                       )),
                     ),
                     ListTile(
                       leading: GestureDetector(
                         child: Container(
                           width: 48,
                           height: 48,
                           alignment: Alignment.center,
                         ),
                       ),
                       title: Text("Name: " + snapshot.data[2] + " " + snapshot.data[3],
                         style: const TextStyle(
                           fontWeight: FontWeight.w500,
                           fontSize: 24.0,
                         )),

                     ),
                     ListTile(
                       leading: GestureDetector(
                         child: Container(
                           width: 48,
                           height: 48,
                           alignment: Alignment.center,

                         ),
                       ),
                       title: Text("Email: " + snapshot.data[0],
                           style: const TextStyle(
                         fontWeight: FontWeight.w500,
                         fontSize: 24.0,
                       )),

                     ),
                   ],
                 );
               } else if (snapshot.hasError) {
                 return Text("${snapshot.error}");
               }
               // By default, show a loading spinner.
               return CircularProgressIndicator();
             },
           ),
         ),
       ),
     );
  }
}
