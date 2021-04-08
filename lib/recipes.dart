import 'package:flutter/material.dart';
import 'search.dart';
import 'package:http/http.dart' as http;
import 'package:quikquisine490/user.dart';
import 'dart:convert';
import 'dart:async';
import 'recipedetails.dart';

var resultSearchTerm;
List<dynamic> resultNames;
List<dynamic> resultDesc;
List<Widget> recipesResultsList = [];
List<dynamic> totalRecipes = [];
List<dynamic> sortedTotalRecipeIng = [];
List<dynamic> filteredSortedTotal = [];
List<dynamic> mealPlannerRecipes = [];
String recipesPageTitle;

Map<String, String> get headers => {
  "X-User-Email": UserList[0],
  "X-User-Token": UserList[2],
  'Content-Type': 'application/json; charset=UTF-8',
};


Future<List> addToList(int id) async{
  var url = 'https://quik-quisine.herokuapp.com/api/v1/users/users/'+UserList[3].toString()+'/meal_planner_baskets';
  var body = {};
  body["user_id"] =UserList[3].toString();
  body["recipe_id"]=id;
  var jsonbody = {};
  jsonbody["user"] = body;
  String msg = json.encode(jsonbody);
  http.Response response = await http.post(url,headers: headers,body: msg);
  print("Add to list code: " + response.statusCode.toString());
}

Future retrieveList() async{

  http.Response response = await http.get('https://quik-quisine.herokuapp.com/api/v1/users/users/'+UserList[3].toString()+'/meal_planner_baskets', headers: headers);
  var parsedJson = jsonDecode(response.body);
  var data = parsedJson['data'];
  mealPlannerRecipes = data;
  for(int i = 0; i < mealPlannerRecipes.length;i++)
  print("in meal planner" + totalRecipes[i]['get_image_url'].toString());
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

Future getSearchIng() async {
  sortedTotalRecipeIng.clear();
  http.Response response = await http.get('https://quik-quisine.herokuapp.com/api/v1/recipes', headers: headers);
  var parsedJson = jsonDecode(response.body);
  var data = parsedJson['data'];
  totalRecipes = data;

  sortedTotalRecipeIng.length = totalRecipes.length;
  for(int i = 0; i < totalRecipes.length; i++){

    sortedTotalRecipeIng[i] = [];

    for(int j = 0; j < totalRecipes[i]['list_of_ingredients'].length; j++){

      sortedTotalRecipeIng[i].add("${totalRecipes[i]['list_of_ingredients'][j]['ingredient_qty']} "
          "${totalRecipes[i]['list_of_ingredients'][j]['name']}\n");
    }
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

Future _ackAlert(BuildContext context,Widget thumbnail, String title, String subtitle, String instructions,String serving,String ingredients,double AverageRating, String review, int id) {
if(review == null){
  review = 'No reviews yet.';
}
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: thumbnail,

        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(title + "\n" + subtitle + "\n" + serving + "\nIngredients:\n" + ingredients + '\nRating:'),
              SmoothStarRating(
                allowHalfRating: true,
                starCount: 5,
                rating: AverageRating,
                size: 20,
                color: Colors.amber,
                borderColor: Colors.black,
              ),
            ],
          ),
        ),
        actions: [
          FlatButton(
            child: Text('Add to List'),
            onPressed: () {
              addToList(id);
              retrieveList();
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('More Details'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => new recipedetails(thumbnail,title,subtitle,instructions,serving,ingredients,id,AverageRating,review),
                ),
              );
            },
          )
        ],
      );
    },
  );
}

Future _ackAlert2(BuildContext context,Widget thumbnail, String title, String subtitle, String instructions,String serving,double AverageRating, String review, int id) {
  if(review == null){
    review = 'No reviews yet.';
  }
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: thumbnail,

        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(title + "\n" + subtitle + "\n" + serving +'\nRating:'),
              SmoothStarRating(
                allowHalfRating: true,
                starCount: 5,
                rating: AverageRating,
                size: 20,
                color: Colors.amber,
                borderColor: Colors.black,
              ),
            ],
          ),
        ),
        actions: [
          FlatButton(
            child: Text('Remove from List'),
            onPressed: () {
              deleteList(id);
              retrieveList();
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('More Details'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => new recipedetails(thumbnail,title,subtitle,instructions,serving,"ingredients",id,AverageRating,review),
                ),
              );
            },
          )
        ],
      );
    },
  );
}

class RecipePage extends StatelessWidget {
  String _title = recipesPageTitle;

  @override
  Widget build(BuildContext context) {
    retrieveList();
    return MaterialApp(
      title: _title,
      home: DefaultTabController(
          length: 2,
          child: Scaffold(
              appBar: AppBar(
                title: Text(_title),
                backgroundColor: Colors.teal[400],
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

/*class RecipeResultsPage extends StatelessWidget {

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

  if(isIngredientSearch == true) {
    for (int i = 0; i < recipeNames.length; i++) {

      recipesResultsList.add(CustomListItemTwo(
        thumbnail: Container(
          child: Image.network(recipePicURLs[i], fit: BoxFit.fill,),
        ),
        title: recipeNames[i],
        subtitle: 'Description: ${recipeDesc[i]}',
        serving: 'Serving size: ${recipeServing[i]}',
        ingredients: ' ${filteredSortedIng[i]}\n'
            'Missing ingredients:\n ${missingIngredients[i].toString()
            .replaceAll("[", "").replaceAll("]", "")
            .replaceAll(",", "\n")}\n',
        instructions: '${recipePrep[i]}',
        //AverageRating: '${recipeRatings[i]}',
      ));

    }
  } else {
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
}*/

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
    this.id,
    this.AverageRating,
    this.review,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String instructions;
  final String serving;
  final String ingredients;
  final String id;
  double AverageRating;
  final String review;

  @override
  Widget build(BuildContext context) {
    if(AverageRating == null)
      AverageRating = 0;
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
                maxLines: 1,
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
              SmoothStarRating(
                allowHalfRating: true,
                starCount: 5,
                rating: AverageRating,
                size: 20,
                color: Colors.amber,
                borderColor: Colors.black,

              ),
             /* Text(
                '$ingredients',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                ),
              ),*/
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
    this.AverageRating,
    this.review
  }) : super(key: key);

  final Widget thumbnail;
  final String title;
  final String subtitle;
  final String serving;
  final String ingredients;
  final String instructions;
   double AverageRating;
  final String review;

  final int id;


  @override
  Widget build(BuildContext context) {
    if(AverageRating==null)
      AverageRating = 0;
    return GestureDetector(
      onTap: () {

        _ackAlert(context,this.thumbnail, this.title, this.subtitle, this.instructions,this.serving,this.ingredients,this.AverageRating, this.review, this.id);
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
                    AverageRating: AverageRating,
                    review: review,
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
    this.AverageRating,
    this.review,
    this.id,
  }) : super(key: key);

  final Widget thumbnail;
  final String title;
  final String subtitle;
  final String serving;
  final String instructions;
  double AverageRating;
  final String review;
  final int id;

  @override
  Widget build(BuildContext context) {
    if(AverageRating==null)
      AverageRating = 0;
    return GestureDetector(
      onTap: () {
        _ackAlert2(context,this.thumbnail, this.title, this.subtitle, this.instructions,this.serving,this.AverageRating, this.review, this.id);
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
                    AverageRating: AverageRating,
                    review: review,
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
                child: Image.network(totalRecipes[index]['get_image_url'], fit: BoxFit.fill,),
              ),
              title: totalRecipes[index]['name'],
              subtitle: totalRecipes[index]['description'],
              serving: "Servings: ${totalRecipes[index]['serving']}",
              ingredients: " ${filteredSortedTotal[index]}",
              instructions: "${totalRecipes[index]['preparation']}",
              id: totalRecipes[index]['id'],
              AverageRating: double.parse(totalRecipes[index]['AverageRating']),
              review: totalRecipes[index]['review'],
            ),

          ),
        );
      },
    );
  }
}

class MyMealPlanner extends StatelessWidget {
  MyMealPlanner({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      itemCount: mealPlannerRecipes.length,
      itemBuilder: (BuildContext context,index){
        return new Card(
          child: new Container(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10, // Space between underline and text
              right: 10,
              left: 10,
            ),
        child: CustomListItemThree(
          thumbnail: Container(
            child: Image.network(mealPlannerRecipes[index]['get_image_url'], fit: BoxFit.fill,),
          ),
          title: mealPlannerRecipes[index]['name'],
          subtitle: mealPlannerRecipes[index]['description'],
          serving: "Servings: ${mealPlannerRecipes[index]['serving']}",
          instructions: "${mealPlannerRecipes[index]['preparation']}",
          id: mealPlannerRecipes[index]['id'],
          AverageRating: double.parse(totalRecipes[index]['AverageRating']),
          review: totalRecipes[index]['review'],
        ),
        ),
        );
      },
    );

  }
}

typedef void RatingChangeCallback(double rating);
class SmoothStarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;
  final Color borderColor;
  final double size;
  final bool allowHalfRating;
  final double spacing;
  SmoothStarRating(
      {this.starCount = 5,
        this.rating = 0.0,
        this.onRatingChanged,
        this.color,
        this.borderColor,
        this.size,
        this.spacing = 0.0,
        this.allowHalfRating = true}) {
    assert(this.rating != null);
  }
  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = new Icon(
        Icons.star_border,
        color: borderColor ?? Theme.of(context).primaryColor,
        size: size ?? 25.0,
      );
    } else if (index > rating - (allowHalfRating ? 0.5 : 1.0) &&
        index < rating) {
      icon = new Icon(
        Icons.star_half,
        color: color ?? Theme.of(context).primaryColor,
        size: size ?? 25.0,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: color ?? Theme.of(context).primaryColor,
        size: size ?? 25.0,
      );
    }
    return new GestureDetector(
      onTap: () {
        if (this.onRatingChanged != null) onRatingChanged(index + 1.0);
      },
      onHorizontalDragUpdate: (dragDetails) {
        RenderBox box = context.findRenderObject();
        var _pos = box.globalToLocal(dragDetails.globalPosition);
        var i = _pos.dx / size;
        var newRating = allowHalfRating ? i : i.round().toDouble();
        if (newRating > starCount) {
          newRating = starCount.toDouble();
        }
        if (newRating < 0) {
          newRating = 0.0;
        }
        if (this.onRatingChanged != null) onRatingChanged(newRating);
      },
      child: icon,
    );
  }
  @override
  Widget build(BuildContext context) {
    return new Material(
      color: Colors.transparent,
      child: new Wrap(
          alignment: WrapAlignment.start,
          spacing: spacing,
          children: new List.generate(
              starCount, (index) => buildStar(context, index))),
    );
  }
}

