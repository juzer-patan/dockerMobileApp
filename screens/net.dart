import 'dart:convert';

import 'package:docker_app/helpers/database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';

class Network extends StatefulWidget {
  @override
  _NetworkState createState() => _NetworkState();
}

class _NetworkState extends State<Network> {
  DataService db = new DataService();
  Stream vols;
  TextEditingController volController = new TextEditingController();
  TextEditingController rivController = new TextEditingController();
  TextEditingController gateController = new TextEditingController();
  TextEditingController subController = new TextEditingController();

   String convertDateTimeDisplay(var date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss');
   // final DateFormat serverFormater = DateFormat('dd-MM-yyyy');
   // final DateTime displayDate = displayFormater.parse(date);
    final String formatted = displayFormater.format(date);
    return formatted;
  }
  Widget volList() {
    return StreamBuilder(
      stream: vols,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return VolTile(
                    snapshot.data.docs[index].data()['name'],
                    snapshot.data.docs[index].data()['created'],
                    snapshot.data.docs[index].data()['driver'],
                    snapshot.data.docs[index].data()['id'],
                    snapshot.data.docs[index].data()['subnet'],
                    snapshot.data.docs[index].data()['gateway'],
                    snapshot.data.docs[index].data()['createdExact'],
                  );
                },
              )
            : Container(
                child: Text("No Networks Found"),
              
            );
      },
    );
  }

  launchNet() async {
    print("Inside");
    var netname;
    var rivname;
    var gatename;
    var subname;
    if (volController.text.isNotEmpty) {
      netname = volController.text;

      rivController.text.isNotEmpty
          ? rivname = rivController.text
          : rivname = "None";
      gateController.text.isNotEmpty
          ? gatename = gateController.text
          : gatename = "None";
      subController.text.isNotEmpty
          ? subname = subController.text
          : subname = "None";
      var url =
          "http://192.168.1.2/cgi-bin/docker_net.py?name=${netname}&driver=${rivname}&subnet=${subname}&gateway=${gatename}";
      var response = await http.get(url);
      print(url);
      if (response.body != null) {
        var op = jsonDecode(response.body);

        var netMap = {
          'name': volController.text,
          'created': DateTime.now().millisecondsSinceEpoch,
          'createdExact' : convertDateTimeDisplay(DateTime.now()),
          'driver': op['Driver'],
          'id': op['Id'],
          'subnet': op['Subnet'],
          'gateway': op['Gateway']
        };
        await db.createNet(netMap,volController.text);
      }
      // print("Response" + response.body);
      print(response.body);
    }
  }

  getList() async {
    await db.getNetList().then((snapshot) {
      print(snapshot);
      setState(() {
        vols = snapshot;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1BC0C5),
      //backgroundColor: Colors.indigoAccent.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        child: volList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0)), //this right here
                  child: SingleChildScrollView(
                    //clipBehavior: Clip.antiAliasWithSaveLayer,
                    physics: ClampingScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.68,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 18.0, right: 18, left: 18, bottom: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New Network',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w600),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8.0, top: 12, bottom: 10),
                              child: TextField(
                                controller: volController,
                                decoration: InputDecoration(
                                    filled: true,
                                    isDense: true,
                                    //  fillColor: Colors.lightBlue.shade50,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    hintText: 'Network Name..'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 8),
                              child: TextField(
                                controller: rivController,
                                decoration: InputDecoration(
                                    helperStyle: TextStyle(fontSize: 14),
                                    //  helperText: "Default bridge",
                                    filled: true,
                                    isDense: true,
                                    //   fillColor: Colors.lightBlue.shade50,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    labelText: 'Driver Name..(Optional)'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 8),
                              child: TextField(
                                controller: subController,
                                decoration: InputDecoration(
                                    helperStyle: TextStyle(fontSize: 14),
                                    //      helperText: "Default bridge",
                                    filled: true,
                                    isDense: true,
                                    //   fillColor: Colors.lightBlue.shade50,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    hintText: 'Subnet Range..(Optional)'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 8),
                              child: TextField(
                                controller: gateController,
                                decoration: InputDecoration(
                                    helperStyle: TextStyle(fontSize: 14),
                                    //  helperText: "Default bridge",
                                    filled: true,
                                    isDense: true,
                                    //   fillColor: Colors.lightBlue.shade50,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    hintText: 'Gateway IP..(Optional)'),
                              ),
                            ),
                            SizedBox(
                              height: 9,
                            ),
                            Material(
                              animationDuration: Duration(seconds: 2),
                              //color: const Color(0xFF1BC0C5),
                              color: Colors.cyan.shade600,
                              // color: Colors.indigo.shade300,
                              //color: const Color(0xff2A75BC),
                              type: MaterialType.button,
                              shadowColor: Colors.black,
                              elevation: 7,
                              borderRadius: BorderRadius.circular(15),
                              child: MaterialButton(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    "Create",
                                    style: TextStyle(
                                      // color: Colors.black54,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  //    launchCon();
                                  launchNet();

                                  ///  launchVol();
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
                );
              });
          //  Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => CreateCon()));
        },
        backgroundColor: Colors.indigoAccent.shade700,
        child: Icon(
          Icons.add,
          size: 25,
        ),
      ),
    );
  }
}

class VolTile extends StatefulWidget {
  String name;
  var created;
  String driv;
  String gateway;
  String subnet;
  String id;
  String exact;

  VolTile(this.name, this.created, this.driv,this.id,this.subnet,this.gateway,this.exact);
  @override
  _VolTileState createState() => _VolTileState();
}

class _VolTileState extends State<VolTile> {

  DataService db = new DataService();
  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';
    print(diff.inSeconds);
    print(diff.inDays);
    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).round().toString() + ' WEEKS AGO';
      }
    }

    return time;
  }

  showAlert(name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete the network ${name}'),
          content: Text("Are you sure ?"),
          actions: <Widget>[
            FlatButton(
              child: Text("YES"),
              onPressed: ()  {
                //Put your code here which you want to execute on Yes button click.
                // Navigator.of(context).pop();
                  rmNet(name);
                  Navigator.of(context).pop();
                //await db.enableLocationShare(widget.chatRoomId);
                
              },
            ),
            FlatButton(
              child: Text("NO"),
              onPressed: () {
                //Put your code here which you want to execute on No button click.
                //  Navigator.of(context).pop();
               // await db.disableLocationShare(widget.chatRoomId);
                Fluttertoast.showToast(
                      msg: "No Changes were made",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.SNACKBAR,
                      timeInSecForIosWeb: 3,
                      backgroundColor: Colors.black45,
                      textColor: Colors.white,
                      fontSize: 18.0
                  );
                
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("CANCEL"),
              onPressed: () {
                //Put your code here which you want to execute on Cancel button click.
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  String convertDateTimeDisplay(var date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss');
   // final DateFormat serverFormater = DateFormat('dd-MM-yyyy');
   // final DateTime displayDate = displayFormater.parse(date);
    final String formatted = displayFormater.format(date);
    return formatted;
  }

  rmNet(name)async{
    //  showAlert(name);
    
    var url = "http://192.168.1.2/cgi-bin/docker_netAct.py?name=${name}&act=rm";
    var response = await http.get(url);
    if(response.body != null){
      print(response.body);
      if(!response.body.contains("Error")){
        await db.delNet(name);
        Fluttertoast.showToast(
                      msg: "Network was deleted successfully",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.SNACKBAR,
                      timeInSecForIosWeb: 3,
                      backgroundColor: Colors.black45,
                      textColor: Colors.white,
                      fontSize: 18.0
                  );
                
                
        print("Action Done");
      }
      else{
        print("Error");
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
//margin: EdgeInsets.only(bottom : 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      // shadowColor: Colors.amber,
      //color: Colors.white54,

      child: Container(
        // padding: EdgeInsets.all(20.0),
        height: 80,
       // width: MediaQuery.of(context).size.width *,
        child: GestureDetector(
                  onDoubleTap: (){
                
                showTopModalSheet(context: context ,child: Container(
                  height: 56,
                  color: Colors.lightBlue.shade200,
                  child: ListTile(
                    leading: IconButton(icon: Icon(Icons.close),onPressed: (){
                      Navigator.pop(context);
                    },
                      color: Colors.black,
                    ),
                    trailing: IconButton(icon: Icon(Icons.delete),onPressed: (){
                       // rmNet( widget.name);
                          showAlert(widget.name);
                    },),
                  ),
                ));
              },
                  child: ListTile(
            // contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),
            trailing: GestureDetector(
                
                onTap: (){
                  showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20.0)), //this right here
              child: Container(
                height: MediaQuery.of(context).size.height * 0.48,
             //   width: MediaQuery.of(context).size.width ,
                child:  Padding(
                  padding: const EdgeInsets.only(top : 18.0,right: 18,left: 18,bottom: 8),
                  child: Wrap(
                   // mainAxisAlignment: MainAxisAlignment.center,
                   
                    direction: Axis.vertical,
                    spacing: 10,
                    children: [
                      Row(
                        children: [
                          Text('Name : ',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600),),
                          Text(widget.name,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600))
                        ],
                      ),
                      Row(
                        children: [
                          Text('Created at : ',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600),),
                        //  Text(readTimestamp(widget.created),style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600))
                            Text(widget.exact,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600),)
                         // Expanded(child: Text(DateTime.now().year.toString() + "-" + DateTime.now().day.toString(),style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600)))
                        ],
                      ),
                      Row(
                        children: [
                          Text('Id : ',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600),),
                          Text(widget.id,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600))
                        ],
                      ),
                      Row(
                        children: [
                          Text('Driver : ',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600),),
                          Text(widget.driv.replaceAll('"',"" ),style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600))
                        ],
                      ),
                      Row(
                        children: [
                          Text('Subnet : ',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600),),
                          Text(widget.subnet.replaceAll('"',"" ),style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600))
                        ],
                      ),
                      Row(
                        children: [
                          Text('Gateway : ',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600),),
                          Text(widget.gateway.replaceAll('"',"" ),style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600))
                        ],
                      ),
                    ],
                  ),
                ) 
              ),
            );
          });
                },
                child: Icon(
              Icons.info,
             // color: Colors.blue.shade400,
              size: 24,
            )),
            //trailing: IconButton(icon : Icon(Icons.info),iconSize: 22,),
            leading: Padding(
              padding: const EdgeInsets.only(bottom: 7.0),
              child: Container(
                // padding: EdgeInsets.all(13),
                width: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40), color: Colors.blue),
                //decoration: BoxDecoration(ima),
                //   child: CircleAvatar(
                child: Center(
                  child: Icon(Icons.wifi_tethering,size: 22,color: Colors.white,),
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                widget.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Wrap(
                //alignment: WrapAlignment.center,
                direction: Axis.vertical,
                //mainAxisAlignment: MainAxisAlignment.start,
                //crossAxisAlignment: CrossAxisAlignment.start,
                //  spacing: 8,
                children: [
                   // Text('Created ' + convertDateTimeDisplay(DateTime.now()))
                  Text('Created ' + readTimestamp(widget.created)),
                  //   Text('Image ' + widget.driv)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
