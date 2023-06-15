import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Listview extends StatefulWidget {
  const Listview({
    Key? key,
  }) : super(key: key);

  @override
  _ListviewState createState() => _ListviewState();
}

class _ListviewState extends State<Listview> {
  CollectionReference todosCollection =
      FirebaseFirestore.instance.collection("task_list");

  TextEditingController titlecontoroller = TextEditingController();
  TextEditingController datecontoroller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String user_id = '';

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      user_id = user.uid;
    }
  }

  Future<void> _success_ok(DocumentSnapshot documentSnapshot) async {
    final String title = documentSnapshot['title'];
    final String date = documentSnapshot['date'];
    await todosCollection
        .doc(documentSnapshot.id)
        .update({"title": title, "date": date, "success": true});
  }

  Future<void> _success_no(DocumentSnapshot documentSnapshot) async {
    final String title = documentSnapshot['title'];
    final String date = documentSnapshot['date'];
    await todosCollection
        .doc(documentSnapshot.id)
        .update({"title": title, "date": date, "success": false});
  }

  Future<void> _update(DocumentSnapshot documentSnapshot) async {
    titlecontoroller.text = documentSnapshot['title'];
    datecontoroller.text = documentSnapshot['date'];
    String date = datecontoroller.text;

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
                    child: TextField(
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
                          initialDate: DateFormat('yyyy-MM-dd').parse(date),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            date =
                                (DateFormat('yyyy-MM-dd')).format(selectedDate);
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
                        await todosCollection.doc(documentSnapshot.id).update({
                          "id": user_id,
                          "title": title,
                          "date": date,
                          "success": documentSnapshot['success']
                        });
                        titlecontoroller.text = "";
                        datecontoroller.text = "";
                        Navigator.of(context).pop();
                      },
                      child: Text('변경'),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> _delete(String task_id) async {
    await todosCollection.doc(task_id).delete();
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: todosCollection.where('id', isEqualTo: user_id).snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
                scrollDirection:
                    Axis.vertical, //vertical : 수직으로 나열 / horizontal : 수평으로 나열
                itemCount: streamSnapshot.data!.docs.length, //리스트의 개수
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  //리스트의 반목문 항목 형성
                  return Container(
                    height: 70,
                    alignment: Alignment.center,
                    child: Card(
                        child: ListTile(
                      title: Text(documentSnapshot['title']),
                      subtitle: Text(documentSnapshot['date']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                if (documentSnapshot['success']) {
                                  _success_no(documentSnapshot);
                                } else {
                                  _success_ok(documentSnapshot);
                                }
                              },
                              icon: Icon(
                                documentSnapshot['success']
                                    ? Icons.done
                                    : Icons.close,
                                color: documentSnapshot['success']
                                    ? Colors.green
                                    : null,
                              )),
                          IconButton(
                              onPressed: () {
                                _update(documentSnapshot);
                              },
                              icon: Icon(Icons.edit)),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('삭제'),
                                    content: Text('정말 삭제 하시겠습니까?'),
                                    actions: [
                                      TextButton(
                                        child: Text('삭제'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _delete(documentSnapshot.id);
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
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    )),
                  );
                });
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
