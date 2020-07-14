import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cowith19/covid.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
//import 'package:flutter/services.dart';

void main() {
  Intl.defaultLocale = "th";
  initializeDateFormatting();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void initState() {
    super.initState();
    _auth.currentUser().then((user) {
      if (user != null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return Covid19();
        }));
      }
    });
  }

  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  void _createUser({String email, String password}) {
    _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      print('Success register' + value.user.toString());
    }).catchError((onError) {
      print(onError);
    });
  }

  void _login({String email, String password}) {
    _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      print('Success login');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Covid19();
      }));
    }).catchError((onError) {
      if (onError.toString().contains("WRONG_PASSWORD")) {
        return AlertDialog(
          title: Text('รหัสผิด'),
        );
      }
    });
  }

  Widget loginBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [
          Colors.deepPurple[300],
          Colors.purple[300],
          Colors.deepPurple[200]
        ]),
      ),
    );
  }

  Widget inputText(TextEditingController controller, String label, String hint,
      Icon icon, bool obsecure) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
          ),
          TextFormField(
            validator: (value) {
              if (value.isEmpty || value.length < 6)
                return 'this is not correct';
              // return '';
            },
            controller: controller,
            obscureText: obsecure,
            decoration: InputDecoration(
              //border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              fillColor: Colors.white,
              //filled: true,
              hintText: hint,
              prefixIcon: icon,

              //icon: Icon(Icons.person,size: 40,)
            ),
          ),
        ],
      ),
    );
  }

  Widget loginBox() {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Padding(
          //     padding: EdgeInsets.only(top: 10),
          //     child: Text(
          //   '\nLogin Page',
          //   style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
          // )),
          Container(
            margin: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height / 4,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.6),
                image: DecorationImage(
                    image: Image.asset('assets/picture/login.png').image)),
          ),
          Container(
            //height: 400,
            margin: EdgeInsets.only(top: 0, left: 20, right: 20),
            decoration: BoxDecoration(
              //boxShadow: [BoxShadow(color: Colors.black26,offset: Offset.fromDirection(-5,9), blurRadius: 3)],
              color: Colors.white.withOpacity(0.0),
              //border: Border.all(color: Colors.deepPurple[200].withOpacity(0.3), width: 5),
              //borderRadius: BorderRadius.circular(10)
            ),

            child: Form(
              key: formKey,
              child: Column(
                children: [
                  inputText(username, 'E-mail', 'example@hotmail.com',
                      Icon(Icons.person, size: 33), false),
                  inputText(password, 'Password', 'p@ssw0rd',
                      Icon(Icons.lock, size: 30), true),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      FlatButton(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 22, color: Colors.green[700]),
                          ),
                          height: 55,
                          width: 170,
                          margin: EdgeInsets.only(bottom: 8, top: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset.fromDirection(-5, 5),
                                    blurRadius: 3)
                              ]),
                        ),
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            formKey.currentState.save();
                            _login(
                                email: username.text, password: password.text);
                          }
                        },
                      ),
                      FlatButton(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Register',
                            style: TextStyle(fontSize: 22, color: Colors.white),
                          ),
                          height: 55,
                          //width: 130,
                          margin: EdgeInsets.only(
                            bottom: 8,
                            top: 10,
                          ),
                          decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset.fromDirection(-5, 5),
                                    blurRadius: 3)
                              ]),
                        ),
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            formKey.currentState.save();
                            _createUser(
                                email: username.text, password: password.text);
                          }
                        },
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                      'or',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                  FlatButton(
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: Image.asset('assets/picture/fb.png')
                                        .image)),
                          ),
                          Text(
                            'Sign in with Facebook',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                      height: 55,
                      margin: EdgeInsets.only(
                        bottom: 8,
                        top: 10,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset.fromDirection(-5, 5),
                                blurRadius: 3)
                          ]),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Center(
            child: Stack(
              children: <Widget>[
                loginBackground(),
                loginBox(),
              ],
            ),
          ),
        ));
  }
}
