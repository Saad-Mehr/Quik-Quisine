import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quikquisine490/calendar.dart';
import 'dart:convert';
import 'dart:async';
import 'editProfile.dart';
import 'recipes.dart';
import 'package:quikquisine490/user.dart';
import 'HomePage.dart' as homepage;
//thedatadb@gmail.com mealdbtester
Map<String, String> get headers => {
  "X-User-Email": UserList[0],
  "X-User-Token": UserList[2],
};

List<dynamic> userRecipes = [];
List<dynamic> subRecipes = [];

Future<List> getData() async{
  String url = 'https://quik-quisine.herokuapp.com/api/v1/users/users/' + UserList[3].toString();
  http.Response response = await http.get(url,headers: headers);
  var parsedJson = jsonDecode(response.body);
  var data = parsedJson['data'];
  List temp = [data['email'],data['username'],data['first_name'],data['last_name']];
  return temp;
}

Future<List> getSubsRecipes() async{
  var url = 'https://quik-quisine.herokuapp.com/api/v1/recipe/latest_subscribed_recipes?user_id='+UserList[3].toString();
  http.Response response = await http.get(url,headers: headers);
  var parsedJson = jsonDecode(response.body);
  var data = parsedJson['data'];
  subRecipes = data;
}

Future<List> getUserRecipes() async{
  var url = 'https://quik-quisine.herokuapp.com/api/v1/recipe/retrieve_user_recipes?user_id='+UserList[3].toString();
  http.Response response = await http.get(url,headers: headers);
  var parsedJson = jsonDecode(response.body);
  var data = parsedJson['data'];
  userRecipes = data;
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
     getUserRecipes();
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
             future:user,
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
                                       ),
                                       Container(
                                         width: 400,
                                         height: 670,
                                         child:TabBarView(
                                             children: [
                                               displaySubRecipe(),
                                               displayUserRecipe()
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
class displaySubRecipe extends StatelessWidget{
  Widget build(BuildContext context) {
  getSubsRecipes();
    return ListView.builder(
      itemCount: subRecipes.length,
      itemBuilder: (BuildContext context, index) {
        return new Card(
          child: new Container(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10, // Space between underline and text
                right: 10,
                left: 10,
              ),
            child: CustomListItemTwo(
              thumbnail: Container(
                child: Image.network(
                  subRecipes[index]['get_image_url'], fit: BoxFit.fill,),
              ),
              title: subRecipes[index]['name'],
              subtitle: subRecipes[index]['description'],
              serving: "Servings: ${subRecipes[index]['serving']}",
              chef: "@${subRecipes[index]['username']} \n",
              user_id: subRecipes[index]['user_id'],
              ingredients: subRecipes[index]['list_of_ingredients'].toString(),
              instructions: "${subRecipes[index]['preparation']}",
              id: subRecipes[index]['id'],
              AverageRating: double.parse(subRecipes[index]['AverageRating']),
              review: subRecipes[index]['review'],
            ),

          ),
        );
      },
    );
  }
}
class displayUserRecipe extends StatelessWidget{
  Widget build(BuildContext context) {

    return ListView.builder(
      itemCount: userRecipes.length,
      itemBuilder: (BuildContext context, index) {
        return new Card(
          child: new Container(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10, // Space between underline and text
              right: 10,
              left: 10,
            ),
            child: CustomListItemTwo(
              thumbnail: Container(
                child: Image.network(
                  userRecipes[index]['get_image_url'], fit: BoxFit.fill,),
              ),
              title: userRecipes[index]['name'],
              subtitle: userRecipes[index]['description'],
              serving: "Servings: ${userRecipes[index]['serving']}",
              chef: "@${UserList[1]} \n",
              user_id: UserList[3],
              ingredients: userRecipes[index]['list_of_ingredients'].toString(),
              instructions: "${userRecipes[index]['preparation']}",
              id: userRecipes[index]['id'],
              AverageRating: double.parse(userRecipes[index]['AverageRating']),
              review: userRecipes[index]['review'],
            ),

          ),
        );
      },
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