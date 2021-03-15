import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:quikquisine490/user.dart';
import 'profile.dart';
import 'package:another_flushbar/flushbar.dart';

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
      appBar: AppBar(
          title: Text('Edit Profile'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(
                context,
                false
            ),
          )
      ),
      body: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FutureBuilder<List>(
                future: user,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(left: 20, top:10, right: 20, bottom:0),
                                  decoration: new BoxDecoration(
                                    borderRadius: new BorderRadius.circular(16.0),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child:CircleAvatar(
                                      radius: 50.0,
                                      backgroundImage:  ExactAssetImage('assets/noprofile.png'),
                                    ),
                                  )

                              ),
                              Container(
                                  child: RaisedButton(
                                      child: Text("Change Profile Photo"),
                                      color: Colors.white,
                                      textColor: Color(0xffEE7B23),
                                      onPressed: (){

                                      }
                                  )
                              ),
                              SizedBox(height: 20.0),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(12.0),
                                color: Colors.grey[400],
                                child: Text("Profile Info",
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 35.0,
                                    ),
                                    textAlign: TextAlign.left

                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                ),
                                child: Text( "Username: " + snapshot.data[1],
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20.0,
                                    ),
                                    textAlign: TextAlign.left

                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Text( "First name: " + snapshot.data[2],
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20.0,
                                    ),
                                    textAlign: TextAlign.left

                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Text( "Last name: " + snapshot.data[3],
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20.0,
                                    ),
                                    textAlign: TextAlign.left

                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Text( "Email: " + snapshot.data[0],
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20.0,
                                    ),
                                    textAlign: TextAlign.left

                                ),
                              ),
                              SizedBox(height: 20.0),
                            ]
                        )
                    );
                  }
                  else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                }
              ),
              TextField(
                controller: _username_controller,
                decoration: InputDecoration(
                  hintText: 'UserName',
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
                Container(
                  margin: EdgeInsets.all(25),
                  child: RaisedButton(
                    child: Text('Update',
                      style: TextStyle(fontSize: 20.0),),
                      color: Color(0xffEE7B23),
                    onPressed: () {
                      if(_username_controller.text!=''|| _firstname_controller.text!=''||_lastname_controller.text!='')
                      updateUserInfo(_username_controller.text, _firstname_controller.text,_lastname_controller.text);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => profile()),
                      );
                      Flushbar(
                        message: "Updated successfully",
                        duration:  Duration(seconds: 3),
                        backgroundColor: Colors.green,
                      )..show(context);
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