import 'package:flutter/material.dart';
import 'package:driverojol/helper/widget_helper.dart';
import 'package:driverojol/network/network.dart';
import 'package:driverojol/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static String id = "register";
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _nama = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode emailNode = FocusNode();
  final FocusNode phoneNode = FocusNode();
  final FocusNode passwordNode = FocusNode();
  final FocusNode fullnameNode = FocusNode();
  Network network = Network();
  WidgetHelper helper = WidgetHelper();
  bool _obsecureText = true;

  void _toogleEye() {
    setState(() {
      _obsecureText = !_obsecureText;
    });
  }

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
                            _nama,
                            "Fullname",
                            false,
                            TextInputType.text,
                            "Fullname",
                            Icons.person,
                            validasiFullname,
                            fullnameNode,
                            emailNode,
                            true,
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
                            _email,
                            "Email",
                            false,
                            TextInputType.emailAddress,
                            "Email",
                            Icons.email,
                            validasiEmail,
                            emailNode,
                            phoneNode,
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
                            _phone,
                            "Phone Number",
                            false,
                            TextInputType.phone,
                            "Phone Number",
                            Icons.call,
                            validasiPhone,
                            phoneNode,
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
                            _obsecureText,
                            TextInputType.number,
                            "Password",
                            Icons.lock,
                            validasiPassword,
                            passwordNode,
                            null,
                            false,
                            context,
                            suffix: IconButton(
                                icon: Icon(_obsecureText
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: _toogleEye))),
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
                          "REGISTER",
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
                      Text("Already a member ? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, LoginScreen.id);
                        },
                        child: Text(
                          "Login",
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

  String validasiPhone(String value) {
    if (value.length < 11) {
      return 'Phone Number harus lebih besar dari 10';
    } else {
      return null;
    }
  }

  String validasiFullname(String value) {
    if (value.length < 5) {
      return 'Fullname harus lebih besar dari 4';
    } else {
      return null;
    }
  }

  void cekValidasi(BuildContext context) {
    if (_formKey.currentState.validate()) {
      network
          .daftarCostumer(_nama.text, _email.text, _password.text, _phone.text)
          .then((response) {
        if (response.result == "true") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.msg),
            ),
          );
          //kembali kehalaman sebelumnya
          Navigator.pop(context);
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
          content: const Text('Gagal register, Cek inputan'),
        ),
      );
    }
  }
}
