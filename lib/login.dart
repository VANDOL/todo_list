import 'package:flutter/material.dart';
import 'package:work_list/home_screen.dart';
import 'package:work_list/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  String user_id = '';
  String user_pw = '';
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    FocusNode _focusNode = FocusNode();
    FocusScope.of(context).requestFocus(_focusNode);
    return Scaffold(
      appBar: AppBar(
        title: Text('Log in'),
        elevation: 0.0,
        backgroundColor: Color.fromARGB(255, 0, 200, 255),
        centerTitle: true,
      ),
      // email, password 입력하는 부분을 제외한 화면을 탭하면, 키보드 사라지게 GestureDetector 사용
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus(); // 키보드 닫기 이벤트
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 50)),
              Form(
                  child: Theme(
                data: ThemeData(
                    primaryColor: Colors.grey,
                    inputDecorationTheme: InputDecorationTheme(
                        labelStyle:
                            TextStyle(color: Colors.teal, fontSize: 15.0))),
                child: Container(
                    padding: EdgeInsets.all(40.0),
                    child: Builder(builder: (context) {
                      return Column(
                        children: [
                          TextField(
                            autofocus: true,
                            decoration: InputDecoration(labelText: '아이디'),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              user_id = value;
                            },
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextField(
                            onChanged: (value) {
                              user_pw = value;
                            },
                            decoration: InputDecoration(labelText: '비밀번호'),
                            keyboardType: TextInputType.text,
                            obscureText: true, // 비밀번호 안보이도록 하는 것
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ButtonTheme(
                                    minWidth: 100.0,
                                    height: 50.0,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          final newUser = await _auth
                                              .signInWithEmailAndPassword(
                                                  email: user_id,
                                                  password: user_pw);
                                          if (newUser.user != null) {
                                            Navigator.pushNamedAndRemoveUntil(
                                                context, '/', (_) => false);

                                            Navigator.pop(context);
                                            Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Homescreen()))
                                                .then((value) {
                                              setState(() {});
                                            });
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content:
                                                Text('아이디 또는 비밀번호 가 틀렸습니다.'),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
                                      },
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 35.0,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 134, 134, 134)),
                                    )),
                                SizedBox(
                                  height: 30,
                                ),
                                ButtonTheme(
                                    minWidth: 100.0,
                                    height: 50.0,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Sign()));
                                      },
                                      child: Text("회원가입"),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 134, 134, 134)),
                                    ))
                              ])
                        ],
                      );
                    })),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
