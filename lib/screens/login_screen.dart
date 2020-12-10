import 'package:flutter/material.dart';
import 'package:myfirstapp_flutter/helper/widget_helper.dart';
import 'package:myfirstapp_flutter/network/network.dart';
import 'package:myfirstapp_flutter/screens/register_screen.dart';
import 'package:myfirstapp_flutter/screens/utama_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static String id = "login";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode passwordNode = FocusNode();
  Network network = Network();
  WidgetHelper helper = WidgetHelper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 350,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.red,
                              Colors.orange,
                            ]),
                        shape: BoxShape.rectangle,
                        // color: Colors.orange[900],
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(60))),
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "images/ina.png",
                          width: 150,
                          color: Colors.white,
                          height: 150,
                        ),
                        Text(
                          "inatechno",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      ],
                    )),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 30, right: 30, top: 30),
                    child: Card(
                        elevation: 7,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        child: helper.myTextFormField(
                            _email,
                            "Email",
                            false,
                            TextInputType.emailAddress,
                            "Email",
                            Icons.email,
                            validasiEmail,
                            null,
                            passwordNode,
                            false,
                            context)),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 30, right: 30, top: 10),
                    child: Card(
                        elevation: 7,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        child: helper.myTextFormField(
                            _password,
                            "Password",
                            true,
                            TextInputType.number,
                            "Password",
                            Icons.lock,
                            validasiPassword,
                            passwordNode,
                            null,
                            false,
                            context)),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 30, right: 34, top: 14),
                    child: Align(
                      child: Text(
                        "Forgot Password ?",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      alignment: Alignment.centerRight,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 50, right: 50, top: 30),
                    child: Container(
                      width: double.infinity,
                      height: 45,
                      child: RaisedButton(
                        onPressed: () {
                          cekValidasi(context);
                        },
                        color: Colors.orange,
                        child: Container(
                            child: Text(
                          "LOGIN",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account ? "),
                      GestureDetector(
                        onTap: () {
                          //perpindahan antar halaman atau scaffold
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => RegisterScreen()));
                          Navigator.pushNamed(context, RegisterScreen.id);
                        },
                        child: Text(
                          "Register",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     Text("Hi!!"),
      //     Text("iswandi saputra!!"),
      //     Text("Flutter!!"),
      //   ],
      // ),
    );
  }

  String validasiEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value.trim()))
      return 'Enter Valid Email';
    else
      return null;
  }

  String validasiPassword(String value) {
    if (value.length < 6) {
      return 'password harus lebih besar dari 5';
    } else {
      return null;
    }
  }

  void cekValidasi(BuildContext context) {
    if (_formKey.currentState.validate()) {
      network
          .loginCostumer(_email.text, _password.text, "0")
          .then((response) async {
        if (response.result == "true") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.msg),
            ),
          );
          // pindah halaman
          Navigator.pushReplacementNamed(context, UtamaScreen.id);

          //set login session
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setString("iduser", response.idUser);
          preferences.setString("token", response.token);
          preferences.setBool("sesi", true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.msg),
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal Login, Cek inputan'),
        ),
      );
    }
  }
}
