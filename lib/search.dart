import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql1Dart;
import 'package:quikquisine490/ingredient.dart';
import 'package:quikquisine490/recipe.dart';
import 'package:quikquisine490/recipes.dart';
import 'package:quikquisine490/searchRetrieval.dart';
import 'package:quikquisine490/user.dart';
import 'SearchResultsSamePage.dart';
import 'calendar.dart';
import 'main.dart';
import 'mysql.dart';
import 'profile.dart';
import 'userIngredientList.dart';


var searchTerm = "";
final String searchTypeTextAll = "All";
final String searchTypeTextPref = "Preference";
final String searchTypeTextCat = "Category";
final String searchTypeTextIng = "Ingredient";
final String searchTypeTextName = "Recipe";
List newCategories = [];
List newPreferences = [];
List categoryIDs = [];
List preferenceIDs = [];
bool isAnyCategoryChecked = false;
bool isAnyPreferenceChecked = false;
bool isIngredientSearch = false;
var checkedCategories = [];
var checkedPreferences = [];
List<dynamic> recipeIDs = [];
List<dynamic> recipeNames = [];
List<dynamic> recipeDesc = [];
List<dynamic> recipeServing = [];
List<dynamic> recipeChef = [];
List<dynamic> recipeIngredients = [];
List<dynamic> recipePicURLs = [];
List<dynamic> recipePrep = [];
List<dynamic> recipeRate = [];
List<dynamic> recipeReviews = [];
List<dynamic> sortedRecipeIng = [];
List<dynamic> sortedRecipeIngNames = [];
List<dynamic> filteredSortedIng = [];
List<Map<dynamic,dynamic>> ingList = [];
List<dynamic> searchedIngIDs = [];
List<dynamic> searchedIngNames = [];
List<dynamic> missingIngredients = [];
// used for storing user's list of ingredients
List<dynamic> userIngredientNamesList = [];

AutoCompleteTextField recTextField;
//TextEditingController recController = new TextEditingController();
GlobalKey<AutoCompleteTextFieldState<Ingredients>> ingredientAutoCompleteKey = new GlobalKey();

class InitRecipeList extends StatefulWidget {

  RecipesState createState() => RecipesState();
}

class InitiateIngList extends StatefulWidget {
  IngListState createState() => IngListState();
}

Future<void> clearRecipeListSamePage() async {

  if(recipeList != null){
    recipeList.clear();
  } else {
    recipeList = [];
  }
}

void clearIngredientList(){

  if(ingredientList != null){
    ingredientList.clear();
  } else {
    ingredientList = [];
  }
}

class RecipesState extends State<InitRecipeList> {
  @override
  void initState() {

    clearRecipeListSamePage();
    _loadAutoCompleteRecipeList();

    if(searchedFromOtherPg == false) {
      searchResultLabel = "Recipes based on your ingredients";
    }

    super.initState();
  }

  void _loadAutoCompleteRecipeList() async {
    print("Executing queries in recipes()");
    await recipes();
  }

  @override
  Widget build(BuildContext context) {
    return AutocompleteRecipeSearch();
  }
}

class IngListState extends State<InitiateIngList> {

  @override
  void initState() {
    clearIngredientList();

    if(ingredientList.length == 0){
      print("ingredients list length is " + ingredientList.length.toString());
      _loadAutoCompleteIngredientsList();
    }

    super.initState();
  }

  void _loadAutoCompleteIngredientsList() async {
    await ingredients();
  }

  @override
  Widget build(BuildContext context) {
    return IngAutocomplete();
  }
}

class AutocompleteRecipeSearch extends StatefulWidget{
  AutoRecipeSearchState createState() => AutoRecipeSearchState();
}

class IngAutocomplete extends StatefulWidget{
  IngAutocompleteState createState() => IngAutocompleteState();
}

class AutoRecipeSearchState extends State<AutocompleteRecipeSearch>{

  GlobalKey<AutoCompleteTextFieldState<Recipes>> recSearchKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Container(
            child: Column(
                children: <Widget>[
                  recTextField = AutoCompleteTextField<Recipes>(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 30, 10, 20),
                      hintText: 'Search recipes',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      focusColor: Colors.red,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.orange[200], width: 1.5),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    itemBuilder: (context, item){
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.0
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(15.0),
                          ),
                          Icon(
                              Icons.add_circle,
                              size: 25.0,
                              color: Colors.green[400]
                          ),
                        ],
                      );
                    },
                    itemFilter: (item, query) {
                      return item.name
                          .toLowerCase()
                          .contains(query.toLowerCase());
                    },
                    itemSorter: (a, b) {
                      return a.name.compareTo(b.name);
                    },
                    itemSubmitted: (item) {
                      setState(() {
                        recTextField.textField.controller.text = item.name;
                      });
                    },
                    key: recSearchKey,
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

class IngAutocompleteState extends State<IngAutocomplete>{
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
                        Expanded(
                          child: Text(item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16.0
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(15.0),
                        ),
                        Icon(
                            Icons.add_circle,
                            size: 25.0,
                            color: Colors.green[400]
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
                      chosenIngredients.add(item.name);
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
                    itemCount: chosenIngredients != null ? chosenIngredients.length : 0,
                    itemBuilder: (context, index) {
                      return Card(
                          child: ListTile(
                            title: Text(chosenIngredients[index]),
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
                                    content: Text('Removed ' + chosenIngredients[index]),
                                  );
                                  // and use it to show a SnackBar.
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  chosenIngredients.removeWhere((ingredient) => ingredient == chosenIngredients[index]);
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

class SearchPage extends StatelessWidget {
  static const String _title = 'Advanced Search';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(
            title: const Text(_title),
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
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            )
        ),
        body:
        SearchWidget(),
      ),
    );
  }

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
        await getSubsRecipes();
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

}

class MenuOptions {
  static const String Recipes = 'Recipes';
  static const String Search = 'Search';
  static const String AdvancedSearch = 'Advanced Search';
  static const String MealPlanner = 'MealPlanner';
  static const String Profile = 'Profile';
  static const String MyIngredientList = 'My ingredients';
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

void clearRecipeList(){

  searchTerm = "";
  recipeIDs.clear();
  recipeNames.clear();
  recipeDesc.clear();
  recipeServing.clear();
  recipeChef.clear();
  recipeIngredients.clear();
  recipePicURLs.clear();
  recipePrep.clear();
  recipeRate.clear();
  recipeReviews.clear();
  sortedRecipeIng = [];
  filteredSortedIng.clear();
  categoryIDs.clear();
  preferenceIDs.clear();
  checkedCategories.clear();
  checkedPreferences.clear();
  searchedIngIDs.clear();
  searchedIngNames.clear();
  missingIngredients.clear();
  isAnyCategoryChecked = false;
  isAnyPreferenceChecked = false;
  isIngredientSearch = false;
}

class SearchWidgetState extends State<SearchWidget> with TickerProviderStateMixin {

  bool isLoading = false;
  bool isCategoryLoading = false;
  bool isPreferenceLoading = false;
  bool isIngredientLoading = false;
  bool isCatChecked = false;
  bool isPrefChecked = false;
  //bool isUserIngListChecked = false;
  bool isAllErr = false;
  bool isIngredientErr = false;
  String errMsg = "";
  Map<String, bool> categoryMap = {};
  Map<String, bool> preferenceMap = {};
  var db = new Mysql();
  final recipesAllController = TextEditingController();
  final ingredientsAllController = TextEditingController();
  final onlyCategoriesController = TextEditingController();
  final onlyPreferencesController = TextEditingController();
  final onlyIngredientsController = TextEditingController();

  Future getIngredients() async {

    String sqlQuery = 'SELECT ingredients.id, ingredients.name ' +
        'FROM heroku_19a4bd20cf30ab1.ingredients;';

    await db.getConnection().then((conn) {

      return conn.query(sqlQuery).then((mysql1Dart.Results results) {
        results.forEach((row) {

          Map r = new Map();
          for(int i=0; i<results.fields.length; i++) {
            r[results.fields[i].name] = row[i];
          }

          ingList.add(r);
        });
      });
    });

    print('ingredientsList is ' + ingList.toString());

    setState(() {
      isIngredientLoading = false;
    });
  }

  getIngredientIds(String ingParam){

    searchedIngIDs = ingParam.split(',');

    print("searchedIngIDs in search.dart is now " + searchedIngIDs.toString());
    print("ingredientsList in search.dart is now " + ingredientList.toString());

    for(int i = 0; i < searchedIngIDs.length; i++){
      for(int j = 0; j < ingredientList.length; j++){
        if(ingredientList[j].name == searchedIngIDs[i]){

          searchedIngNames.add(ingredientList[j].id);
          searchedIngIDs[i] = ingredientList[j].id.toString();
        }
      }
    }

    print("searchedIngIDs in search.dart is now " + searchedIngIDs.toString());
    ingParam = searchedIngIDs.toString().replaceAll(new RegExp("[\\[\\]\\s]"), "");
    return ingParam;
  }

  Future sortSearchedIngredients() async {

    sortedRecipeIng.length = recipeIngredients.length;
    sortedRecipeIngNames.length = recipeIngredients.length;

    for(int i = 0; i < recipeIngredients.length; i++){

      sortedRecipeIng[i] = [];
      sortedRecipeIngNames[i] = [];
      for(int j = 0; j < recipeIngredients[i].length; j++){

        sortedRecipeIng[i].add("${recipeIngredients[i][j]['ingredient_qty']} ${recipeIngredients[i][j]['name']}\n");
        sortedRecipeIngNames[i].add("${recipeIngredients[i][j]['name']}");
      }

      filteredSortedIng.add(sortedRecipeIng[i].toString().replaceAll("[", "").replaceAll("]", "").replaceAll(",", ""));
    }

    List<dynamic> tempArr = sortedRecipeIngNames;
    List<dynamic> tempUserIng = userIngredientNamesList.map((element)=>element.toLowerCase()).toList();

    for(int i = 0; i < tempArr.length; i++) {

      if(tempUserIng.isNotEmpty){

        tempArr[i] = tempArr[i].map((element) => element.toLowerCase()).toList();
        tempArr[i].removeWhere((element) => tempUserIng.contains(element));
      }

      if( tempArr[i].isEmpty ) {

        missingIngredients.add("Missing ingredients:\n " + "You have all the ingredients!");
      } else {

        missingIngredients.add("Missing ingredients:\n " + tempArr[i].toString()
            .replaceAll("[", "").replaceAll("]", "")
            .replaceAll(",", "\n"));
      }
    }

  }

  Future metaSearch(String searchType, String searchText, String ingredientText) async {

    String linkParams = '';
    String nameParam = '';
    String prefParam = '';
    String categParam = '';
    String ingParam = '';
    String ingText = '';
    List<dynamic> tempRecipes = [];
    List<dynamic> tempIngList = [];
    userIngredientNamesList = [];
    bool alreadyAdded = false;

    print("selectedIngredientList is " + selectedIngredientList.toString());

    for(int i = 0; i < selectedIngredientList.length; i++){
      userIngredientNamesList.add(selectedIngredientList[i].name);
    }

    print("userIngredientNamesList is " + userIngredientNamesList.toString());

    if(ingredientText != null) {
      ingText = ingredientText.trim();
    }

    if ( ingText.isNotEmpty && (ingText != null) ) {

      ingText += "," + userIngredientNamesList.toString().replaceAll("[", "").replaceAll("]", "").replaceAll(", ", ",");
      alreadyAdded = true;
      print("ingText is right now " + ingText);
    }

    if( alreadyAdded == false && userIngredientNamesList.isNotEmpty && (userIngredientNamesList != null) ){

      ingText += userIngredientNamesList.toString().replaceAll("[", "").replaceAll("]", "").replaceAll(", ", ",");
      print("ingText is right now " + ingText);
    }

    userIngredientNamesList = ingText.split(',');
    print("userIngredientNamesList is now " + userIngredientNamesList.toString());

    if( searchText != null && searchText.isNotEmpty && searchType != searchTypeTextName ){

      searchTerm = searchText;
      nameParam = searchTerm;
      linkParams += '?recipe_name=$nameParam';
    }

    if(searchType == searchTypeTextAll){

      nameParam.isEmpty ? linkParams += '?search_type=All' : linkParams += '&search_type=All';

      await getCheckedCategories();
      await getCheckedPreferences();

      if(isAnyPreferenceChecked == true) {
        prefParam = preferenceIDs.toString().replaceAll(new RegExp("[\\[\\]\\s]"), "");
        linkParams += '&preferences=';
        linkParams += prefParam;
      }

      if(isAnyCategoryChecked == true) {
        categParam = categoryIDs.toString().replaceAll(new RegExp("[\\[\\]\\s]"), "");
        linkParams += '&categories=';
        linkParams += categParam;
      }

      if(ingText.isNotEmpty || selectedIngredientList.isNotEmpty){

        ingParam = getIngredientIds(ingText);
        linkParams += '&ingredients=';
        linkParams += ingParam;
      }

    } else if (searchType == searchTypeTextPref){

      nameParam.isEmpty ? linkParams += '?search_type=Preference' : linkParams += '&search_type=Preference';
      await getCheckedPreferences();

      if(isAnyPreferenceChecked == true){

        prefParam = preferenceIDs.toString().replaceAll(new RegExp("[\\[\\]\\s]"), "");
        linkParams += '&preferences=';
        linkParams += prefParam;
      }

    } else if (searchType == searchTypeTextCat){

      nameParam.isEmpty ? linkParams += '?search_type=Category' : linkParams += '&search_type=Category';
      await getCheckedCategories();

      if(isAnyCategoryChecked == true) {

        categParam = categoryIDs.toString().replaceAll(new RegExp("[\\[\\]\\s]"), "");
        linkParams += '&categories=';
        linkParams += categParam;
      }

    } else if (searchType == searchTypeTextIng){

      nameParam.isEmpty ? linkParams += '?search_type=Ingredient' : linkParams += '&search_type=Ingredient';

      if(ingText.isNotEmpty || selectedIngredientList.isNotEmpty){

        ingParam = getIngredientIds(ingText);
        linkParams += '&ingredients=';
        linkParams += ingParam;
      }
    } else if (searchType == searchTypeTextName){

      nameParam.isEmpty ? linkParams += '?search_type=Recipe' : linkParams += '&search_type=Recipe';

      categParam = categoryIDs.toString().replaceAll(new RegExp("[\\[\\]\\s]"), "");
      linkParams += '&recipe_name=';
      linkParams += searchText;

    } else {

      print('Bad searchType input');
    }

    // linkParams in advanced page is now ?search_type=Ingredient&ingredients=eggegg,21,4261,2691,3501,601,1,21,4261,2691,3501,601
    print("linkParams in advanced page is now " + linkParams);

    await recipeSearch(linkParams);

    await getSearchIng();

    searchList.forEach((searchList) => recipeIDs.add(searchList['id']));
    searchList.forEach((searchList) => recipeNames.add(searchList['name']));
    searchList.forEach((searchList) => recipeDesc.add(searchList['description']));
    searchList.forEach((searchList) => recipeServing.add(searchList['serving']));
    searchList.forEach((searchList) => recipeChef.add(searchList['username']));
    searchList.forEach((searchList) => recipeIngredients.add(searchList['list_of_ingredients']));
    searchList.forEach((searchList) => recipePicURLs.add(searchList['get_image_url']));
    searchList.forEach((searchList) => recipePrep.add(searchList['preparation']));
    searchList.forEach((searchList) => recipeRate.add(searchList['AverageRating']));
    searchList.forEach((searchList) => recipeReviews.add(searchList['review']));

    await sortSearchedIngredients();

    tempIngList = filteredSortedIng;

    for(int i = 0; i < recipeIDs.length; i++) {
      for(int j = 0; j < totalRecipes.length; j++) {
        if( recipeIDs[i] == totalRecipes[j]['id'] ) {
          tempRecipes.add(totalRecipes[j]);
        }
      }
    }

    totalRecipes = tempRecipes;
    tempIngList = filteredSortedIng;

    for (int i = 0; i < missingIngredients.length; i++) {
      filteredSortedIng[i] += "\n${missingIngredients[i]}\n";
    }

    filteredSortedTotal = filteredSortedIng;
    filteredSortedIng = tempIngList;

    recipesPageTitle = "Recipes found: " + totalRecipes.length.toString();
    //print("filteredSortedTotal is ------------------ " + filteredSortedTotal.toString());
    print("selectedIngredientList is " + selectedIngredientList.toString());

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {

    clearRecipeList();

    /*setState(() {
      isCategoryLoading = true; //Data is loading
      isPreferenceLoading = true;
      isIngredientLoading = true;
    });*/

    super.initState();

    print("categoriesList before conditional is " + categoriesList.toString());

    if(categoriesList.isEmpty || categoryMap.isEmpty){
      print("categoriesList before conditional is " + categoriesList.toString());
      setState(() {
        isCategoryLoading = true;
      });
      findCategories();
    }

    if(preferencesList.isEmpty || preferenceMap.isEmpty){
      setState(() {
        isPreferenceLoading = true;
      });
      findPreferences();
    }

    if(ingList.isEmpty){
      setState(() {
        isIngredientLoading = true;
      });
      getIngredients();
    }

    print("categoryMap inside initstate is " + categoryMap.toString());
    print('hi there');
  }

  void findCategories() async {

    int responseCode = await categories();
    print(responseCode);

    if(responseCode == 200){

      newCategories = categoriesList;

      setState(() {
        for(int i = 0; i < newCategories.length; i++){
          categoryMap.putIfAbsent(newCategories[i]['name'].toString(), () => false);
        }
      });
    } else {

      print("Error findCategories() : unauthorized");
    }

    print("categoryMap inside findcategories is " + categoryMap.toString());

    setState(() {
      isCategoryLoading = false;
    });
  }

  void findPreferences() async {

    int responseCode = await preferences();
    print(responseCode);

    if(responseCode == 200){

      newPreferences = preferencesList;

      setState(() {
        for(int i = 0; i < newPreferences.length; i++){
          preferenceMap.putIfAbsent(newPreferences[i]['name'].toString(), () => false);
        }
      });
    } else {

      print("Error findPreferences() : unauthorized");
    }

    setState(() {
      isPreferenceLoading = false;
    });
  }

  Future getCheckedCategories() async {

    categoryMap.forEach((key, value) {
      if(value == true) {
        checkedCategories.add(key);

        for(var i = 0; i < categoriesList.length; i++){
          if(categoriesList[i]['name'] == key){
            categoryIDs.add(categoriesList[i]['id']);
          }
        }

        isAnyCategoryChecked = true;
      }
    });
  }

  Future getCheckedPreferences() async {

    preferenceMap.forEach((key, value) {

      if(value == true) {

        checkedPreferences.add(key);

        for(var i = 0; i < preferencesList.length; i++){

          if(preferencesList[i]['name'] == key){

            preferenceIDs.add(preferencesList[i]['id']);
          }
        }

        isAnyPreferenceChecked = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: <Widget>[
            Container(
              constraints: BoxConstraints.expand(height: 60),
              child: TabBar(
                  labelColor: Colors.orange[900],
                  indicatorColor: Colors.orange[700],
                  tabs: [
                    Tab(
                      text: "All",
                      icon: Icon(Icons.search),
                    ),
                    Tab(
                      text: "Category",
                      icon: Icon(Icons.book),
                    ),
                    Tab(
                      text: "Preference",
                      icon: Icon(Icons.favorite),
                    ),
                    Tab(
                      text: "Ingredient",
                      icon: Icon(Icons.local_dining),
                    ),
                  ]
              ),
            ),
            Expanded(
              child: Container(
                child: TabBarView(children: [
                  Container(
                    height: height,
                    width: width,
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0),

                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 40.0,),
                          new Card(
                            //key: searchResultKey,
                            child: new Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(
                                    color: Colors.amber,
                                    width: 1.3, // Underline thickness
                                  ))
                              ),
                              child: Text(
                                "Input name (optional)",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0,),
                          InitRecipeList(),
                          SizedBox(height: 40.0,),
                          new Card(
                            //key: searchResultKey,
                            child: new Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(
                                    color: Colors.amber,
                                    width: 1.3, // Underline thickness
                                  ))
                              ),
                              child: Text(
                                "Check Categories",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0,),
                          isCategoryLoading ? Center(
                            child: CircularProgressIndicator(),
                          ) : Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Card(
                                  child: (new ListView(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    children: categoryMap.keys.map((String key) {
                                      return new CheckboxListTile(
                                        title: new Text(key, style: TextStyle(color: Colors.black54),),
                                        value: categoryMap[key],
                                        activeColor: Colors.green,
                                        checkColor: Colors.white,
                                        onChanged: (bool value) {
                                          setState(() {
                                            categoryMap[key] = value;
                                            if(categoryMap.values.contains(true)) {
                                              isCatChecked = true;
                                            } else {
                                              isCatChecked = false;
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ))
                              )
                          ),
                          SizedBox(height: 40.0,),
                          new Card(
                            //key: searchResultKey,
                            child: new Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(
                                    color: Colors.amber,
                                    width: 1.3, // Underline thickness
                                  ))
                              ),
                              child: Text(
                                "Check Preferences",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0,),
                          isPreferenceLoading ? Center(
                            child: CircularProgressIndicator(),
                          ) : Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Card(
                                  child: (new ListView(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    children: preferenceMap.keys.map((String key) {
                                      return new CheckboxListTile(
                                        title: new Text(key, style: TextStyle(color: Colors.black54),),
                                        value: preferenceMap[key],
                                        activeColor: Colors.green,
                                        checkColor: Colors.white,
                                        onChanged: (bool value) {
                                          setState(() {
                                            preferenceMap[key] = value;
                                            if(preferenceMap.values.contains(true)) {
                                              isPrefChecked = true;
                                            } else {
                                              isPrefChecked = false;
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ))
                              )
                          ),
                          SizedBox(height: 40.0,),
                          new Card(
                            //key: searchResultKey,
                            child: new Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(
                                    color: Colors.amber,
                                    width: 1.3, // Underline thickness
                                  ))
                              ),
                              child: Text(
                                "Input Ingredients",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0,),
                          isIngredientLoading ? Center(
                            child: CircularProgressIndicator(),
                          ) : Container(
                            height: 350,
                            child: InitiateIngList(),
                          ),
                          SizedBox(height: 25.0,),
                          /*new Card(
                            child: new Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(
                                    color: Colors.amber,
                                    width: 1.3, // Underline thickness
                                  ))
                              ),
                              child: new CheckboxListTile(
                                title: new Text("Search with your saved ingredients", style: TextStyle(color: Colors.black54),),
                                value: isUserIngListChecked,
                                activeColor: Colors.green,
                                checkColor: Colors.white,
                                onChanged: (bool value) {
                                  setState(() {
                                    isUserIngListChecked = value;
                                  });
                                },
                              ),
                            ),
                          ),*/
                          isAllErr ? Center(
                              child: Text(
                                errMsg,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red[400],
                                ),
                              ),
                          ) : SizedBox(height: 5.0,),
                          isLoading ? Center(
                            child: CircularProgressIndicator(),
                          ) : new RaisedButton(
                            child: Text('Search'),
                            color: Colors.orange[600],
                            textColor: Colors.white,
                            onPressed: () async {
                              setState(() {
                                isLoading = true; //Data is loading
                              });

                              errMsg = "";
                              isAllErr = false;

                              if( ( isCatChecked == false ) || ( isPrefChecked == false ) ){

                                errMsg += "Error: At least 1 category and preference box must be selected.\n\n";
                                isAllErr = true;
                                setState(() {
                                  isLoading = false; //Data is loading
                                });
                              }

                              if( selectedIngredientList.isEmpty && ingredientsAllController.text.trim().isEmpty ) {

                                errMsg += "Error: An ingredient must be entered.\n\n";
                                isAllErr = true;
                                setState(() {
                                  isLoading = false; //Data is loading
                                });
                              }

                              if( isAllErr == false ) {

                                clearResults();
                                isIngredientSearch = true;
                                print("recTextField is " + recTextField.textField.controller.text);
                                print("chosenIngredients is " + chosenIngredients.toString());
                                await metaSearch(searchTypeTextAll, recTextField.textField.controller.text, chosenIngredients.toString().replaceAll("[", "").replaceAll("]", "").replaceAll(", ", ","));
                                searchedFromOtherPg = true;
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>BasicSearch()));
                                searchResultLabel = "Advanced Search Results";
                              }
                            },
                          ),
                          SizedBox(height: 50.0,),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: height,
                    width: width,
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0),

                    child: SingleChildScrollView(
                      child: Column(
                          children: [
                            SizedBox(height: 40.0,),
                            InitRecipeList(),
                            SizedBox(height: 40.0,),
                            new Card(
                              child: new Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(
                                      color: Colors.amber,
                                      width: 1.3, // Underline thickness
                                    ))
                                ),
                                child: Text(
                                  "Categories",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0,),
                            isCategoryLoading ? Center(
                              child: CircularProgressIndicator(),
                            ) : Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Card(
                                    child: (new ListView(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      children: categoryMap.keys.map((String key) {
                                        return new CheckboxListTile(
                                          title: new Text(key, style: TextStyle(color: Colors.black54),),
                                          value: categoryMap[key],
                                          activeColor: Colors.green,
                                          checkColor: Colors.white,
                                          onChanged: (bool value) {
                                            setState(() {
                                              categoryMap[key] = value;
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ))
                                )
                            ),
                            SizedBox(height: 40.0,),
                            isLoading ? Center(
                              child: CircularProgressIndicator(),
                            ) : new RaisedButton(
                              child: Text('Search'),
                              color: Colors.orange[600],
                              textColor: Colors.white,
                              onPressed: () async {
                                setState(() {
                                  isLoading = true; //Data is loading
                                });

                                clearResults();

                                await metaSearch(searchTypeTextCat, recTextField.textField.controller.text, null);
                                searchedFromOtherPg = true;
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>BasicSearch()));
                                searchResultLabel = "Advanced Search Results";
                              },
                            ),
                          ]
                      ),
                    ),
                  ),
                  Container(
                    height: height,
                    width: width,
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0),

                    child: SingleChildScrollView(
                      child: Column(
                          children: [
                            SizedBox(height: 40.0,),
                            InitRecipeList(),
                            SizedBox(height: 40.0,),
                            new Card(
                              child: new Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(
                                      color: Colors.amber,
                                      width: 1.3, // Underline thickness
                                    ))
                                ),
                                child: Text(
                                  "Preferences",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0,),
                            isPreferenceLoading ? Center(
                              child: CircularProgressIndicator(),
                            ) : Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Card(
                                    child: (new ListView(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      children: preferenceMap.keys.map((String key) {
                                        return new CheckboxListTile(
                                          title: new Text(key, style: TextStyle(color: Colors.black54),),
                                          value: preferenceMap[key],
                                          activeColor: Colors.green,
                                          checkColor: Colors.white,
                                          onChanged: (bool value) {
                                            setState(() {
                                              preferenceMap[key] = value;
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ))
                                )
                            ),
                            SizedBox(height: 40.0,),
                            isLoading ? Center(
                              child: CircularProgressIndicator(),
                            ) : new RaisedButton(
                              child: Text('Search'),
                              color: Colors.orange[600],
                              textColor: Colors.white,
                              onPressed: () async {
                                setState(() {
                                  isLoading = true; //Data is loading
                                });

                                clearResults();

                                await metaSearch(searchTypeTextPref, recTextField.textField.controller.text, null);
                                searchedFromOtherPg = true;
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>BasicSearch()));
                                searchResultLabel = "Advanced Search Results";
                              },
                            ),
                            SizedBox(height: 40.0,),
                          ]
                      ),
                    ),
                  ),
                  Container(
                    height: height,
                    width: width,
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0),

                    child: SingleChildScrollView(
                      child: Column(
                          children: [
                            SizedBox(height: 40.0,),
                            isIngredientLoading ? Center(
                              child: CircularProgressIndicator(),
                            ) : Container(
                              height: 320,
                              child: InitiateIngList(),
                            ),
                            SizedBox(height: 25.0,),
                            /*new Card(
                              child: new Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(
                                      color: Colors.amber,
                                      width: 1.3, // Underline thickness
                                    ))
                                ),
                                child: new CheckboxListTile(
                                  title: new Text("Search with your saved ingredients", style: TextStyle(color: Colors.black54),),
                                  value: isUserIngListChecked,
                                  activeColor: Colors.green,
                                  checkColor: Colors.white,
                                  onChanged: (bool value) {
                                    setState(() {
                                      isUserIngListChecked = value;
                                      print("isUserIngListChecked is now " + isUserIngListChecked.toString());
                                    });
                                  },
                                ),
                              ),
                            ),*/
                            SizedBox(height: 5.0),
                            isIngredientErr ? Center(
                                child: Text(
                                  errMsg,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red[400],
                                  ),
                                )
                            ) : SizedBox(height: 1.0,),
                            SizedBox(height: 15.0,),
                            isLoading ? Center(
                              child: CircularProgressIndicator(),
                            ) : new RaisedButton(
                              child: Text('Search'),
                              color: Colors.orange[600],
                              textColor: Colors.white,
                              onPressed: () async {
                                setState(() {
                                  isLoading = true; //Data is loading
                                });

                                clearResults();
                                errMsg = "";
                                isIngredientErr = false;

                                if( selectedIngredientList.isEmpty && chosenIngredients.isEmpty ) {

                                  errMsg += "Please enter an ingredient";
                                  isIngredientErr = true;
                                  setState(() {
                                    isLoading = false; //Data is loading
                                  });
                                } else {

                                  isIngredientErr = false;
                                  isIngredientSearch = true;
                                  print("chosenIngredients is " + chosenIngredients.toString());
                                  await metaSearch(searchTypeTextIng, null, chosenIngredients.toString().replaceAll("[", "").replaceAll("]", "").replaceAll(", ", ","));
                                  searchedFromOtherPg = true;
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>BasicSearch()));
                                  chosenIngredients.clear();
                                  searchResultLabel = "Advanced Search Results";
                                }

                              },
                            ),
                            SizedBox(height: 40.0,),
                          ]
                      ),
                    ),
                  ),
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }

}