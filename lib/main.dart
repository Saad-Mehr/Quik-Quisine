import 'package:flutter/material.dart';
import 'package:quikquisine490/recipe.dart';
import 'HomePage.dart';
import 'user.dart';
import 'SignInPage.dart';
import 'search.dart';
import 'userIngredientList.dart';
import 'SearchResultsSamePage.dart';
import 'ingredient.dart';


void main() {
  runApp(MaterialApp(home:Myapp()));
}

class Myapp extends StatefulWidget {
  @override
  _MyappState createState() => _MyappState();
}

class _MyappState extends State<Myapp> {

  final TextEditingController _email_controller = TextEditingController();
  final TextEditingController _password_controller = TextEditingController();

  var statusText;
  double _opacity = 0.0;
  bool _visible = false;
  bool isLoading = false;

  void opacityAndLoading(){
    _opacity = 1;
    _visible = true;
    isLoading = false;
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: width,
                height: height*0.45,
                child: Image.asset('assets/Quik Quisine Logo.png',fit: BoxFit.fill,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Login',style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
              SizedBox(height: 10.0,),
              AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: _opacity,
                child: Column(
                        children: <Widget>[
                          Visibility(
                              child: Text(
                              '$statusText',
                              style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),),
                            visible: _visible,
                          ),
                  ],
                ),
              ),
              SizedBox(height: 15.0,),
              TextField(
                controller: _email_controller,
                decoration: InputDecoration(
                  hintText: 'Email',
                  suffixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 20.0,),
              TextField(
                controller: _password_controller,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: Icon(Icons.visibility_off),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              //SizedBox(height: 30.0,),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Forgot password?',style: TextStyle(fontSize: 12.0),),
                    isLoading ? Center(
                      child: CircularProgressIndicator(),
                    ) : new RaisedButton(
                      child: Text('Login'),
                      color: Color(0xffEE7B23),
                      onPressed: () async{


                          setState((){isLoading = true;});
                          int response_code = await LogIn(_email_controller.text, _password_controller.text);
                          if (response_code == 200)
                           {
                            //await recipes();
                            setState((){isLoading = false;});
                            await existingIngredients();
                            if(selectedIngredientList.isEmpty) {
                              Navigator.push(context,MaterialPageRoute(builder: (context) => UserIngredientList()));
                            }
                            else {
                              setState(() {
                                isRecipeListLoading = true;
                              });
                              Navigator.push(context,MaterialPageRoute(builder: (context) => BasicSearch()));
                            }
                          } else if ( response_code == 401 ) {
                            setState(() {
                              print('Status code is: $response_code');
                              statusText = 'Incorrect password';
                              opacityAndLoading();
                            });
                          } else if ( response_code == 500 ) {
                            setState(() {
                              print('Status code is: $response_code');
                              statusText = 'Email does not exist';
                              opacityAndLoading();
                            });
                          } else {
                            setState(() {
                              print('Status code is: $response_code');
                              statusText = 'Unknown error';
                              opacityAndLoading();
                            });
                          }
                        } else if ( response_code == 401 ) {
                          setState(() {
                            print('Status code is: $response_code');
                            statusText = 'Incorrect password';
                            opacityAndLoading();
                          });
                        } else if ( response_code == 500 ) {
                          setState(() {
                            print('Status code is: $response_code');
                            statusText = 'Email does not exist';
                            opacityAndLoading();
                          });
                        } else {
                          setState(() {
                            print('Status code is: $response_code');
                            statusText = 'Unknown error';
                            opacityAndLoading();
                          });
                        }
                        },
                    ),
    ],
    ),
    ),
    SizedBox(height:20.0),
    GestureDetector(
    onTap: (){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>Second()));
    },
    child: Text.rich(
    TextSpan(
    text: 'Don\'t have an account? ',
                      children: [
                        TextSpan(
                          text: 'Signup',
                          style: TextStyle(
                              color: Color(0xffEE7B23)
                          ),
                        ),
                      ]
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
