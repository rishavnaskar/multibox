import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CitySearchScreen extends StatefulWidget {
  @override
  _CitySearchScreenState createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  String text;
  DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MediaQuery.of(context).viewInsets,
      color: Color(0xff757575),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            )),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  'Enter city name',
                  style: TextStyle(
                    fontSize: 40.0,
                    color: Colors.deepPurple[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 50.0),
                child: TextField(
                  cursorColor: Colors.deepPurple[700],
                  autocorrect: true,
                  keyboardType: TextInputType.text,
                  enableInteractiveSelection: true,
                  enableSuggestions: true,
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    text = value;
                  },
                ),
              ),
              Container(
                child: RaisedButton(
                  elevation: 20.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                    ),
                  ),
                  color: Colors.deepPurple[700],
                  padding: EdgeInsets.fromLTRB(50.0, 20.0, 50.0, 20.0),
                  onPressed: () {
                    Navigator.pop(context, text);
                  },
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
