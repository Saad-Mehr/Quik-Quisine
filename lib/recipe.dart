import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'user.dart';

List<Recipes> recipeList = [];
//List<Recipes> savedRecipesList;

class Recipes {
  int id;
  String name;
  // add other attributes like image, description later

  Recipes(int id, String name){
    this.id = id;
    this.name = name;
  }
}

Future<int> recipes() async {
  var resBody = {};
  //recipeList = [];
  resBody["email"] = UserList[0];
  resBody["token"] = UserList[2];
  String recipesListURL = 'https://quik-quisine.herokuapp.com/api/v1/recipes';
  Map<String,String> headers = {'X-User-Email': resBody["email"], 'X-User-Token': resBody["token"]};

  http.Response response = await http.get(recipesListURL , headers: headers);

  if (response.statusCode == 200) {
    var parsedJson = json.decode(response.body);
    var data = parsedJson['data'];
    for(var i = 0; i < data.length; i++){
      recipeList.add(new Recipes(data[i]["id"], data[i]["name"]));
    }
    /*print("data is: ${data[0]["name"]}");
    print("recipes are: $recipeList");*/
    print("Success in recipes() : Code ${response.statusCode}");
    print("recipeList is " + recipeList.toString());
    /*print("savedRecipesList is " + savedRecipesList.toString());
    savedRecipesList = recipeList;*/
    return response.statusCode;
  } else if( (response.statusCode == 401) || (response.statusCode == 500) ){
    print("Error: Unauthorized");
    return response.statusCode;
  }
  else
    return response.statusCode;
}
