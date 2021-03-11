import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flushbar/flushbar.dart';
import 'dart:async';
import 'ingredient.dart';
import 'search.dart';

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
  GlobalKey<AutoCompleteTextFieldState<Ingredients>> key = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
            children: <Widget>[
              searchTextField = AutoCompleteTextField<Ingredients>(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                decoration: InputDecoration(
                  suffixIcon: Container(
                    width: 85.0,
                    height: 60.0,
                  ),
                  contentPadding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 20.0),
                  filled: true,
                  hintText: "Search ingredient",
                  hintStyle: TextStyle(
                      color: Colors.black
                  ),
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
                    selectedIngredientList.add(item);
                  });
                },
                key: key,
                suggestions: ingredientList,
                suggestionsAmount: 10,
              ),
              //this is where the list of ingredients is updated and displayed
              Expanded(
                  child: ListView.builder(
                    itemCount: selectedIngredientList != null ? selectedIngredientList.length : 0,
                    itemBuilder: (context, index) {
                      return ListTile(
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
                                duration: const Duration(seconds: 1),
                                content: Text('Removed ' + selectedIngredientList[index].name),
                              );
                              // and use it to show a SnackBar.
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              selectedIngredientList.removeWhere((ingredient) => ingredient.name == selectedIngredientList[index].name);
                            }
                            );
                          },
                        ),
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

// returns the user ingredient list from db if it already exist


//List the ingredients when the suggestion is tapped

class UserIngredientList extends StatelessWidget{
  static const String _title = 'My Ingredients List';

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(20),
              child: Text("List your available ingredients",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black54,
                ),
              ),
            ),
            InitiateIngredientList(),
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
