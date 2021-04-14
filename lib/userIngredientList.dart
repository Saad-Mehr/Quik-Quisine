import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:quikquisine490/SearchResultsSamePage.dart';
import 'package:quikquisine490/profile.dart';
import 'package:quikquisine490/recipes.dart';
import 'calendar.dart';
import 'main.dart';
import 'user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'dart:async';
import 'ingredient.dart';
import 'search.dart';
import 'SearchResultsSamePage.dart';

// class RIKeys {
//   static final GlobalKey<AutoCompleteTextFieldState<Ingredients>> ingredientAutoCompleteKey = new GlobalKey();
// }
// this is a global key for the autocomplete in the what's in your kitchen page
GlobalKey<AutoCompleteTextFieldState<Ingredients>> ingredientAutoCompleteKey = new GlobalKey();
// issue with the global key, multiple widget are using it
class InitiateIngredientList extends StatefulWidget {

  IngredientListState createState() => IngredientListState();

}

void clearIngredientAndExistingIngredientList(){
  if(selectedIngredientList != null){
    selectedIngredientList.clear();
  }
  else{
    selectedIngredientList = new List<Ingredients>();
  }

  if(ingredientList != null){
    ingredientList.clear();
  }
  else{
    ingredientList = new List<Ingredients>();
  }
}

class IngredientListState extends State<InitiateIngredientList> {

  @override
  void initState() {
    clearIngredientAndExistingIngredientList();
    _loadAutoCompleteIngredientsList();
    _loadExistingIngredientsList();
    super.initState();

    // // focus on the ingredient autocomplete bar after it builds
    // WidgetsBinding.instance.addPostFrameCallback((_) => FocusScope.of(context)
    //     .requestFocus(ingredientAutoCompleteKey .currentState.textField.focusNode));
  }

  void _loadExistingIngredientsList() async {
    await existingIngredients();
    //once the existing user list is updated the set state is trigger to rebuild the page
    setState((){
    });
  }
  void _loadAutoCompleteIngredientsList() async {
    await ingredients();
  }

  @override
  Widget build(BuildContext context) {
    return AutocompleteSearch();
  }
}
////////////////////////////////////////////////////////////////////////////////

//this is for the autocomplete search bar//////////////////////////////////////
class AutocompleteSearch extends StatefulWidget{
  AutocompleteSearchState createState() => AutocompleteSearchState();
}

class AutocompleteSearchState extends State<AutocompleteSearch>{
  AutoCompleteTextField searchTextField;
  TextEditingController controller = new TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<Ingredients>> ingredientAutoCompleteKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
            children: <Widget>[
              SizedBox(
                width: 300,
                child: searchTextField = AutoCompleteTextField<Ingredients>(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      width: 85.0,
                      height: 60.0,
                        child: Icon(Icons.add)
                    ),
                    contentPadding: EdgeInsets.fromLTRB(10, 30, 10, 20),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Ex: Tomatoes",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange[700]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  itemBuilder: (context, item){
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(item.name,
                          style: TextStyle(
                              fontSize: 16.0
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(15.0),
                        ),
                        Icon(
                            Icons.add_circle,
                            size: 25.0,
                            color: Colors.green
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
                      selectedIngredientList.add(item);
                    });
                  },
                  key: ingredientAutoCompleteKey,
                  suggestions: ingredientList,
                  suggestionsAmount: 10,
                ),
              ),

              //this is where the list of ingredients is updated and displayed
              Expanded(
                  child: ListView.builder(
                    itemCount: selectedIngredientList != null ? selectedIngredientList.length : 0,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(selectedIngredientList[index].name),
                          trailing: IconButton(
                            icon: Icon(
                                Icons.delete,
                                size: 25.0,
                                color: Colors.red
                            ),
                            onPressed:(){
                              // this is where we update the list when an ingredient is deleted
                              setState(() {
                                // show the message that the ingredient has been removed
                                final snackBar = SnackBar(
                                  duration: const Duration(milliseconds: 500),
                                  content: Text('Removed ' + selectedIngredientList[index].name),
                                );
                                // and use it to show a SnackBar.
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                selectedIngredientList.removeWhere((ingredient) => ingredient.name == selectedIngredientList[index].name);
                              }
                              );
                            },
                          ),
                        )
                      );
                    },
                  )
              )
            ]
        )
    );
  }
}
///////////////////////////////////////////////////////////////////////////////

class MenuOptions {
  static const String Recipes = 'Recipes';
  static const String Search = 'Search';
  static const String AdvancedSearch = 'Advanced Search';
  static const String MealPlanner = 'MealPlanner';
  static const String Profile = 'Profile';
  static const String MyIngredientList = 'My ingredients';
  static const String Logout = 'Logout';

  static const List<String> options = <String>[
    //Recipes,
    Search,
    AdvancedSearch,
    MealPlanner,
    Profile,
    MyIngredientList,
    Logout
  ];

}

///////////////////////////////////////////////////////////////////////////////

// returns the user ingredient list from db if it already exist


//List the ingredients when the suggestion is tapped

class UserIngredientList extends StatelessWidget{
  static const String _title = 'My Ingredients';

  Future<void> optionAction(String option, BuildContext context) async {

    if (option == MenuOptions.Recipes) {
      await getRecipes();
      //filteredSortedIng.clear();
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
            Container(
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange[700]),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Text("What's in your kitchen?",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.orange[700],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(10),
              child: Text("Add ingredients to help us find recipes for you",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            InitiateIngredientList(),
            RaisedButton(
              child: Text('Search'),
              color: Color(0xffEE7B23),
              onPressed: () async{
                if(selectedIngredientList != null && selectedIngredientList.isNotEmpty){
                  int response_code = await SaveIngredients();
                  if (response_code == 200)
                  {
                    Navigator.push(context,MaterialPageRoute(builder: (context) => BasicSearch()));
                  }
                }
                else{
                  // show the message that the ingredient has been removed
                  final snackBar = SnackBar(
                    content: Text('Please add your ingredients'),
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