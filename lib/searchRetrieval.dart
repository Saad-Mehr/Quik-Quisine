import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'user.dart';

List categoriesList = [];
List preferencesList = [];
List searchList = [];

Future<int> categories() async {
  var resBody = {};
  var jsonbody = {};
  categoriesList = [];
  resBody["email"] = UserList[0];
  resBody["token"] = UserList[2];
  jsonbody["user"] = resBody;
  String url = 'https://quik-quisine.herokuapp.com/api/v1/users/users/' + UserList[3].toString();
  String categoriesURL = 'https://quik-quisine.herokuapp.com/api/v1/categories';
  Map<String,String> headers = {'X-User-Email': resBody["email"], 'X-User-Token': resBody["token"]};

  http.Response response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {

    http.Response catResponse = await http.get(categoriesURL, headers: headers);
    print("categories response is: ${catResponse.statusCode}");

    var parsedJson = json.decode(catResponse.body);
    var data = parsedJson['data'];
    for(var i = 0; i < data.length; i++){
      categoriesList.add(data[i]);
    }
    print("data is: ${data[0]}");
    print("categories are: $categoriesList");
    print("Success: Code ${response.statusCode}");
    return response.statusCode;
  } else if( (response.statusCode == 401) || (response.statusCode == 500) ){ // incorrect email and/or password
    print("Error: Unauthorized");
    return response.statusCode;
  }
  else
    return response.statusCode;
}

Future<int> preferences() async {
  var resBody = {};
  var jsonbody = {};
  preferencesList = [];
  resBody["email"] = UserList[0];
  resBody["token"] = UserList[2];
  jsonbody["user"] = resBody;
  String url = 'https://quik-quisine.herokuapp.com/api/v1/users/users/' + UserList[3].toString();
  String preferencesURL = 'https://quik-quisine.herokuapp.com/api/v1/preferences';
  Map<String,String> headers = {'X-User-Email': resBody["email"], 'X-User-Token': resBody["token"]};

  http.Response response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {

    http.Response prefResponse = await http.get(preferencesURL, headers: headers);
    print("categories response is: ${prefResponse.statusCode}");

    var parsedJson = json.decode(prefResponse.body);
    var data = parsedJson['data'];
    for(var i = 0; i < data.length; i++){
      preferencesList.add(data[i]);
    }
    print("data is: ${data[0]}");
    print("preferences are: $preferencesList");
    print("Success: Code ${response.statusCode}");
    return response.statusCode;
  } else if( (response.statusCode == 401) || (response.statusCode == 500) ){ // incorrect email and/or password
    print("Error: Unauthorized");
    return response.statusCode;
  }
  else
    return response.statusCode;
}

Future<int> recipeSearch(String urlParams) async {
  var resBody = {};
  var jsonbody = {};
  searchList = [];
  resBody["email"] = UserList[0];
  resBody["token"] = UserList[2];
  jsonbody["user"] = resBody;
  String searchURL = 'https://quik-quisine.herokuapp.com/api/v1/recipe/search$urlParams';
  Map<String,String> headers = {'X-User-Email': resBody["email"], 'X-User-Token': resBody["token"]};

  http.Response response = await http.get(searchURL, headers: headers);

  print('searchURL is now: $searchURL');

  if (response.statusCode == 200) {

    http.Response searchResponse = await http.get(searchURL, headers: headers);
    print("searchURL response is: ${searchResponse.statusCode}");

    var parsedJson = json.decode(searchResponse.body);
    var data = parsedJson['data'];
    for(var i = 0; i < data.length; i++){
      searchList.add(data[i]);
    }
    print("search data[0] is: ${data[0]}");
    print("search list is : $searchList");
    print("Success: Code ${response.statusCode}");
    return response.statusCode;
  } else if( (response.statusCode == 401) || (response.statusCode == 500) ){ // incorrect email and/or password
    print("Error: Unauthorized");
    return response.statusCode;
  }
  else
    return response.statusCode;
}