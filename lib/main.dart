import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
void main(){
  runApp(MaterialApp(
    home:Login(),
  
  ));

}


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

enum LoginStatus{
  notSignin,
  signin
}

class _LoginState extends State<Login> {
  LoginStatus _loginStatus = LoginStatus.notSignin;
  String email, password;
  final _key = new GlobalKey<FormState>();
  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check(){
    final form = _key.currentState;
    if(form.validate()){
      form.save();
      login();
    }
  }
  login() async {
    final response = await http.post("http://192.168.10.193/flutter/login.php",
        body: {"email": email, "password": password});
        
    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];
    
    if(value == 1){
      setState(() {
        _loginStatus = LoginStatus.signin;
        savePref(value);
      });
      
      print(pesan);
    }else{
      print(pesan);
    }
  }
  savePref(int value) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", value);
      preferences.commit();
    });
  }
  var value;
  getPref() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.get("value");

      _loginStatus = value == 1 ? LoginStatus.signin : LoginStatus.notSignin;
    });
  }
  signOut() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setString("value", null);
      preferences.commit();
      _loginStatus = LoginStatus.notSignin;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }
  @override
  Widget build(BuildContext context) {
    switch(_loginStatus){
      case LoginStatus.notSignin:
      return Scaffold(
      appBar: AppBar(
        
      ),
      body: Form(
        key: _key,
              child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              validator: (e){
                if(e.isEmpty){
                  return "isi username";
                }
              },
              onSaved: (e)=>email = e,
              decoration: InputDecoration(
                labelText: "Email"
              ),
            ),

            TextFormField(
              validator: (e){
                if(e.isEmpty){
                  return "isi password";
                }
              },
              obscureText: _secureText,
              onSaved: (e)=>password = e,
              decoration: InputDecoration(
                labelText: "Password",
              ),
            ),

          MaterialButton(
            onPressed: (){
              check();
            },
            child: Text("Login"),
          )
          ],
        ),
      ),
    );
      break;
      case LoginStatus.signin:
      return MainMenu(signOut());
      break;
    }
    
  }
}

class MainMenu extends StatefulWidget {
  final VoidCallback signOut;
  MainMenu(this.signOut);
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  signOut(){
    setState(() {
      widget.signOut;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: (){
              signOut();
            },
            icon: Icon(Icons.lock_open),
          )
        ],
      ),
      body: Center(
        child: Text('Dashboard'),
      ),
    );
  }
}