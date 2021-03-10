import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'main.dart';
import 'user.dart';
import 'userIngredientList.dart';

class Second extends StatefulWidget {
  @override
  _SecondState createState() => _SecondState();
}

class _SecondState extends State<Second> {
  final TextEditingController _first_name = TextEditingController();
  final TextEditingController _last_name = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password_confirm = TextEditingController();
  final TextEditingController _email_controller = TextEditingController();
  final TextEditingController _password_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width=MediaQuery.of(context).size.width;
    double height=MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
          height: height,
          width: width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 60.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Signup',style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
                TextField(
                  controller: _first_name,
                  decoration: InputDecoration(
                    hintText: 'First Name',
                    //suffixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    )
                  ),
                ),
                SizedBox(height: 20.0,),
                TextField(
                  controller: _last_name,
                  decoration: InputDecoration(
                      hintText: 'Last Name',
                      //suffixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      )
                  ),
                ),
                SizedBox(height: 20.0,),
                TextField(
                  controller: _username,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    //suffixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                SizedBox(height: 20.0,),
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
                SizedBox(height: 30.0,),
                TextField(
                  controller: _password_confirm,
                  obscureText: true,
                  decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      suffixIcon: Icon(Icons.visibility_off),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      )
                  ),
                ),
                SizedBox(height: 20.0,),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Forgot password?',style: TextStyle(fontSize: 12.0),),
                      RaisedButton(
                        child: Text('Signup'),
                        color: Color(0xffEE7B23),
                        onPressed: () async{
                          int response_code = await SignUp(_username.text, _first_name.text, _last_name.text, _email_controller.text, _password_controller.text, _password_confirm.text);
                          if (response_code == 200)
                          {
                            Navigator.push(context,MaterialPageRoute(builder: (context) => UserIngredientList()));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height:20.0),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Myapp()));
                  },
                  child: Text.rich(
                    TextSpan(
                        text: 'Already have an account? ',
                        children: [
                          TextSpan(
                            text: 'Sign in',
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
        )
    );
  }
}