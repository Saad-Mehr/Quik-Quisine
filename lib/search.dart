import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql1Dart;
import 'package:quikquisine490/recipes.dart';
import 'package:quikquisine490/searchRetrieval.dart';
import 'mysql.dart';

var searchTerm = "";
final String searchTypeTextAll = "All";
final String searchTypeTextPref = "Preference";
final String searchTypeTextCat = "Category";
final String searchTypeTextIng = "Ingredient";
List newCategories = [];
List newPreferences = [];
List categoryIDs = [];
List preferenceIDs = [];
bool isAnyCategoryChecked = false;
bool isAnyPreferenceChecked = false;
var checkedCategories = [];
var checkedPreferences = [];
List<dynamic> recipeIDs = [];
List<dynamic> recipeNames = [];
List<dynamic> recipeDesc = [];
List<dynamic> recipeServing = [];
List<dynamic> recipeIngredients = [];
List<dynamic> recipePicURLs = [];
List<dynamic> recipePrep = [];
List<dynamic> sortedRecipeIng = [];
List<dynamic> filteredSortedIng = [];
List<Map<dynamic,dynamic>> ingredientsList = [];
List<dynamic> searchedIngredients = [];

class SearchPage extends StatelessWidget {
  static const String _title = 'Search';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(
            title: const Text(_title),
            backgroundColor: Colors.deepOrangeAccent,
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
  recipeIngredients.clear();
  recipePicURLs.clear();
  recipePrep.clear();
  sortedRecipeIng = [];
  filteredSortedIng.clear();
  categoryIDs.clear();
  preferenceIDs.clear();
  checkedCategories.clear();
  checkedPreferences.clear();
  searchedIngredients.clear();
  isAnyCategoryChecked = false;
  isAnyPreferenceChecked = false;
}

class SearchWidgetState extends State<SearchWidget> with TickerProviderStateMixin {

  bool isLoading = false;
  bool isCategoryLoading = false;
  bool isPreferenceLoading = false;
  bool isIngredientLoading = false;
  bool isIngredientErr = false;
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

          ingredientsList.add(r);
        });
      });
    });

    print('ingredientsList is ' + ingredientsList.toString());

    setState(() {
      isIngredientLoading = false;
    });
  }

  getIngredientIds(String ingParam){

    searchedIngredients = ingParam.split(',');

    for(int i = 0; i < searchedIngredients.length; i++){
      for(int j = 0; j < ingredientsList.length; j++){
        if(ingredientsList[j]['name'] == searchedIngredients[i]){

          searchedIngredients[i] = ingredientsList[j]['id'].toString();
        }
      }
    }

    ingParam = searchedIngredients.toString().replaceAll(new RegExp("[\\[\\]\\s]"), "");
    return ingParam;
  }

  Future sortSearchedIngredients() async {

    sortedRecipeIng.length = recipeIngredients.length;

    for(int i = 0; i < recipeIngredients.length; i++){
      sortedRecipeIng[i] = [];
      for(int j = 0; j < recipeIngredients[i].length; j++){

        sortedRecipeIng[i].add("${recipeIngredients[i][j]['ingredient_qty']} ${recipeIngredients[i][j]['name']}\n");
      }
      filteredSortedIng.add(sortedRecipeIng[i].toString().replaceAll("[", "").replaceAll("]", "").replaceAll(",", ""));
    }
  }

  Future metaSearch(String searchType, String searchText, String ingredientText) async {

    String linkParams = '';
    String nameParam = '';
    String prefParam = '';
    String categParam = '';
    String ingParam = '';

    if(searchText != null && searchText.isNotEmpty){

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

      if(ingredientText.isNotEmpty){

        ingParam = getIngredientIds(ingredientText.split(" ").join(""));
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

      if(ingredientText.isNotEmpty){

        ingParam = getIngredientIds(ingredientText.split(" ").join(""));
        linkParams += '&ingredients=';
        linkParams += ingParam;
      }
    } else {

      print('Bad searchType input');
    }

    await recipeSearch(linkParams);

    searchList.forEach((searchList) => recipeIDs.add(searchList['id']));
    searchList.forEach((searchList) => recipeNames.add(searchList['name']));
    searchList.forEach((searchList) => recipeDesc.add(searchList['description']));
    searchList.forEach((searchList) => recipeServing.add(searchList['serving']));
    searchList.forEach((searchList) => recipeIngredients.add(searchList['list_of_ingredients']));
    searchList.forEach((searchList) => recipePicURLs.add(searchList['get_image_url']));
    searchList.forEach((searchList) => recipePrep.add(searchList['preparation']));

    await sortSearchedIngredients();

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {

    clearRecipeList();
    ingredientsList.clear();

    setState(() {
      isCategoryLoading = true; //Data is loading
      isPreferenceLoading = true;
      isIngredientLoading = true;
    });

    super.initState();
    findCategories();
    findPreferences();
    getIngredients();
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

      print("new categories of length ${newCategories.length} are: " + newCategories[1]['name'].toString());
      print("categoryMap is: " + categoryMap.toString());
    } else {
      print("Error: unauthorized");
    }

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

      print("new preferences of length ${newPreferences.length} are: " + newPreferences[1]['name'].toString());
      print("preferenceMap is: " + preferenceMap.toString());
    } else {
      print("Error: unauthorized");
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

    /*print(checkedCategories);
    print('category ids are : ' + categoryIDs.toString());
    print(categoryMap.keys);*/
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

    /*print(checkedPreferences);
    print('preference ids are : ' + preferenceIDs.toString());
    print('isAnyPreferenceChecked? : ' + isAnyPreferenceChecked.toString());
    print(preferenceMap.keys);*/
  }

  @override
  Widget build(BuildContext context) {
    double width=MediaQuery.of(context).size.width;
    double height=MediaQuery.of(context).size.height;

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
                          TextField(
                            controller: recipesAllController,
                            decoration: InputDecoration(
                              hintText: 'Search recipes',
                              prefixIcon: Icon(Icons.search),
                              isDense: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.orange[600], width: 1.5),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 40.0,),
                          Text(
                            "Categories",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
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
                          Text(
                            "Preferences",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
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
                          Text(
                            "Ingredients",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 50.0,),
                          isIngredientLoading ? Center(
                            child: CircularProgressIndicator(),
                          ) : new TextField(
                            controller: ingredientsAllController,
                            decoration: InputDecoration(
                              hintText: 'Search ingredients',
                              prefixIcon: Icon(Icons.search),
                              isDense: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.orange[600], width: 1.5),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 50.0,),
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

                              await metaSearch(searchTypeTextAll, recipesAllController.text, ingredientsAllController.text);
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>RecipeResultsPage()));
                            },
                          ),
                          SizedBox(height: 50.0,),
                          RaisedButton(
                            child: Text(" Get Checked Checkbox Items ", style: TextStyle(fontSize: 20),),
                            onPressed: getCheckedCategories,
                            color: Colors.green,
                            textColor: Colors.white,
                            splashColor: Colors.grey,
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          ),
                          SizedBox(height: 40.0,),
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
                            TextField(
                              controller: onlyCategoriesController,
                              decoration: InputDecoration(
                                hintText: 'Search recipes',
                                prefixIcon: Icon(Icons.search),
                                isDense: true,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.orange[600], width: 1.5),
                                ),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 40.0,),
                            Text(
                              "Categories",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
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
                            SizedBox(height: 50.0,),
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

                                await metaSearch(searchTypeTextCat, onlyCategoriesController.text, null);
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>RecipeResultsPage()));
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
                            TextField(
                              controller: onlyPreferencesController,
                              decoration: InputDecoration(
                                hintText: 'Search recipes',
                                prefixIcon: Icon(Icons.search),
                                isDense: true,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.orange[600], width: 1.5),
                                ),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 40.0,),
                            Text(
                              "Preferences",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
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
                            SizedBox(height: 50.0,),
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

                                await metaSearch(searchTypeTextPref, onlyPreferencesController.text, null);
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>RecipeResultsPage()));
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
                            isIngredientLoading ? Center(
                              child: CircularProgressIndicator(),
                            ) : new TextField(
                              controller: onlyIngredientsController,
                              decoration: InputDecoration(
                                hintText: 'Search ingredients',
                                prefixIcon: Icon(Icons.search),
                                isDense: true,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.orange[600], width: 1.5),
                                ),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 25.0,),
                            isIngredientErr ? Center(
                              child: Text(
                                "Error: Please enter an ingredient",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red[400],
                                ),
                              )
                            ) : SizedBox(height: 21.0,),
                            SizedBox(height: 25.0,),
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

                                if(onlyIngredientsController.text.trim() == ''){
                                  isIngredientErr = true;
                                  setState(() {
                                    isLoading = false; //Data is loading
                                  });
                                } else {
                                  isIngredientErr = false;
                                  await metaSearch(searchTypeTextIng, null, onlyIngredientsController.text);
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>RecipeResultsPage()));
                                }

                              },
                            ),
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