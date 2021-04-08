import 'package:flutter/material.dart';
import 'package:quikquisine490/user.dart';
import 'recipes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
List<dynamic> recipeRatings = new List();
int recentRating;
String recentReview;
Future getReviews(int id) async{
  recipeRatings.clear();
  http.Response response = await http.get('https://quik-quisine.herokuapp.com/api/v1/recipes/'+id.toString()+'/ratings', headers: headers);
  var parsedJson = jsonDecode(response.body);
  var data = parsedJson['data'];
  recipeRatings = data;
  print('ratings data:');
  print(recipeRatings);
}
Future setReviews(int id, int rating, String review) async{
  var url = 'https://quik-quisine.herokuapp.com/api/v1/recipes/'+id.toString()+'/ratings';
  var body = {
    "user_id" :UserList[3].toString(),
    "difficulty_rating_score": 0,
    "like_rating_score": rating,
    "review": review,
  };
  //var jsonbody = {};
 // jsonbody["user"] = body;
  String msg = json.encode(body);
  http.Response response = await http.post(url,headers: headers,body: msg);
  print("Review added code:: " + response.statusCode.toString());
}
class reviewItem extends StatelessWidget {
  reviewItem({
    Key key,
    this.id,
    this.AverageRating,
    this.review
  }) : super(key: key);

  final double AverageRating;
  String review;
  final int id;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        Navigator.pop(context, false);
      },
      //child: Padding(
        //padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Container(
          margin: const EdgeInsets.all(20.0),
          height: 100,
          color: Colors.white,
          child: ListView(

            children: <Widget>[
              Text('Review: ' + review ,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                  decoration: TextDecoration.none,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text('\nRating:',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                  decoration: TextDecoration.none,
                ),
              ),
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
     // ),
    );
  }
}

Future _ackAlert(BuildContext context,double AverageRating, String review) {

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return ListView.builder(
        itemCount: recipeRatings.length,
        itemBuilder: (BuildContext context,index){
          return reviewItem(
            AverageRating: double.parse(recipeRatings[index]['like_rating_score'].toString()),
            review: recipeRatings[index]['review'],
          );

        },
      );
    },
  );
}
Future _ackAlert2(BuildContext context,int id, double AverageRating, String review)  {
  String newReview;
  int newRating;
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Leave a review'),

        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              new TextFormField(
                decoration: InputDecoration(
                    labelText: 'Type here...'
                ),
                maxLines: 5,
                onChanged: (String val) => newReview = val,
              ),
              new TextField(
                decoration: new InputDecoration(labelText: "Rate 0-5 stars"),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-5]'))
                ],
                onChanged: (String val) => newRating = int.tryParse(val),// Only numbers can be entered
                maxLength: 1,
              ),
            ],
          ),
        ),
        actions: [
          FlatButton(
            child: Text('Submit'),
            onPressed: () {
              if(newRating!=null && newReview!=null) {
                setReviews(id, newRating, newReview);
                recentRating = newRating;
                recentReview = newReview;
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

class recipedetails extends StatelessWidget {
  Widget thumbnail;
  String title;
  String subtitle;
  String instructions;
  String serving;
  String ingredients;
  String review;
  double AverageRating;
  int id;
  recipedetails(this.thumbnail, this.title, this.subtitle,this.instructions,this.serving,this.ingredients,this.id,this.AverageRating,this.review);
  @override
  Widget build(BuildContext context,) {
    getReviews(id);
    if(recentReview != null)
      review = recentReview;
    if(recentRating != null)
      AverageRating = recentRating.toDouble();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        appBar: AppBar(
            title: Text(title),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            )),
        body:
          ListView(
              children: [
                thumbnail,
                Text(title,textAlign: TextAlign.center,textScaleFactor: 2,),
                Align(
                  alignment: Alignment.center,
                  child: SmoothStarRating(
                    allowHalfRating: true,
                    starCount: 5,
                    rating: AverageRating,
                    size: 20,
                    color: Colors.amber,
                    borderColor: Colors.black,
                  ),
                ),
                Text(subtitle),
                Text(serving),
                Text(ingredients),
                Text("Instructions:\n" + instructions),
                Text("\nReviews:\n" + review),
                if(review != 'No reviews yet.')
                  FlatButton(
                    child: Text('More Reviews'),
                    onPressed: () {
                      _ackAlert(context,this.AverageRating, this.review);
                    },
                  ),
                FlatButton(
                  child: Text('Leave a Review'),
                  onPressed: (){
                    _ackAlert2(context,this.id, this.AverageRating, this.review);
                  },
                )
              ]
          )

      ),
    );
  }
}
