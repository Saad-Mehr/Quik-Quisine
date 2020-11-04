import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';


List UserList = [];
class User {
  String email;
  //final String password;
  String token;
  String username;
  String id;
  //User({this.email, this.password, this.token, this.username});

  User(Map<String, dynamic> json){
      this.email = json['email'];
      this.username = json['username'];
      this.token = json['authentication_token'];
      this.id = json['id'];
  }
}

Future<List> signIn(String email, String password) async{
  var resBody = {};
  resBody["email"] = email;
  resBody["password"] = password;
  var jsonbody = {};
  jsonbody["user"] = resBody;
  String msg = json.encode(jsonbody);
  String url = 'https://quik-quisine.herokuapp.com/api/v1/users/sign_in';
  Map<String,String> headers = {'Content-Type': 'application/json; charset=UTF-8'};
  http.Response response = await http.post(url, headers: headers, body: msg);
  if (response.statusCode == 200) {
    var parsedJson = json.decode(response.body);
    var data = parsedJson['data'];
    //List<String> tags = data != null ? List.from(data) : null;
    //var testuser = User(test);
    List user = [data['email'],data['username'],data['authentication_token'],data['id']];
    print(response.statusCode);
    return user;
  }
  else
    return null;
}

