import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:work_list/list_view.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work_list/login.dart';

class Homescreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Homescreen();
}

class _Homescreen extends State<Homescreen> {
  CollectionReference todosCollection =
      FirebaseFirestore.instance.collection("task_list");
  String date;
  TextEditingController titlecontoroller = TextEditingController();
  TextEditingController datecontoroller = TextEditingController();

  final _auth = FirebaseAuth.instance;
  String user_id = '';

  String user_name = '';
  String user_brith = '';
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection("user_list");

  _Homescreen() : date = DateFormat('yyyy-MM-dd').format(DateTime.now()) {
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      user_id = user.uid;
    }
  }

  void getuserdata() {
    var user = _auth.currentUser;
    if (user != null) {
      var userDoc = userCollection.where('id', isEqualTo: user_id).get().then(
          (value) => value.docs.forEach(
              (doc) => {user_name = doc['name'], user_brith = doc['birth']}));
    }
  }

  Future<void> _create() async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: TextFormField(
                      controller: titlecontoroller,
                      decoration: InputDecoration(hintText: '일정 명'),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    child: TextFormField(
                      controller: datecontoroller,
                      onTap: () async {
                        final DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        );
                        if (selectedDate != "") {
                          setState(() {
                            date = (DateFormat('yyyy-MM-dd'))
                                .format(selectedDate!);
                            datecontoroller.text = date;
                          });
                        } else {
                          setState(() {
                            date = (DateFormat('yyyy-MM-dd'))
                                .format(DateTime.now());
                            datecontoroller.text = date;
                          });
                        }
                      },
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: date,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final String title = titlecontoroller.text;
                        final String date = datecontoroller.text;
                        await todosCollection.add({
                          "id": user_id,
                          "title": title,
                          "date": date,
                          "success": false
                        });
                        titlecontoroller.text = "";
                        datecontoroller.text = "";
                        Navigator.of(context).pop();
                      },
                      child: Text('추가'),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future<void> _neverSatisfied() async {
    return showDialog<void>(
      //다이얼로그 위젯 소환
      context: context,
      barrierDismissible: false, // 다이얼로그 이외의 바탕 눌러도 안꺼지도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('제목'),
          content: SingleChildScrollView(
            child: ListBody(
              //List Body를 기준으로 Text 설정
              children: <Widget>[
                Text('Alert Dialog 입니다'),
                Text('OK를 눌러 닫습니다'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TodoList'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 0, 200, 255),
        elevation: 0.0,
        actions: <Widget>[
          Container(
              child: user_id != ""
                  ? IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('로그아웃'),
                              content: Text('정말 로그아웃 하시겠습니까?'),
                              actions: [
                                TextButton(
                                  child: Text('로그아웃'),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await _auth.signOut();
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/', (_) => false);
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Homescreen()),
                                    ).then((value) {
                                      setState(() {});
                                    });
                                  },
                                ),
                                TextButton(
                                  child: Text('취소'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.login),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Login()));
                      },
                    ))
        ],
      ),

      body: Center(
          child: user_id != ""
              ? Listview()
              : Text(
                  "로그인 해주세요",
                  style: TextStyle(fontSize: 20),
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (user_id != "") {
            _create();
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 237, 237, 237),
        foregroundColor: Colors.black,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
