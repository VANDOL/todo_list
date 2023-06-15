import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Sign extends StatefulWidget {
  @override
  State<Sign> createState() => _SignState();
}

class _SignState extends State<Sign> {
  String user_id = '';
  String user_pw = '';
  String user_name = '';
  String user_birth = '';
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection("user_list");

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
        elevation: 0.0,
        backgroundColor: Color.fromARGB(255, 0, 200, 255),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
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
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty || value.contains('@')) {
                                return '이메일 형식으로 작성해주세요';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              user_id = value;
                            },
                            onSaved: (value) {
                              user_id = value!;
                            },
                            autofocus: true,
                            decoration: InputDecoration(labelText: '아이디'),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            obscureText: true,
                            onChanged: (value) {
                              user_pw = value;
                            },
                            onSaved: (value) {
                              user_pw = value!;
                            },
                            autofocus: true,
                            decoration: InputDecoration(labelText: '비밀번호'),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            onChanged: (value) {
                              user_name = value;
                            },
                            onSaved: (value) {
                              user_name = value!;
                            },
                            autofocus: true,
                            decoration: InputDecoration(labelText: '이름'),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            onChanged: (value) {
                              user_birth = value;
                            },
                            onSaved: (value) {
                              user_birth = value!;
                            },
                            autofocus: true,
                            decoration: InputDecoration(labelText: '생년월일'),
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          ButtonTheme(
                              minWidth: 100.0,
                              height: 50.0,
                              child: TextButton(
                                onPressed: () async {
                                  try {
                                    final newUser = await _auth
                                        .createUserWithEmailAndPassword(
                                            email: user_id, password: user_pw);

                                    final user = newUser.user;
                                    if (user != null) {
                                      await userCollection.add({
                                        "id": user.uid,
                                        "name": user_name,
                                        'birth': user_birth,
                                      });
                                      Navigator.pop(
                                        context,
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('이메일과 비밀번호를 확인하세요'),
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
                                    backgroundColor:
                                        Color.fromARGB(255, 134, 134, 134)),
                              ))
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
