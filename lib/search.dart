import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql1Dart;
import 'package:quikquisine490/main.dart';
import 'package:quikquisine490/recipes.dart';
import 'mysql.dart';

var searchTerm = "";
List<dynamic> recipeNames = [];
List<dynamic> recipeDesc = [];
List<Map<dynamic,dynamic>> recipes = [];

class searchPage extends StatelessWidget {
  static const String _title = 'Search';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title),
            leading: IconButton(icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            )
        ),
        body:
        SearchWidget(),
      ),
    );
  }
}

class SearchWidget extends StatefulWidget {
  @override
  SearchWidgetState createState() =>
      new SearchWidgetState();
}

String get getSearchTerm{
  return searchTerm;
}

List get getRecipeNames {
  return recipeNames;
}

List get getRecipeDesc {
  return recipeDesc;
}

class SearchWidgetState extends State<SearchWidget> with TickerProviderStateMixin {

  bool isLoading = false;
  var db = new Mysql();
  final searchController = TextEditingController();

  void dispose(){
    searchController.dispose();
    super.dispose();
  }

  Future getRecipe(String searchText) async {
    recipeNames = [];
    recipeDesc = [];
    recipes = [];

    searchTerm = searchText;

    setState(() {
      isLoading = true; //Data is loading
    });

    await db.getConnection().then((conn) {
      String sql = 'select name, description from heroku_19a4bd20cf30ab1.recipes where name LIKE "%' + searchTerm + '%";';
      conn.query(sql).then((mysql1Dart.Results results) {
        results.forEach((row) {

            Map r = new Map();
            for(int i=0; i<results.fields.length; i++) {
              r[results.fields[i].name] = row[i];
            }

            recipes.add(r);
        });
      });
    });

    await Future.delayed(Duration(milliseconds: 450));

    recipes.forEach((recipe) => recipeNames.add(recipe['name']));
    recipes.forEach((recipe) => recipeDesc.add(recipe['description']));
    print(recipeNames);
    print(recipeDesc);

    setState(() {
      isLoading = false; //Data has loaded
    });
  }

  List<String> _options = [
    "Appetizer",
    "Entree",
    "Dessert",
    "Meat-lovers",
    "Vegetarian"
  ];
  List<bool> _selected = [false, false, false, false, false];

  Widget _buildChips() {
    List<Widget> chips = new List();

    for (int i = 0; i < _options.length; i++) {
      FilterChip filterChip = FilterChip(
        selected: _selected[i],
        label: Text(_options[i], style: TextStyle(color: Colors.white)),
        showCheckmark: false,
        avatar: _selected[i] ? Icon(Icons.check, color: Colors.white) : null,
        backgroundColor: Colors.black38,
        selectedColor: Colors.blue,
        onSelected: (bool selected) {
          setState(() {
            _selected[i] = selected;
          });
        },
      );

      chips.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: filterChip,
      ));
    }

    return ListView(
      scrollDirection: Axis.horizontal,
      children: chips,
      shrinkWrap: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    double width=MediaQuery.of(context).size.width;
    double height=MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.only(left: 20.0, right: 20.0),

        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 80.0,),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search recipes',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              SizedBox(height: 50.0,),
              Container(
                height: 30,
                child: _buildChips(),
              ),
              SizedBox(height: 50.0,),
              RaisedButton(
                child: Text('Search'),
                color: Color(0xff0091EA),
                textColor: Colors.white,
                onPressed: () {
                  getRecipe(searchController.text);
                  Future.delayed(Duration(milliseconds: 1000), () {
                    // 5s over, navigate to a new page
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>RecipeResultsPage()));
                  });
                },
              ),
              SizedBox(height: 50.0,),
              /*Text(
                'recipe:',
              ),
              Text(
                'recipeNames',
              )*/
            ],
          ),
        ),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }

}


Future _ackAlert(BuildContext context,Widget thumbnail, String title, String subtitle, String instructions) {
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
  }) : super(key: key);

  final Widget thumbnail;
  final String title;
  final String subtitle;
  final String instructions;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _ackAlert(context,this.thumbnail, this.title, this.subtitle, this.instructions);
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

class ResultsState extends StatefulWidget {
  @override
  ResultsWidget createState() =>
      new ResultsWidget();
}


class ResultsWidget extends State<ResultsState> {

  //ResultsWidget({Key key}) : super(key: key);

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