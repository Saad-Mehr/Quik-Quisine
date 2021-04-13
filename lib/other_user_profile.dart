import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quikquisine490/calendar.dart';
import 'dart:convert';
import 'dart:async';
import 'recipes.dart';
import 'package:quikquisine490/user.dart';
import 'HomePage.dart' as homepage;
import 'user.dart';



bool is_subscribed;
List<dynamic> userRecipes = [];

Future<List> getData() async{
  String url = 'https://quik-quisine.herokuapp.com/api/v1/users/users/' + UserList[3].toString() + '/other_profile?other_user_id=' + otherUserList[0].toString();
  Map<String,String> headers = {'X-User-Email': UserList[0], 'X-User-Token': UserList[2]};
  http.Response response = await http.get(url,headers: headers);
  var parsedJson = jsonDecode(response.body);
 
  var data = parsedJson['data'];
  List temp = [data['email'],data['username'],data['first_name'],data['last_name'], data['followers_count'], data['followings_count'], data['is_subscribed']];
  is_subscribed = temp[6];
  return temp;
}

Future<List> getUserRecipes() async{
  var url = 'https://quik-quisine.herokuapp.com/api/v1/recipe/retrieve_user_recipes?user_id='+otherUserList[0].toString();
  http.Response response = await http.get(url,headers: headers);
  var parsedJson = jsonDecode(response.body);
  var data = parsedJson['data'];
  userRecipes = data;
}

class other_profile extends StatefulWidget {
  @override
  getUserInfoState createState() =>
      new getUserInfoState();
}

class getUserInfoState extends State<other_profile> {
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
                              child: UpdateText(),
                            ),
                            Container(
                              child: Text("Followers ${snapshot.data[4]} |",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16.0,
                                  )
                              ),
                            ),
                            Container(
                              child: Text(" Following ${snapshot.data[5]}",
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
                                  length: 1,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        constraints: BoxConstraints.expand(height: 60, width:MediaQuery. of(context). size. width),
                                        child: TabBar(
                                            labelColor: Colors.orange[900],
                                            indicatorColor: Colors.orange[700],
                                            tabs: [
                                              Tab(
                                                text: "Recipes",
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

class displayUserRecipe extends StatelessWidget{
  Widget build(BuildContext context) {
  getUserRecipes();
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
              chef: "${otherUserList[1]} \n",
              user_id: otherUserList[0],
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

//update subscription text button

class UpdateText extends StatefulWidget {

  UpdateTextState createState() => UpdateTextState();

}

class UpdateTextState extends State {
  String textHolder = is_subscribed ? "Unsubscribe" : "Subscribe";

  void updateSubscription() async {
    await setSubscription();
    setState((){
      textHolder = is_subscribed ? "Unsubscribe" : "Subscribe";
    });
  }

  Widget build(BuildContext context) {
    return RaisedButton(
      //     disabledColor: Colors.red,
      // disabledTextColor: Colors.black,
      padding: const EdgeInsets.all(10),
      textColor: Colors.black,
      color: is_subscribed ? Colors.grey : Colors.orange,
      onPressed: () {
        updateSubscription();
      },
      child: Text(textHolder) ,
    );
    // return Text('$textHolder',
    //     style: TextStyle(fontSize: 21)
    // );
  }
}

Future<int> setSubscription() async{
  if(is_subscribed) {
    String url = 'https://quik-quisine.herokuapp.com/api/v1/users/users/' +
        UserList[3].toString() + '/unsubscribe?other_user_id=' +
        otherUserList[0].toString();
    Map<String, String> headers = {
      'X-User-Email': UserList[0],
      'X-User-Token': UserList[2]
    };
    http.Response response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      is_subscribed = false;
      return response.statusCode;
    } else if( (response.statusCode == 401) || (response.statusCode == 500) ){
      print("Error: Unauthorized");
      return response.statusCode;
    }
    else{
      return response.statusCode;
    }
  }
  else{
    String url = 'https://quik-quisine.herokuapp.com/api/v1/users/users/' +
        UserList[3].toString() + '/subscribe?other_user_id=' +
        otherUserList[0].toString();
    Map<String, String> headers = {
      'X-User-Email': UserList[0],
      'X-User-Token': UserList[2]
    };
    http.Response response = await http.post(url, headers: headers);

    if (response.statusCode == 200) {
      is_subscribed = true;
      return response.statusCode;
    } else if( (response.statusCode == 401) || (response.statusCode == 500) ){
      print("Error: Unauthorized");
      return response.statusCode;
    }
    else
      return response.statusCode;
  }

}

