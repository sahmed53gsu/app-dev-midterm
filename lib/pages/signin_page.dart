import 'package:admob_flutter/admob_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app/helper/helper_functions.dart';
import 'package:group_chat_app/pages/home_page.dart';
import 'package:group_chat_app/services/auth_service.dart';
import 'package:group_chat_app/services/database_service.dart';
import 'package:group_chat_app/shared/constants.dart';
import 'package:group_chat_app/shared/loading.dart';

import '../ad_manager.dart';

class SignInPage extends StatefulWidget {
  final Function toggleView;
  SignInPage({this.toggleView});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // text field state
  String email = '';
  String password = '';
  String error = '';

  AdmobInterstitial interstitial;
  AdmobReward reward;

  @override
  void initState(){
    super.initState();
    interstitial = AdmobInterstitial(adUnitId: AdManager.interstitialId);
    interstitial.load();
  }

  _onSignIn() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      await _auth.signInWithEmailAndPassword(email, password).then((result) async {
        if (result != null) {
          QuerySnapshot userInfoSnapshot = await DatabaseService().getUserData(email);

          await HelperFunctions.saveUserLoggedInSharedPreference(true);
          await HelperFunctions.saveUserEmailSharedPreference(email);
          await HelperFunctions.saveUserNameSharedPreference(
            userInfoSnapshot.documents[0].data['fullName']
          );

          print("Signed In");
          await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
            print("Logged in: $value");
          });
          await HelperFunctions.getUserEmailSharedPreference().then((value) {
            print("Email: $value");
          });
          await HelperFunctions.getUserNameSharedPreference().then((value) {
            print("Full Name: $value");
          });

          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
        }
        else {
          setState(() {
            error = 'Error signing in!';
            _isLoading = false;
          });
        }
      });
    }
  }

  _anonSignin() async {
    String email = "";
    String fullName = "Anonymous";
    String password = "";
    await _auth.signInAnon(fullName, email, password).then((result) async{
      if (result != null) {
          await HelperFunctions.saveUserLoggedInSharedPreference(true);
          await HelperFunctions.saveUserEmailSharedPreference(email);
          await HelperFunctions.saveUserNameSharedPreference(fullName);

          print("Registered");
          await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
            print("Logged in: $value");
          });
          await HelperFunctions.getUserEmailSharedPreference().then((value) {
            print("Email: $value");
          });
          await HelperFunctions.getUserNameSharedPreference().then((value) {
            print("Full Name: $value");
          });

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
      }
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return _isLoading ? Loading() : Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          color: Colors.black,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Create or Join Groups", style: TextStyle(color: Colors.white, fontSize: 40.0, fontWeight: FontWeight.bold)),
                
                  SizedBox(height: 30.0),
                
                  Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 25.0)),

                  SizedBox(height: 20.0),
                
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: textInputDecoration.copyWith(labelText: 'Email'),
                    validator: (val) {
                      return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val) ? null : "Please enter a valid email";
                    },
                  
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                  ),
                
                  SizedBox(height: 15.0),
                
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: textInputDecoration.copyWith(labelText: 'Password'),
                    validator: (val) => val.length < 6 ? 'Password not strong enough' : null,
                    obscureText: true,
                    onChanged: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                  ),
                
                  SizedBox(height: 20.0),
                
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: RaisedButton(
                      elevation: 0.0,
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      child: Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 16.0)),
                      onPressed: () async{
                        if(await interstitial.isLoaded){
                              interstitial.show();
                          }
                        _onSignIn();
                      }
                    ),
                  ),
                
                  SizedBox(height: 10.0),

                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: RaisedButton(
                      elevation: 0.0,
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      child: Text('Sign In Anonymously', style: TextStyle(color: Colors.white, fontSize: 16.0)),
                      onPressed: ()  async {
                        if(await interstitial.isLoaded){
                              interstitial.show();
                          }
                        _anonSignin(); 
                      }
                    ),
                  ),
                
                  SizedBox(height: 10.0),
                  
                  Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Register here',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            widget.toggleView();
                          },
                        ),
                      ],
                    ),
                  ),
                
                  SizedBox(height: 10.0),
                
                  Text(error, style: TextStyle(color: Colors.red, fontSize: 14.0)),

                  AdmobBanner(adUnitId: AdManager.bannerId, adSize: AdmobBannerSize.BANNER)
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}
