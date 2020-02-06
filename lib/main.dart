import 'package:flash_chat/screens/chat_screen.dart' as Chat;
import 'package:flash_chat/screens/login_screen.dart' as Login;
import 'package:flash_chat/screens/registration_screen.dart' as Registration;
import 'package:flash_chat/screens/welcome_screen.dart' as Welcome;
import 'package:flutter/material.dart';

void main() => runApp(FlashChat());

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          body1: TextStyle(color: Colors.black54),
        ),
      ),
      routes: {
        Welcome.route: (context) => Welcome.WelcomeScreen(),
        Login.route: (context) => Login.LoginScreen(),
        Registration.route: (context) => Registration.RegistrationScreen(),
        Chat.route: (context) => Chat.ChatScreen()
      },
      initialRoute: Login.route,
    );
  }
}
