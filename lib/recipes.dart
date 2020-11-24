import 'package:flutter/material.dart';
import 'search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

var resultSearchTerm;
List<dynamic> resultNames;
List<dynamic> resultDesc;
List<Widget> recipesResultsList = List();
List<dynamic> totalRecipes = new List();
List<dynamic> sortedTotalRecipeIng = [];
List<dynamic> filteredSortedTotal = [];
List<dynamic> mealPlannerRecipes = new List();
Map<String, String> get headers => {
  "X-User-Email": 'test@gmail.com',
  "X-User-Token":'KV7aSwEfxti-X2Mr6LxJ',
  'Content-Type': 'application/json; charset=UTF-8',
};


Future<List> addToList(int id) async{
  var url = 'https://quik-quisine.herokuapp.com/api/v1/users/users/51/meal_planner_baskets';
  var body = {};
  body["user_id"] ="51";
  body["recipe_id"]=id;
  var jsonbody = {};
  jsonbody["user"] = body;
  String msg = json.encode(jsonbody);
  http.Response response = await http.post(url,headers: headers,body: msg);
  print("Add to list code: " + response.statusCode.toString());
}

Future retrieveList() async{

  http.Response response = await http.get('https://quik-quisine.herokuapp.com/api/v1/users/users/51/meal_planner_baskets', headers: headers);
  var parsedJson = jsonDecode(response.body);
  var data = parsedJson['data'];
  mealPlannerRecipes = data;
  //print('mealPlanner data is ------------------------ ' + mealPlannerRecipes.toString());
  //print('mealPlanner[0] data is ------------------------ ' + mealPlannerRecipes[0].toString());
  //print('mealPlannerRecipes images are: ------------------------- ' + mealPlannerRecipes[0]['get_image_url'].toString());
}

Future<List> deleteList(int id) async{
  http.Response response = await http.delete('https://quik-quisine.herokuapp.com/api/v1/users/meal_planner_baskets/'+id.toString(),headers: headers);
  print(response.statusCode);
}

Future sortAllIngredients() async {

  sortedTotalRecipeIng.length = totalRecipes.length;
  for(int i = 0; i < totalRecipes.length; i++){

    sortedTotalRecipeIng[i] = [];

    for(int j = 0; j < totalRecipes[i]['list_of_ingredients'].length; j++){

      sortedTotalRecipeIng[i].add("${totalRecipes[i]['list_of_ingredients'][j]['ingredient_qty']} "
          "${totalRecipes[i]['list_of_ingredients'][j]['name']}\n");
    }

    filteredSortedTotal.add(sortedTotalRecipeIng[i].toString().replaceAll("[", "").replaceAll("]", "").replaceAll(",", ""));
  }

}

Future getRecipes() async{
  sortedTotalRecipeIng.clear();
  filteredSortedTotal.clear();
  http.Response response = await http.get('https://quik-quisine.herokuapp.com/api/v1/recipes', headers: headers);
  var parsedJson = jsonDecode(response.body);
  var data = parsedJson['data'];
  totalRecipes = data;
  await sortAllIngredients();
}

Future _ackAlert(BuildContext context,Widget thumbnail, String title, String subtitle, String instructions,String serving,String ingredients, int id) {

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: thumbnail,

        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(title + "\n" + subtitle + "\n" + serving + "\nIngredients:\n" + ingredients + '\nInstructions:\n' + instructions)
            ],
          ),
        ),
        actions: [
          FlatButton(
            child: Text('Add to List'),
            onPressed: () {
              addToList(id);
              retrieveList();
            },
          ),
        ],
      );
    },
  );
}

Future _ackAlert2(BuildContext context,Widget thumbnail, String title, String subtitle, String serving, String instructions, int id) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: thumbnail,

        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(title + "\n" + subtitle + "\n" + serving + '\n\nInstructions:\n' + instructions)
            ],
          ),
        ),
        actions: [
          FlatButton(
            child: Text('Remove from List'),
            onPressed: () {
              deleteList(id);
              retrieveList();
            },
          ),
        ],
      );
    },
  );
}

class RecipePage extends StatelessWidget {
  static const String _title = 'Recipes';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: DefaultTabController(
          length: 2,
          child: Scaffold(
              appBar: AppBar(title: const Text(_title),
                leading: IconButton(icon:Icon(Icons.arrow_back),
                  onPressed:() => Navigator.pop(context, false),
                ),
                bottom: TabBar(
                  tabs:[
                    Tab(icon: Icon(Icons.kitchen)),
                    Tab(icon: Icon(Icons.list)),
                  ],
                ),
              ),
              body:TabBarView(
                children:[
                  MyStatelessWidget(),
                  MyMealPlanner(),
                ],
              )
          )
      ),
    );
  }

}

class RecipeResultsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    resultNames = getRecipeNames;
    resultDesc = getRecipeDesc;
    resultSearchTerm = getSearchTerm;

    String _title;

    if(getSearchTerm.isNotEmpty) {
      _title = 'Results for ' + getSearchTerm +
          ': ${resultNames.length}';
    } else {
      _title = 'Results' + ': ${resultNames.length}';
    }

    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: Text(_title),
            leading: IconButton(icon:Icon(Icons.arrow_back),
              onPressed:() => Navigator.pop(context, false),
            )
        ),
        body:
        ResultsWidget(),

      ),
    );
  }
}

class ResultsWidget extends StatelessWidget {
  ResultsWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("recipes.dart has resultnames: ");
    print(resultNames);
    return ListView(
      padding: const EdgeInsets.all(10.0),
      children: getRecipeResults(),

    );
  }
}

List<Widget> getRecipeResults() {

  for (int i = 0; i < recipeNames.length; i++) {
    recipesResultsList.add(CustomListItemTwo(
      thumbnail: Container(
        child: Image.network(recipePicURLs[i], fit: BoxFit.fill,),
      ),
      title: recipeNames[i],
      subtitle: 'Description: ${recipeDesc[i]}',
      serving: 'Serving size: ${recipeServing[i]}',
      ingredients: ' ${filteredSortedIng[i]}',
      instructions: '${recipePrep[i]}',
    ));
  }

  if(resultNames.length == 0) {
    if(searchTerm.isEmpty){
      recipesResultsList.add(Text(
        'No results to display.',
      ));
    } else {
      recipesResultsList.add(Text(
        'No results for $searchTerm.',
      ));
    }
  }

  return recipesResultsList;
}

void clearResults(){
  resultSearchTerm = "";
  resultNames = [];
  resultDesc = [];
  recipesResultsList = [];
  clearRecipeList();
}

class _ArticleDescription extends StatelessWidget {
  _ArticleDescription({
    Key key,
    this.title,
    this.subtitle,
    this.instructions,
    this.serving,
    this.ingredients,
    this.id
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String instructions;
  final String serving;
  final String ingredients;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$title',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                '$subtitle',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                '$serving',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                '$ingredients',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,

          ),
        ),
      ],
    );
  }
}

class CustomListItemTwo extends StatelessWidget {
  CustomListItemTwo({
    Key key,
    this.thumbnail,
    this.title,
    this.subtitle,
    this.serving,
    this.ingredients,
    this.instructions,
    this.id,
  }) : super(key: key);

  final Widget thumbnail;
  final String title;
  final String subtitle;
  final String serving;
  final String ingredients;
  final String instructions;

  final int id;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {

        _ackAlert(context,this.thumbnail, this.title, this.subtitle, this.instructions,this.serving,this.ingredients, this.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),

        child: SizedBox(
          height: 155,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1.0,
                child: thumbnail,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                  child: _ArticleDescription(
                    title: title,
                    subtitle: subtitle,
                    serving: serving,
                    ingredients: ingredients,
                  ),

                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomListItemThree extends StatelessWidget {
  CustomListItemThree({
    Key key,
    this.thumbnail,
    this.title,
    this.subtitle,
    this.serving,
    this.instructions,
    this.id,
  }) : super(key: key);

  final Widget thumbnail;
  final String title;
  final String subtitle;
  final String serving;
  final String instructions;
  final int id;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _ackAlert2(context,this.thumbnail, this.title, this.subtitle, this.serving, this.instructions, this.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),

        child: SizedBox(
          height: 155,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1.0,
                child: thumbnail,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                  child: _ArticleDescription(
                    title: title,
                    subtitle: subtitle,
                    serving: serving,
                    instructions: instructions,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyStatelessWidget extends StatelessWidget {
  MyStatelessWidget({Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: totalRecipes.length,
      itemBuilder: (BuildContext context,index){
        return CustomListItemTwo(
          thumbnail: Container(
            child: Image.network(totalRecipes[index]['get_image_url'], fit: BoxFit.fill,),
          ),
          title: totalRecipes[index]['name'],
          subtitle: totalRecipes[index]['description'],
          serving: "Servings: ${totalRecipes[index]['serving']}",
          ingredients: " ${filteredSortedTotal[index]}",
          instructions: "${totalRecipes[index]['preparation']}",
          id: totalRecipes[index]['id'],
        );
      },
    );
  }
}

class MyMealPlanner extends StatelessWidget {
  MyMealPlanner({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    retrieveList();
    return ListView.builder(
      itemCount: mealPlannerRecipes.length,
      itemBuilder: (BuildContext context,index){
        return CustomListItemThree(
          thumbnail: Container(
            child: Image.network(mealPlannerRecipes[index]['get_image_url'], fit: BoxFit.fill,),
          ),
          title: mealPlannerRecipes[index]['name'],
          subtitle: mealPlannerRecipes[index]['description'],
          serving: "Servings: ${mealPlannerRecipes[index]['serving']}",
          instructions: "${mealPlannerRecipes[index]['preparation']}",
          id: mealPlannerRecipes[index]['id'],
        );
      },
    );

  }
}

