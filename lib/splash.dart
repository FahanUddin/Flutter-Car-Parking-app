import 'package:carparkapp_new/circle_transition.dart';
import 'package:carparkapp_new/main.dart';
import 'package:carparkapp_new/login_page.dart';
import 'package:flutter/material.dart';

//this is the splash screen and will show on start up
class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigatehome();
  }

  //this function navigates to the login page after a period of time
  _navigatehome() async {
    await Future.delayed(Duration(milliseconds: 1300), () {});

    Navigator.of(context).pushReplacement(_routelogin());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 26, 25, 23),
      body: Center(
        child: Text('CarPark.',
            style: TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }

  Route _routelogin() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionDuration: const Duration(milliseconds: 2500),
        reverseTransitionDuration: const Duration(milliseconds: 1300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var screenSize = MediaQuery.of(context).size;
          var centerCircular =
              Offset(screenSize.width / 2, screenSize.height / 2);

          double beginRadius = 1.0;
          double endRadius = screenSize.height * 1.1;

          var radiusTween = Tween(begin: beginRadius, end: endRadius);
          var radiusTweenAnimation = animation.drive(radiusTween);

          return ClipPath(
            child: child,
            clipper: CircleTransition(
              radius: radiusTweenAnimation.value,
              center: centerCircular,
            ),
          );
        });
  }
}
