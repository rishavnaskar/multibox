import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'add_task_screen.dart';

String phoneNo;
List<String> tasks = [];
List<bool> checkValues = [];
ListView listView = ListView();

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await FirebaseAuth.instance.currentUser();
      if (user != null) {
        setState(() {
          phoneNo = user.phoneNumber;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[400],
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.deepPurple[400], Color(0xff6B63FF)],
                      begin: Alignment.topRight),
                ),
                child: TaskStream(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskStream extends StatefulWidget {
  @override
  _TaskStreamState createState() => _TaskStreamState();
}

class _TaskStreamState extends State<TaskStream> {
  bool isDeleted = false;

  void refresh(AsyncSnapshot snapshot) {
    final records = snapshot.data.documents;
    for (var record in records) {
      if (record.data['tasks'].length == null || record.data['tasks'] == 0) {
        return null;
      } else if (record.data['phone'] == phoneNo) {
        int len = record.data['tasks'].length, cnt = 0;
        for (int i = 0; i < len; i++) {
          if (tasks.length > 0) {
            for (int j = 0; j < tasks.length; j++) {
              if (record.data['tasks'][i] == tasks[j]) cnt++;
            }
            if (cnt == 0) {
              tasks.add(record.data['tasks'][i]);
              checkValues.add(record.data['checkvalues'][i]);
            }
          } else {
            tasks.add(record.data['tasks'][i]);
            checkValues.add(record.data['checkvalues'][i]);
          }
        }
      }
    }
  }

  void deleteRecordsSelected(int index) async {
    final records =
        await Firestore.instance.collection('records').getDocuments();
    setState(() {
      for (var record in records.documents) {
        if (record.data['phone'] == phoneNo) {
          Firestore.instance
              .collection('records')
              .document('$phoneNo')
              .updateData({
            'tasks': FieldValue.delete(),
            'checkvalues': FieldValue.delete(),
          });
          int len = tasks.length;
          for (int i = 0; i < len; i++) {
            Firestore.instance
                .collection('records')
                .document('$phoneNo')
                .updateData({
              'tasks': FieldValue.arrayUnion([tasks[i]]),
              'checkvalues': checkValues,
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('records').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Color(0xff520935),
            ),
          );
        }

        final records = snapshot.data.documents;
        for (var record in records) {
          if (record.data['phone'] == phoneNo) {
            if (record.data['tasks'] == null) {
              break;
            } else {
              refresh(snapshot);
            }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 15.0),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1.0,
                  blurRadius: 50.0,
                ),
              ]),
              child: Icon(Icons.list, color: Colors.white, size: 40.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 30.0),
                  child: Text(
                    'Todo List',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(child: SizedBox(height: 10.0)),
                IconButton(
                  icon: Icon(Icons.add),
                  iconSize: 30.0,
                  color: Colors.white,
                  onPressed: () async {
                    final resultText = await showModalBottomSheet(
                        context: context,
                        builder: (context) => AddTaskScreen(),
                        isScrollControlled: true);
                    setState(() {
                      tasks.add(resultText);
                      checkValues.add(false);
                      Firestore.instance
                          .collection('records')
                          .document('$phoneNo')
                          .updateData({
                        'tasks': FieldValue.arrayUnion([resultText]),
                        'checkvalues': FieldValue.delete(),
                      });
                      Firestore.instance
                          .collection('records')
                          .document('$phoneNo')
                          .updateData({
                        'checkvalues': checkValues,
                      });
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  color: Colors.white,
                  iconSize: 30.0,
                  onPressed: () {
                    setState(() {
                      isDeleted = true;
                      Firestore.instance
                          .collection('records')
                          .document('$phoneNo')
                          .updateData({
                        'tasks': FieldValue.delete(),
                        'checkvalues': FieldValue.delete(),
                      });
                      tasks.clear();
                      checkValues.clear();
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  color: Colors.white,
                  iconSize: 30.0,
                  onPressed: () {
                    setState(() {
                      isDeleted = false;
                      refresh(snapshot);
                    });
                  },
                ),
              ],
            ),
            Flexible(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: isDeleted ? 0 : tasks.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Colors.white,
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(Icons.delete),
                          iconSize: 25.0,
                          color: Color(0xff520935),
                          onPressed: () {
                            tasks.removeAt(index);
                            checkValues.removeAt(index);
                            setState(() {
                              deleteRecordsSelected(index);
                            });
                          },
                        ),
                        onTap: () {},
                        title: Text(
                          '${tasks[index]}',
                          style: TextStyle(
                            color: Color(0xff520935),
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        trailing: Checkbox(
                          value: checkValues[index],
                          activeColor: Colors.white,
                          checkColor: Colors.deepPurple[700],
                          onChanged: (bool value) {
                            setState(() {
                              checkValues[index] = !checkValues[index];
                              Firestore.instance
                                  .collection('records')
                                  .document('$phoneNo')
                                  .updateData({
                                'checkvalues': FieldValue.delete(),
                              });
                              Firestore.instance
                                  .collection('records')
                                  .document('$phoneNo')
                                  .updateData({
                                'checkvalues': checkValues,
                              });
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
