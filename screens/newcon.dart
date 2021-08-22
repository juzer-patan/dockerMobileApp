import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docker_app/helpers/database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateNewCon extends StatefulWidget {
  @override
  _CreateNewConState createState() => _CreateNewConState();
}

class _CreateNewConState extends State<CreateNewCon> {
  @override
  Widget build(BuildContext context) {
    int selectedRadio = 2;
  bool showVol = false;
  var selectedval;
  var fsconnect = FirebaseFirestore.instance;
  List<DropdownMenuItem<dynamic>> dropdownitems;
  DataService db = new DataService();
  setSelectedRadio(val) {
    setState(() {
      selectedRadio = val;
    });
  }

  Future<List<DropdownMenuItem<dynamic>>> getVolumes() async {
    var vol = await db.getVolumes();
    List<DropdownMenuItem<dynamic>> items = List();
    print(vol.docs.length);
    if(vol.docs.length != 0){
    selectedval = vol.docs[0].data()['name'];

    for (var volume in vol.docs) {
      items.add(DropdownMenuItem(
        child: Text(volume.data()['name']),
        value: volume.data()['name'],
      ));
    }
    return items;
    }
    items.add(
      DropdownMenuItem(
        child: Text('No Volumes Found'),
        value: 'No Volumes',
      ));
    selectedval = 'No Volumes';
    return items;
  }
    getItems() async{
    dropdownitems = await getVolumes();
  }
  @override
  void initState() {
    // TODO: implement initState
    getItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Demo'),
        ),
        body: Wrap(
          // runAlignment: WrapAlignment.spaceEvenly,
          runSpacing: -8,
          children: [
            RadioListTile(
                title: Text('Add Existing Volume'),
                value: 1,
                groupValue: selectedRadio,
                onChanged: (val) {
                  setSelectedRadio(val);
                  showVol = !showVol;
                }),
            showVol
                ? Container(
                    alignment: Alignment.center,
                    child: DropdownButton(
                      //elevation: 25,
                      underline: Container(
                        height: 2,
                        color: Colors.blue,
                      ),
                      items: dropdownitems,
                      onChanged: (val) {
                        setState(() {
                          selectedval = val;
                        });
                      },
                      value: selectedval,
                    ),
                  )
                : Container(),
            RadioListTile(
                title: Text('None'),
                value: 2,
                groupValue: selectedRadio,
                onChanged: (val) {
                  showVol = !showVol;
                  setSelectedRadio(val);
                })
          ],
        ),
      
    );
  }
}}