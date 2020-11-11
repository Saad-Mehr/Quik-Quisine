import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';


List UserList = [];

Future<int> LogIn(String email, String password) async{
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
    return response.statusCode;
  }
  else
    return null;
}

Future<int> SignUp(String UserName,String FirstName, String LastName, String email, String password, String PasswordConfirmation) async{
  var resBody = {};
  resBody["username"] = UserName;
  resBody["first_name"] = FirstName;
  resBody["last_name"] = LastName;
  resBody["email"] = email;
  resBody["password"] = password;
  resBody["password_confirmation"] = PasswordConfirmation;

  var jsonbody = {};
  jsonbody["user"] = resBody;
  String msg = json.encode(jsonbody);
  String url = 'https://quik-quisine.herokuapp.com/api/v1/users/sign_up';

  Map<String,String> headers = {'Content-Type': 'application/json; charset=UTF-8'};
  http.Response response = await http.post(url, headers: headers, body: msg);

  if (response.statusCode == 200) {
    var parsedJson = json.decode(response.body);
    var data = parsedJson['data'];
    UserList = [data['id'],data['email'],data['username'],data['authentication_token']];
    print(response.statusCode);
    return UserList;
  }
  else
    return null;
}