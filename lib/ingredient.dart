import 'dart:convert';
import 'package:quikquisine490/userIngredientList.dart';

import 'user.dart';
import 'package:http/http.dart' as http;

// the variable that stores the user existing ingredients is declared in the user.dart.(selectedIngredientList)
List<Ingredients> ingredientList = [];

// this is used for advanced search (not saved)
//List<Ingredients> tempIngList = [];
List<dynamic> chosenIngredients = [];

class Ingredients {
  int id;
  String name;

  Ingredients(int id, String name){
    this.id = id;
    this.name = name;
  //  add quantity later
  }
}

//method to save user ingredients
Future<int> SaveIngredients() async{
  var resBody = {};
  var ingredientListString = "";
  resBody["email"] = UserList[0];
  resBody["token"] = UserList[2];
  resBody["user_id"] = UserList[3];

  //format the selectedIngredientList to get a list of ingredient ids seperated by a comma
  for( var i = 0 ; i < selectedIngredientList.length; i++ ) {
    ingredientListString += selectedIngredientList[i].id.toString() + ",";
  }
  //remove the last comma in ingredientListString
  if (ingredientListString != null && ingredientListString.length > 0) {
    ingredientListString = ingredientListString.substring(0, ingredientListString.length - 1);
  }

  resBody["ingredients"] = ingredientListString;
  String msg = json.encode(resBody);
  String url = 'https://quik-quisine.herokuapp.com/api/v1/users/user_ingredients/';
  Map<String,String> headers = {'Content-Type': 'application/json','X-User-Email': resBody["email"], 'X-User-Token': resBody["token"]};
  http.Response response = await http.post(url, headers: headers, body: msg);

  if (response.statusCode == 200) {
    var parsedJson = json.decode(response.body);
    var data = parsedJson['data'];
    print(response.statusCode);
    return response.statusCode;

  } else if( (response.statusCode == 401) || (response.statusCode == 500) ){ // not saved successfully
    return response.statusCode;

  }
  else
    return null;
}

// method retrieves all ingredients and store it in the ingredient list on page load///////////
Future<int> ingredients() async {
  var resBody = {};
  resBody["email"] = UserList[0];
  resBody["token"] = UserList[2];
  String ingredientListURL = 'https://quik-quisine.herokuapp.com/api/v1/ingredients/index';
  Map<String,String> headers = {'X-User-Email': resBody["email"], 'X-User-Token': resBody["token"]};

  http.Response response = await http.get(ingredientListURL , headers: headers);

  if (response.statusCode == 200) {
    var parsedJson = json.decode(response.body);
    var data = parsedJson['data'];
    for(var i = 0; i < data.length; i++){
      ingredientList.add(new Ingredients(data[i]["id"], data[i]["name"]));
      //tempIngList.add(new Ingredients(data[i]["id"], data[i]["name"]));
    }
    print("data is: ${data[0]["name"]}");
    print("ingredients are: $ingredientList");
    print("Success: Code ${response.statusCode}");
    return response.statusCode;
  } else if( (response.statusCode == 401) || (response.statusCode == 500) ){
    print("Error: Unauthorized");
    return response.statusCode;
  }
  else
    return response.statusCode;
}

//method to retrieve the existing list of user ingredient
Future<int> existingIngredients() async {
  var resBody = {};
  resBody["email"] = UserList[0];
  resBody["token"] = UserList[2];
  String existingIngredientListURL = 'https://quik-quisine.herokuapp.com/api/v1/users/user_ingredients/?user_id=' + UserList[3].toString();
  Map<String,String> headers = {'X-User-Email': resBody["email"], 'X-User-Token': resBody["token"]};
  http.Response response = await http.get(existingIngredientListURL , headers: headers);

  if (response.statusCode == 200) {
    var parsedJson = json.decode(response.body);
    var data = parsedJson['data'];
    // need to do later: return data values as hashes not array so that we can do data[i]["name"] to retrieve name. Fix needs to be in api
    for(var i = 0; i < data.length; i++){
      selectedIngredientList.add(new Ingredients(data[i][1], data[i][2]));
    }
    print("data is: ${data[0][2]}");
    print("ingredients are: $selectedIngredientList");
    print("Success: Code ${response.statusCode}");
    return response.statusCode;
  } else if( (response.statusCode == 401) || (response.statusCode == 500) ){
    print("Error: Unauthorized");
    return response.statusCode;
  }
  else
    return response.statusCode;
}