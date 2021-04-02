import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:quikquisine490/profile.dart';
import 'package:quikquisine490/recipe.dart';
import 'package:quikquisine490/recipes.dart';
import 'package:quikquisine490/userIngredientList.dart';
import 'calendar.dart';
import 'main.dart';
import 'package:another_flushbar/flushbar.dart';
import 'dart:async';
import 'ingredient.dart';
import 'search.dart';
import 'user.dart';

class InitiateRecipeList extends StatefulWidget {

  RecipeListState createState() => RecipeListState();

}

void clearRecipeList(){

  if(recipeList != null){
    recipeList.clear();
  }
  else{
    recipeList = [];
  }
}

class RecipeListState extends State<InitiateRecipeList> {
  @override
  void initState() {
    clearRecipeList();
    _loadAutoCompleteRecipeList();
    super.initState();
  }

  void _loadAutoCompleteRecipeList() async {
    await recipes();
  }

  @override
  Widget build(BuildContext context) {
    return AutocompleteSearch();
  }
}

class AutocompleteSearch extends StatefulWidget{
  AutocompleteSearchState createState() => AutocompleteSearchState();
}

class AutocompleteSearchState extends State<AutocompleteSearch>{

  AutoCompleteTextField searchTextField;
  TextEditingController controller = new TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<Recipes>> key = new GlobalKey();

  @override
  Widget build(BuildContext context) {

    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    return Expanded(
      child: Container(

        // height: height,
        // width: width,
        // margin: const EdgeInsets.only(left: 20.0, right: 20.0),

        child: Column(
            children: <Widget>[
              searchTextField = AutoCompleteTextField<Recipes>(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                decoration: InputDecoration(
                  hintText: 'Search recipe name',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.orange[600], width: 1.5),
                  ),
                  border: const OutlineInputBorder(),
                ),
                itemBuilder: (context, item){
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(item.name,
                        style: TextStyle(
                            fontSize: 16.0
                        ),),
                      Padding(
                        padding: EdgeInsets.all(15.0),
                      ),
                    ],
                  );
                },
                itemFilter: (item, query) {
                  return item.name
                      .toLowerCase()
                      .startsWith(query.toLowerCase());
                },
                itemSorter: (a, b) {
                  return a.name.compareTo(b.name);
                },
                itemSubmitted: (item) {
                  setState(() {
                    searchTextField.textField.controller.text = item.name;
                  });
                },
                key: key,
                suggestions: recipeList,
                suggestionsAmount: 10,
                clearOnSubmit: false,
              ),
            ]
        )
      )
    );
  }
}

class MenuOptions {
  static const String Recipes = 'Recipes';
  static const String Search = 'Search';
  static const String AdvancedSearch = 'Advanced Search';
  static const String MealPlanner = 'MealPlanner';
  static const String Profile = 'Profile';
  static const String MyIngredientList = 'My ingredients list';
  static const String Logout = 'Logout';

  static const List<String> options = <String>[
    Recipes,
    Search,
    AdvancedSearch,
    MealPlanner,
    Profile,
    MyIngredientList,
    Logout
  ];

}

class BasicSearch extends StatelessWidget{
  static const String _title = 'Search Recipes';

  Future<void> optionAction(String option, BuildContext context) async {

    if (option == MenuOptions.Recipes) {

      await getRecipes();
      recipesPageTitle = 'Recipes';
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RecipePage()),
      );
    }
    else if (option == MenuOptions.Search) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BasicSearch()),
      );
    }
    else if (option == MenuOptions.AdvancedSearch) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchPage()),
      );
    }
    else if (option == MenuOptions.MealPlanner) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    }
    else if (option == MenuOptions.Profile) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => profile()),
      );
    }
    else if (option == MenuOptions.MyIngredientList) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserIngredientList()),
      );
    }
    else if (option == MenuOptions.Logout) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Myapp()),
      );
    }
  }

  /*
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    height: height,
    width: width,
    margin: const EdgeInsets.only(left: 20.0, right: 20.0),
  */

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.deepOrangeAccent,
        actions: <Widget>[
          PopupMenuButton<String>(
              onSelected: (option) => optionAction(option, context),
              itemBuilder: (BuildContext context) {
                return MenuOptions.options.map((String option){
                  return PopupMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList();
              }
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(height: 30.0,),
            Text(
              "What would you like you create?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 30.0,),
            InitiateRecipeList(),
            RaisedButton(
              child: Text('Save'),
              color: Color(0xffEE7B23),
              onPressed: () async{
                if(selectedIngredientList != null && selectedIngredientList.isNotEmpty){
                  int response_code = await SaveIngredients();
                  if (response_code == 200)
                  {
                    Navigator.push(context,MaterialPageRoute(builder: (context) => SearchPage()));
                    Flushbar(
                      message: "Saved successfully",
                      duration:  Duration(seconds: 3),
                      backgroundColor: Colors.green,
                    )..show(context);
                  }
                }
                else{
                  // show the message that the ingredient has been removed
                  final snackBar = SnackBar(
                    content: Text('Please list your available ingredients to display your missing ingredients on recipes'),
                    backgroundColor: Colors.redAccent,
                  );
                  // and use it to show a SnackBar.
                  _scaffoldKey.currentState..showSnackBar(snackBar);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
