import 'package:flutter/material.dart';
import 'package:cyber_safeguard/registration_screens/login_screen.dart';
import 'package:cyber_safeguard/registration_screens/register_screem.dart';


class LoginOrRegisterPage extends StatefulWidget{

  const LoginOrRegisterPage ({super.key});

  @override
  State<LoginOrRegisterPage> createState() {
    return _LoginOrRegisterPageState();
  }
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage>{

  bool showLoginPage = true;

  void toggleScreen(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return LoginScreen(onTap: toggleScreen );
    }else{
      return RegisterScreen(
        onTap: toggleScreen,
      );
    }
  }
}