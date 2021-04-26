import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quikquisine490/userIngredientList.dart';
import 'SearchResultsSamePage.dart';
import 'search.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import "dart:core";

class Webilicious extends StatefulWidget{
  String ingredients;

  Webilicious({Key key, @required this.ingredients}) : super(key: key);
  @override
  Webby createState()=> Webby(ingredients: ingredients);
}

class Webby extends State<Webilicious>{
  String Linky = "https://walmart.com/search/?query=";
  String ingredients;
  Webby({Key key, @required this.ingredients});

  List <dynamic> list_o_missing_shit;

  void initState(){
    list_o_missing_shit = grab_missing(ingredients);
  }

  @override build(BuildContext context)
  {
    double width=MediaQuery.of(context).size.width;
    double height=MediaQuery.of(context).size.height;
    List <Widget> title = [
      Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        child: Text("Here you can buy the other ingredients you need for this recipe",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        )
      ),
    ];

    List <Widget> page = title;
    page.add(_buyin_ingredients(list_o_missing_shit));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy ingredients"),
        backgroundColor: Colors.deepOrangeAccent,
        //automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: page,
      )
    );
  }

  launchy(String ingredient) {
     FlutterWebBrowser.openWebPage
      (
        url: Linky+ingredient,
        customTabsOptions: CustomTabsOptions
          (
          urlBarHidingEnabled: true,
          colorScheme: CustomTabsColorScheme.values[1],
        )
    );
  }
  Widget _buyin_ingredients(List ingredients){
    List <Widget>ingred_widget_list = [];
    ingredients.forEach((element) {
      ingred_widget_list.add(
        Row(
          children: [
            Expanded(
              child: Text(element, textAlign: TextAlign.left, style: TextStyle(color: Colors.black)),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
            ),
            TextButton(onPressed: (){launchy(element);},
                child: Text("Buy", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.blue)
                        )
                    )
                )
            )
          ],
        )
      );
    }
    );

    Widget wigetin = Column(
      children: ingred_widget_list,
    );
    return wigetin;
  }
}
List <dynamic> grab_missing(String ingredient_list)
{
  List <dynamic> temp = ingredient_list.split("\n");
  List <dynamic> missing_ingredients = [];
  int length = temp.length;
  String value;
  var index = temp.indexOf("Missing ingredients:");
  for( int i = index+1; i< length-1; i++)
  {
    value = temp[i];
    missing_ingredients.add(value);
  }
  return missing_ingredients;
}