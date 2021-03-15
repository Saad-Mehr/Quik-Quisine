import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quikquisine490/calendar.dart';
import 'dart:convert';
import 'dart:async';
import 'editProfile.dart';
import 'package:quikquisine490/user.dart';
import 'HomePage.dart' as homepage;

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
         primarySwatch: Colors.deepOrange,
       ),
       home: Scaffold(
         appBar: AppBar(
           title: Text('Profile'),
             leading: IconButton(
               icon: Icon(Icons.arrow_back),
               onPressed: () => Navigator.pop(
                 context,
                 false
               ),
             )
         ),
         body: Center(
           child: FutureBuilder<List>(
             future: user,
             builder: (context, snapshot) {
               if (snapshot.hasData) {
                 return ListView(
                   children: <Widget>[
                     Column(
                       children: <Widget>[
                         Row(
                           mainAxisAlignment: MainAxisAlignment.start,
                           children: <Widget>[
                             Container(
                                 margin: EdgeInsets.only(left: 20, top:10, right: 20, bottom:0),
                                 decoration: new BoxDecoration(
                                   borderRadius: new BorderRadius.circular(16.0),
                                 ),
                                 child: Align(
                                   alignment: Alignment.topLeft,
                                   child:CircleAvatar(
                                     radius: 50.0,
                                     backgroundImage:  ExactAssetImage('assets/noprofile.png'),
                                   ),
                                 )

                             ),
                             Container(
                               child: Text(snapshot.data[1],
                                   style: const TextStyle(
                                     fontWeight: FontWeight.normal,
                                     fontSize: 24.0,
                                   )
                               ),
                             )
                           ],
                         ),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.start,
                           children: <Widget>[
                             Container(
                               margin:  EdgeInsets.only(left: 20, top:10, right: 20, bottom:0),
                               child: PopupMenuButton<String>(
                                 child:Row(
                                     children: <Widget>[
                                       ElevatedButton.icon(
                                           icon: Icon(Icons.settings,color: Colors.grey,),
                                           label: Text(
                                             "Settings",
                                             textAlign: TextAlign.center,
                                             overflow: TextOverflow.ellipsis,
                                             style: TextStyle(color: Colors.black),
                                           )
                                       ),
                                     ]
                                 ),
                                 onSelected: (option) => optionAction(option, context),
                                 itemBuilder: (BuildContext context) {
                                   return MenuOptions.options.map((String option){
                                     return PopupMenuItem<String>(
                                       value: option,
                                       child: Text(option),
                                     );
                                   }).toList();
                                 }
                               ),
                             ),
                             Container(
                               child: Text("Followers 2000 |",
                                   style: const TextStyle(
                                     fontWeight: FontWeight.normal,
                                     fontSize: 16.0,
                                   )
                               ),
                             ),
                             Container(
                               child: Text(" Following 0",
                                   style: const TextStyle(
                                     fontWeight: FontWeight.normal,
                                     fontSize: 16.0,
                                   )
                               ),
                             )
                           ],
                         ),
                         Row(
                             mainAxisAlignment: MainAxisAlignment.start,
                             children: <Widget>[
                               DefaultTabController(
                                   length: 2,
                                   child: Column(
                                     children: <Widget>[
                                       Container(
                                         constraints: BoxConstraints.expand(height: 60, width:MediaQuery. of(context). size. width),
                                         child: TabBar(
                                             labelColor: Colors.orange[900],
                                             indicatorColor: Colors.orange[700],
                                             tabs: [
                                               Tab(
                                                 text: "Subscriptions",
                                                 icon: Icon(Icons.bookmarks),

                                               ),
                                               Tab(
                                                 text: "My Recipes",
                                                 icon: Icon(Icons.local_dining),
                                               ),
                                             ]
                                         ),
                                       )
                                     ],
                                   )
                               ),
                             ]
                         )
                       ],
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

// the options for the settings dropdown
class MenuOptions {
  static const String EditProfile = 'Edit profile';

  static const List<String> options = <String>[
    EditProfile
  ];

}
// the route change to the option selected
void optionAction(String option, BuildContext context) {
  if (option == MenuOptions.EditProfile) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => editProfile()),
    );
  }
}