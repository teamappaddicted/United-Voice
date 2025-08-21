import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';



class main_Login extends StatelessWidget {
  const main_Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        
          child: Login(),
        ),
      
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    // Start the animation off-screen
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1), // Start from off-screen below
      end: Offset(0, 0), // End at the bottom of the screen
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  Future<void> SignInwithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential usercredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      print(usercredential.user?.displayName);
    } catch (e) {
      print("Error signing in with Google: $e");
    }
  }

  Future<void> signInwithGitHub() async {
    try {
      final AuthorizationServiceConfiguration serviceConfiguration =
          AuthorizationServiceConfiguration(
        authorizationEndpoint:
            Uri.parse('https://github.com/login/oauth/authorize').toString(),
        tokenEndpoint:
            Uri.parse('https://github.com/login/oauth/access_token').toString(),
      );

      final AuthorizationTokenRequest request = AuthorizationTokenRequest(
        'Ov23liTDDA68oVogboEt',
        'https://zedd-7024f.firebaseapp.com/__/auth/handler',
        clientSecret: 'a84e9f697bdc51aaf0dd69d2f4726830a4abfdae',
        scopes: ['user:email'],
        serviceConfiguration: serviceConfiguration,
      );

      final AuthorizationTokenResponse result =
          await _appAuth.authorizeAndExchangeCode(request);

      final AuthCredential credential =
          GithubAuthProvider.credential(result.accessToken!);
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      print('Signed in with GitHub: ${user?.displayName}');
    } catch (e) {
      print('Error signing in with GitHub: $e');
    }
  }

  void _toggleOverlayVisibility() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
      _isOverlayVisible
          ? _animationController.forward()
          : _animationController.reverse();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: (){_toggleOverlayVisibility();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Center(
             child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(image: AssetImage("assets/uv_logo.png"),height: screenHeight*0.2,width: screenWidth*0.2,),
                SizedBox(width: 10,),
                Text("United Voice",style: TextStyle(color: Colors.white,fontSize: 32),)
              ],
             ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom:
                  _isOverlayVisible ? 0 : -200, // Change based on visibility
              child: Container(
                padding: EdgeInsets.all(10),
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  height: 100, // Fixed height for the overlay

                  decoration: BoxDecoration(
                        border: Border.all(
      color: const Color.fromARGB(255, 66, 66, 66), // Set your desired border color here
      width: 1.0,         // Set the border width
    ),borderRadius: BorderRadius.circular(16),
                      color: Colors.transparent,
                      // gradient: LinearGradient(
                      //     colors: [Color(0xFF000928), Color(0xFF000A2C)]),
                      
                      ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(

                          color: Colors.transparent,
                            // gradient: LinearGradient(
                            //     colors: [Color(0xFF000928), Color(0xFF000A2C)]),
                               border: Border.all(
      color: const Color.fromARGB(255, 66, 66, 66), // Set your desired border color here
      width: 1.0,         // Set the border width
    ),borderRadius: BorderRadius.circular(16),
                            
                            ),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (){SignInwithGoogle();},
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16))),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent),
                            shadowColor: MaterialStateProperty.all<Color>(
                                Colors.transparent),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(onPressed: (){}, 
                              icon: FaIcon(FontAwesomeIcons.google,color: Colors.white,)),
                              const SizedBox(width: 10),
                              const Text("Continue with Google",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                     
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
