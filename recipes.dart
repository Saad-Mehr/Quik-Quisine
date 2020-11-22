import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

var resultSearchTerm;
List<dynamic> resultNames;
List<dynamic> resultDesc;
List<dynamic> totalRecipes = new List();
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
  var parsedJson = jsonDecode(response.body);
  var data = parsedJson['data'];
  print("Add to list code: " + response.statusCode.toString());
}

Future retrieveList() async{

  http.Response response = await http.get('https://quik-quisine.herokuapp.com/api/v1/users/users/51/meal_planner_baskets',headers: headers);
  var parsedJson = jsonDecode(response.body);
  var data = parsedJson['data'];
  mealPlannerRecipes = data;
}

Future<List> deleteList(int id) async{
  http.Response response = await http.delete('https://quik-quisine.herokuapp.com/api/v1/users/meal_planner_baskets/'+id.toString(),headers: headers);
  print(response.statusCode);
}

Future getRecipes() async{
  http.Response response = await http.get('https://quik-quisine.herokuapp.com/api/v1/recipes',headers: headers);
  var parsedJson = jsonDecode(response.body);
  var data = parsedJson['data'];
  totalRecipes = data;
}

Future _ackAlert(BuildContext context,Widget thumbnail, String title, String subtitle, String instructions, int id) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: thumbnail,

        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(title + "\n\nIngredients:\n" + subtitle +'\n\nInstructions:\n' + instructions)
            ],
          ),
        ),
        actions: [
          FlatButton(
            child: Text('Add to List'),
            onPressed: () {
              addToList(id);
              retrieveList();
              //retrieveList();
            },
          ),
        ],
      );
    },
  );
}

Future _ackAlert2(BuildContext context,Widget thumbnail, String title, String subtitle, String instructions, int id) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: thumbnail,

        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(title + "\n\nIngredients:\n" + subtitle +'\n\nInstructions:\n' + instructions)
            ],
          ),
        ),
        actions: [
          FlatButton(
            child: Text('Remove from List'),
            onPressed: () {
              //addToList(id);
              deleteList(id);
              retrieveList();
              //retrieveList();
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
    Future.delayed(Duration(milliseconds: 500));

    resultNames = getRecipeNames;
    resultDesc = getRecipeDesc;
    resultSearchTerm = getSearchTerm;

    String _title = 'Results for ' + getSearchTerm + ': ${resultNames.length}';

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

List<Widget> getRecipeResults() {
  List<Widget> recipes = List();

  print(resultNames.length);

  for (int i = 0; i < resultNames.length; i++) {
    recipes.add(CustomListItemTwo(
      thumbnail: Container(
        child: Image.asset('assets/${resultNames[i]}.jpg', fit: BoxFit.fill,),
      ),
      title: resultNames[i],
      subtitle: 'Ingredients: 16 ounces sliced pepperoncini undrained, 14 1/2 ounces diced tomatoes undrained, 1 medium onion chopped, 1/2 cup water, 2 packages Italian salad dressing mix, 1 teaspoon dried oregano, 1/2 teaspoon garlic powder, 1 beef rump roast or bottom round roast (3 to 4 pounds), 12 Italian rolls split',
      instructions: '1. In a bowl, mix the first 7 ingredients. Halve roast; place in a 6-qt. electric pressure cooker. Pour pepperoncini mixture over top. Lock lid; close pressure-release valve. Adjust to pressure-cook on high for 60 minutes. Let pressure release naturally. A thermometer inserted into beef should read at least 145°. \n2. Remove roast; cool slightly. Skim fat from cooking juices. Shred beef with 2 forks. Return beef and cooking juices to pressure cooker; heat through. Serve on rolls.',
    ));
  }

  if(resultNames.length == 0) {
    recipes.add(Text(
      'No results for $searchTerm.',
    ));
  }

  return recipes;
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



class _ArticleDescription extends StatelessWidget {
  _ArticleDescription({
    Key key,
    this.title,
    this.subtitle,
  }) : super(key: key);

  final String title;
  final String subtitle;


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
                maxLines: 3,
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
    this.instructions,
    this.id,
  }) : super(key: key);

  final Widget thumbnail;
  final String title;
  final String subtitle;
  final String instructions;
  final int id;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _ackAlert(context,this.thumbnail, this.title, this.subtitle, this.instructions, this.id);
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
    this.instructions,
    this.id,
  }) : super(key: key);

  final Widget thumbnail;
  final String title;
  final String subtitle;
  final String instructions;
  final int id;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _ackAlert2(context,this.thumbnail, this.title, this.subtitle, this.instructions, this.id);
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

  @override
  Widget build(BuildContext context) {
    getRecipes();
    return ListView.builder(
      itemCount: totalRecipes.length,
      itemBuilder: (BuildContext context,index){
        return CustomListItemTwo(
          thumbnail: Container(
            child: Image.asset('assets/' + totalRecipes[index]['name'] + '.jpg',fit: BoxFit.fill,),
          ),
          title: totalRecipes[index]['name'],
          subtitle: totalRecipes[index]['description'],
          instructions: "Servings: " + totalRecipes[index]['serving'].toString() + " " + "Preparation: " ,
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
            child: Image.asset('assets/' + mealPlannerRecipes[index]['name'] + '.jpg',fit: BoxFit.fill,),
          ),
          title: mealPlannerRecipes[index]['name'],
          subtitle: mealPlannerRecipes[index]['description'],
          instructions: "Servings: " + mealPlannerRecipes[index]['serving'].toString() + " " + "Preparation: " ,
          id: mealPlannerRecipes[index]['id'],
        );
      },
    );

  }
}

