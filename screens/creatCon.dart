//mport 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docker_app/helpers/database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CreateCon extends StatefulWidget {
  @override
  _CreateConState createState() => _CreateConState();
}

class _CreateConState extends State<CreateCon> {
  int selectedRadio = 2;
  int selectedNetRadio = 2;
  int selectedPortRadio = 2;
  bool showVol = false;
  bool showNet = false;
  bool showPort = false;
  bool showLocal = false;
  var selectedval;
  var selectedImageval;
  var selectedNetval;
  TextEditingController portController= new TextEditingController();
  TextEditingController nameController= new TextEditingController();
  TextEditingController volController= new TextEditingController();

  var fsconnect = FirebaseFirestore.instance;
  List<DropdownMenuItem<dynamic>> dropdownitems;
  List<DropdownMenuItem<dynamic>> dropdownImageitems;
  List<DropdownMenuItem<dynamic>> dropdownNetitems;

  DataService db = new DataService();
  setSelectedRadio(val) {
    setState(() {
      selectedRadio = val;
    });
  }

  setSelectedNetRadio(val) {
    setState(() {
      selectedNetRadio = val;
    });
  }

  setSelectedPortRadio(val) {
    setState(() {
      selectedPortRadio = val;
    });
  }

  Future<List<DropdownMenuItem<dynamic>>> getVolumes() async {
    var vol = await db.getVolumes();
    List<DropdownMenuItem<dynamic>> items = List();
    print(vol.docs.length);
    if (vol.docs.length != 0) {
      selectedval = vol.docs[0].data()['name'];

      for (var volume in vol.docs) {
        items.add(DropdownMenuItem(
          child: Text(volume.data()['name']),
          value: volume.data()['name'],
        ));
      }
      return items;
    }
    items.add(DropdownMenuItem(
      child: Text('No Volumes Found'),
      value: 'No Volumes',
    ));
    selectedval = 'No Volumes';
    return items;
  }

  Future<List<DropdownMenuItem<dynamic>>> getImages() async {
    var img = await db.getImages();
    List<DropdownMenuItem<dynamic>> items = List();
    print(img.docs.length);
    if (img.docs.length != 0) {
      selectedImageval = img.docs[0].data()['name'];

      for (var volume in img.docs) {
        items.add(DropdownMenuItem(
          child: Text(volume.data()['name']),
          value: volume.data()['name'],
        ));
      }
      return items;
    }
    items.add(DropdownMenuItem(
      child: Text('No Images Found'),
      value: 'No Images',
    ));

    selectedImageval = 'No Images';

    return items;
  }

  Future<List<DropdownMenuItem<dynamic>>> getNet() async {
    var img = await db.getNet();
    List<DropdownMenuItem<dynamic>> items = List();
    print(img.docs.length);
    if (img.docs.length != 0) {
      selectedNetval = img.docs[0].data()['name'];

      for (var volume in img.docs) {
        items.add(DropdownMenuItem(
          child: Text(volume.data()['name']),
          value: volume.data()['name'],
        ));
      }
      return items;
    }
    items.add(DropdownMenuItem(
      child: Text('No Network Found'),
      value: 'No Network',
    ));

    selectedNetval = 'No Network';

    return items;
  }

  getItems() async {
    dropdownitems = await getVolumes();
    dropdownImageitems = await getImages();
    dropdownNetitems = await getNet();
    setState(() {});
  }
   String convertDateTimeDisplay(var date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss');
   // final DateFormat serverFormater = DateFormat('dd-MM-yyyy');
   // final DateTime displayDate = displayFormater.parse(date);
    final String formatted = displayFormater.format(date);
    return formatted;
  }
  launchCon() async{
    var volume;
    var net;
    var port;
    var path;
    showVol ? selectedval != "No Volumes" ? volume = selectedval : volume = "None" : volume = "None";
    showNet ? selectedNetval != "No Network" ? net = selectedNetval : net = "None" : net = "None";
    if((showPort && portController.text.isEmpty) || (showVol && selectedval != "No Volumes" && volController.text.isEmpty)){
       print("Enter valid");
    }
   
    else{
      showVol ? selectedval != "No Volumes" ? volume = selectedval : volume = "None" : volume = "None";
      showNet ? selectedNetval != "No Network" ? net = selectedNetval : net = "None" : net = "None";
      showPort ? port = portController.text : port = "None";
      showVol ? selectedval != "No Volumes" ? path = volController.text : path = "None" : path = "None";
      print(net);
    print(volume);
    print(port);
    var name = nameController.text;
    
     var url = "http://192.168.1.2/cgi-bin/docker.py?os=${name}&img=${selectedImageval}&volume=${volume}&path=${path}&network=${net}&port=${port}";
      var response = await http.get(url);
      print(response.body);
      if(response.body != null ){
        if( !response.body.contains('Error')){
        var netMap = {
          'name': nameController.text,
          'image' : selectedImageval,
          'id' : response.body,
          'created': DateTime.now().millisecondsSinceEpoch,
          'createdExact' : convertDateTimeDisplay(DateTime.now()),
          'Volume': volume,
          'status' : "Running",
          'Network': net != "None" ? net : "bridge",
          'port': port,
          'mount': path
        };
        await db.createCon(netMap,nameController.text);
        }
        else{
          print("Already there");
        }
      }

    }
    
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
        extendBodyBehindAppBar: true,
       
       // backgroundColor: Colors.indigoAccent.shade100,
        backgroundColor: const Color(0xFF1BC0C5),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(top: 78, bottom: 10),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                alignment: Alignment.topCenter,
                //height: MediaQuery.of(context).size.height * 0.8,
                //      width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Text(
                            'Name',
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.normal),
                          ),
                          Expanded(
                              child: Container(
                            padding: EdgeInsets.only(left: 35),
                            height: 35,
                            child: TextField(
                              controller: nameController,
                              style: TextStyle(fontSize: 18),
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(5),
                                  // isDense: true,
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.blue.shade50))),
                            ),
                          )),
                        ],
                      ),
                    ),
                /*    Container(
                      margin: EdgeInsets.only(
                          left: 60,
                          top: 12,
                          right: 40
                          )
                          ,
                      height: 2,
                      color: Colors.grey,
                    ),*/
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Text(
                            'Image',
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.normal),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 35),
                            alignment: Alignment.center,
                            child: DropdownButton(
                              //elevation: 25,
                              underline: Container(
                                height: 2,
                                color: Colors.grey,
                              ),
                              items: dropdownImageitems,
                              onChanged: (val) {
                                setState(() {
                                  selectedImageval = val;
                                });
                              },
                              value: selectedImageval,
                            ),
                          )
                        ],
                      ),
                    ),
                  /*  Container(
                      margin: EdgeInsets.only(
                          left: 60,
                          top: 12,
                          right: 40
                          )
                          ,
                      height: 2,
                      color: Colors.grey,
                    ),*/
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Volume',
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.normal),
                          ),
                          Column(
                            // direction: Axis.vertical,
                            // runAlignment: WrapAlignment.spaceEvenly,
                            // runSpacing: -10,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.70,
                                // height: 20,
                                child: Expanded(
                                  child: RadioListTile(

                                      //dense: true,
                                      title: Text(
                                        'Add Existing Volume',
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      value: 1,
                                      groupValue: selectedRadio,
                                      onChanged: (val) {
                                        setSelectedRadio(val);
                                        showVol = !showVol;
                                      }),
                                ),
                              ),
                              showVol
                                  ? Wrap(
                                    spacing: selectedval != "No Volumes" ? 20 : 0,
                                    direction: Axis.vertical,
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      DropdownButton(
                                            //elevation: 25,
                                            underline: Container(
                                              height: 2,
                                              color: Colors.grey,
                                            ),
                                            items: dropdownitems,
                                            onChanged: (val) {
                                              print(val);
                                              setState(() {
                                                selectedval = val;
                                              });
                                            },
                                            value: selectedval,
                                          
                                        ),
                                        selectedval != "No Volumes" ?
                                        Container(
                                        padding: EdgeInsets.only(left: 35),
                                        height: 35,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        child: TextField(
                                          controller: volController,
                                          style: TextStyle(fontSize: 18),
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(5),
                                              // isDense: true,
                                              filled: true,
                                              labelText: "Mount Path..",
                                              labelStyle: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black54),
                                              fillColor: Colors.grey.shade50,
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey)),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color: Colors
                                                          .blue.shade50))),
                                        ),
                                      ) : Container()
                                    ],
                                  )
                                  : Container(),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.70,
                                //   height: 30,
                                child: Expanded(
                                  child: RadioListTile(
                                      dense: true,
                                      title: Text(
                                        'None',
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      value: 2,
                                      groupValue: selectedRadio,
                                      onChanged: (val) {
                                        showVol = !showVol;
                                        setSelectedRadio(val);
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                /*    Container(
                      margin: EdgeInsets.only(
                          left: 60,
                          top: 12,
                          right: 40
                          )
                          ,
                      height: 2,
                      color: Colors.grey,
                    ),*/
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Network',
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.normal),
                          ),
                          Column(
                            // direction: Axis.vertical,
                            // runAlignment: WrapAlignment.spaceEvenly,
                            // runSpacing: -10,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.70,
                                // height: 20,
                                child: Expanded(
                                  child: RadioListTile(

                                      //dense: true,
                                      title: Text(
                                        'Add Other Network',
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      value: 1,
                                      groupValue: selectedNetRadio,
                                      onChanged: (val) {
                                        setSelectedNetRadio(val);
                                        showNet = !showNet;
                                      }),
                                ),
                              ),
                              showNet
                                  ? Align(
                                      alignment: Alignment.center,
                                      child: DropdownButton(
                                        //elevation: 25,
                                        underline: Container(
                                          height: 2,
                                          color: Colors.grey,
                                        ),
                                        items: dropdownNetitems,
                                        onChanged: (val) {
                                          setState(() {
                                            selectedNetval = val;
                                          });
                                        },
                                        value: selectedNetval,
                                      ),
                                    )
                                  : Container(),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.70,
                                //   height: 30,
                                child: Expanded(
                                  child: RadioListTile(
                                      dense: true,
                                      title: Text(
                                        'Default',
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      value: 2,
                                      groupValue: selectedNetRadio,
                                      onChanged: (val) {
                                        showNet = !showNet;
                                        setSelectedNetRadio(val);
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    /*Container(
                      margin: EdgeInsets.only(
                          left: 60,
                          top: 12,
                          right: 40
                          )
                          ,
                      height: 2,
                      color: Colors.grey,
                    ),*/
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Port',
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.normal),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 29),
                            child: Column(
                              // direction: Axis.vertical,
                              // runAlignment: WrapAlignment.spaceEvenly,
                              // runSpacing: -10,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.70,
                                  // height: 20,
                                  child: Expanded(
                                    child: RadioListTile(

                                        //dense: true,
                                        title: Text(
                                          'Expose Port',
                                          style: TextStyle(fontSize: 17),
                                        ),
                                        value: 1,
                                        groupValue: selectedPortRadio,
                                        onChanged: (val) {
                                          setSelectedPortRadio(val);
                                          showPort = !showPort;
                                        }),
                                  ),
                                ),
                                showPort
                                    ? Container(
                                        padding: EdgeInsets.only(left: 35),
                                        height: 35,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        child: TextField(
                                          controller: portController,
                                          style: TextStyle(fontSize: 18),
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(5),
                                              // isDense: true,
                                              filled: true,
                                              labelText: "Port Number..",
                                              labelStyle: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black54),
                                              fillColor: Colors.grey.shade50,
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey)),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color: Colors
                                                          .blue.shade50))),
                                        ),
                                      )
                                    : Container(),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.70,
                                  //   height: 30,
                                  child: Expanded(
                                    child: RadioListTile(
                                        dense: true,
                                        title: Text(
                                          'None',
                                          style: TextStyle(fontSize: 17),
                                        ),
                                        value: 2,
                                        groupValue: selectedPortRadio,
                                        onChanged: (val) {
                                          showPort = !showPort;
                                          setSelectedPortRadio(val);
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                          animationDuration: Duration(seconds: 2),
                          //color: const Color(0xFF1BC0C5),
                          color: Colors.indigo.shade300,
                         // color: const Color(0xff2A75BC),
                          type: MaterialType.button,
                          shadowColor: Colors.black,
                          elevation: 10,
                          borderRadius: BorderRadius.circular(15),
                          child: MaterialButton(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: 
                                  Text(
                                    "Launch",
                                    style: TextStyle(
                                     // color: Colors.black54,
                                      fontSize: 18,
                                    ),
                                  ),
                                
                              
                            ),
                            onPressed: () {
                              launchCon();
                              print("something");
                     //         web();
                            },
                          ),
                        ),
                    
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
