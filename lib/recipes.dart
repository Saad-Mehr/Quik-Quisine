import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'search.dart';

var resultSearchTerm;
List<dynamic> resultNames;
List<dynamic> resultDesc;
List<Widget> recipesResultsList = List();

Future _ackAlert(BuildContext context,Widget thumbnail, String title, String subtitle,
                                                        String serving, String ingredients, String instructions) {
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
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
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
      home: Scaffold(
        appBar: AppBar(title: const Text(_title),
            leading: IconButton(icon:Icon(Icons.arrow_back),
              onPressed:() => Navigator.pop(context, false),
            )
        ),
        body:
        MyStatelessWidget(),

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
    this.serving,
    this.ingredients,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String serving;
  final String ingredients;

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
  }) : super(key: key);

  final Widget thumbnail;
  final String title;
  final String subtitle;
  final String serving;
  final String ingredients;
  final String instructions;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _ackAlert(context,this.thumbnail, this.title, this.subtitle, this.serving, this.ingredients, this.instructions);
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

class MyStatelessWidget extends StatelessWidget {
  MyStatelessWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(10.0),
      children: <Widget>[
        CustomListItemTwo(
          thumbnail: Container(
            child: Image.asset('assets/Pressure-Cooker Italian Beef Sandwiches.jpg',fit: BoxFit.fill,),
          ),
          title: 'Pressure-Cooker Italian Beef Sandwiches',
          subtitle: 'Ingredients: 16 ounces sliced pepperoncini undrained, 14 1/2 ounces diced tomatoes undrained, 1 medium onion chopped, 1/2 cup water, 2 packages Italian salad dressing mix, 1 teaspoon dried oregano, 1/2 teaspoon garlic powder, 1 beef rump roast or bottom round roast (3 to 4 pounds), 12 Italian rolls split',
          instructions: '1. In a bowl, mix the first 7 ingredients. Halve roast; place in a 6-qt. electric pressure cooker. Pour pepperoncini mixture over top. Lock lid; close pressure-release valve. Adjust to pressure-cook on high for 60 minutes. Let pressure release naturally. A thermometer inserted into beef should read at least 145°. \n2. Remove roast; cool slightly. Skim fat from cooking juices. Shred beef with 2 forks. Return beef and cooking juices to pressure cooker; heat through. Serve on rolls.',
        ),
        CustomListItemTwo(
          thumbnail: Container(
            child: Image.asset('assets/glazed salmon.jpg',fit: BoxFit.fill,),
          ),
          title: 'Honey Garlic Glazed Salmon',
          subtitle: 'Ingredients: 1/4 c.soy sauce, 1/3 c.honey, 2 tbsp.lemon juice, 1 tsp.red pepper flakes, 3 tbsp.extra-virgin olive oil divide, 4 6-oz. salmon fillets, patted dry with a paper towel, Kosher salt, Freshly ground black pepper, 3 cloves garlic mince, 1 lemon sliced into rounds',
          instructions: '1. In a medium bowl, whisk together honey, soy sauce, lemon juice and red pepper flakes. \n2.In a large skillet over medium-high heat, heat two tablespoons oil. When oil is hot but not smoking, add salmon skin-side up and season with salt and pepper. Cook salmon until deeply golden, about 6 minutes, then flip over and add remaining tablespoon of oil.\n3. Add garlic to the skillet and cook until fragrant, 1 minute. Add the honey mixture and sliced lemons and cook until sauce is reduced by about 1/3. Baste salmon with the sauce.\n4. Garnish with sliced lemon and serve.',
        ),
      ],

    );
  }
}
