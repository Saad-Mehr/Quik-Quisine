import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:quikquisine490/user.dart';
import 'profile.dart';
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
Future updateUserInfo(String newUsername, String newFirstName, String newLastName) async{
    print('Strings are '+ newUsername + ' ' + newFirstName + ' ' + newLastName);
    var body = {};
    if(newUsername!='') {
      body["username"] = newUsername;;
    }
    if(newFirstName!='') {
      body["first_name"] = newFirstName;
    }
    if(newLastName!='') {
      body["last_name"] = newLastName;
    }
  String url = 'https://quik-quisine.herokuapp.com/api/v1/users/users/' + UserList[3].toString();
  http.Response response = await http.patch(url,headers: headers, body: body);
  print('Update status code: '+ response.statusCode.toString());
}

class editProfile extends StatefulWidget {
  @override
  getNewUserInfo createState() =>
      new getNewUserInfo();
}

class getNewUserInfo extends State<editProfile> {
  Future<List> user;
  final TextEditingController _username_controller = TextEditingController();
  final TextEditingController _firstname_controller = TextEditingController();
  final TextEditingController _lastname_controller = TextEditingController();

  @override
  void initState() {
    user = getData();
  }

  @override
  Widget build(BuildContext context) {
    initState();
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 15.0,),
              TextField(
                controller: _username_controller,
                decoration: InputDecoration(
                  hintText: 'UserName',
                  suffixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 15.0,),
              TextField(
                controller: _firstname_controller,
                decoration: InputDecoration(
                  hintText: 'First Name',
                  suffixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 15.0,),
              TextField(
                controller: _lastname_controller,
                decoration: InputDecoration(
                  hintText: 'Last Name',
                  suffixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
                Container(
                  margin: EdgeInsets.all(25),
                  child: FlatButton(
                    child: Text('Update', style: TextStyle(fontSize: 20.0),),
                    onPressed: () {
                      if(_username_controller.text!=''|| _firstname_controller.text!=''||_lastname_controller.text!='')
                      updateUserInfo(_username_controller.text, _firstname_controller.text,_lastname_controller.text);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => profile()),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}