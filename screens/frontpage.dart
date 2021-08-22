import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docker_app/helpers/database.dart';
import 'package:docker_app/screens/creatCon.dart';
import 'package:docker_app/screens/img.dart';
import 'package:docker_app/screens/net.dart';
import 'package:docker_app/screens/vol.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
class Front extends StatefulWidget {
  @override
  _FrontState createState() => _FrontState();
}

class _FrontState extends State<Front> {
  DataService db = new DataService();
  Stream cons;
  Widget conList() {
    return StreamBuilder(
      stream: cons,
      builder: (context, snapshot) {
        // snapshot.hasData ? print(snapshot.data.docs[0].data()['name']) : print("nothing");
        // return Container();
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return ConTile(
                    snapshot.data.docs[index].data()['name'],
                    snapshot.data.docs[index].data()['created'],
                    snapshot.data.docs[index].data()['image'],
                    snapshot.data.docs[index].data()['status'],
                  );
                },
              )
            : Container();
      },
    );
  }

  getList() async {
    await db.getContainerList().then((snapshot) {
      print(snapshot);
      setState(() {
        cons = snapshot;
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
      ///  backgroundColor: Colors.purple.shade100,
      //backgroundColor: Colors.indigo.shade200,
      backgroundColor: const Color(0xFF1BC0C5),
      //backgroundColor: Colors.indigoAccent.shade100,
      //backgroundColor: Colors.white70,
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        child: ListView(
          // padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
              decoration: BoxDecoration(color: Colors.lightBlue.shade50
                  /*   image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        //  'https://s3.envato.com/files/120334242/Preview%20image%20set/indigo-cyan.png'
                          // 'https://miro.medium.com/max/1200/1*zH86wd-3URNeM_MoeaBQuQ.jpeg'
                          ))*/
                  ),
              child: Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: Image.network(
                    'https://www.freepnglogos.com/uploads/blue-d-letter-logo-png-17.png',
                    // 'https://www.freepnglogos.com/uploads/letter-d-dr-odd-logo-png-1.png',
                    //  'https://cdn2.iconfinder.com/data/icons/social-media-and-payment/64/-37-512.png'
                    //'https://www.kindpng.com/picc/m/292-2920038_blue-d-letter-logo-png-disqus-logo-png.png',
                    fit: BoxFit.fill,
                    height: 60,
                  ),
                ),
              ),
            ),
            Card(
              color: Colors.cyan,
              // color: Colors.indigo.shade400,
              child: ListTile(
                leading: Icon(
                  Icons.storage,
                  size: 20,
                  color: Colors.white,
                ),
                title: Text(
                  'Volumes',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Volumes()));
                },
              ),
            ),
            Card(
              color: Colors.cyan,
              //  color: Colors.indigo.shade400,
              child: ListTile(
                //contentPadding: EdgeInsets.z,
                leading: Icon(
                  Icons.network_check,
                  size: 20,
                  color: Colors.white,
                ),
                title: Text(
                  'Networks',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Network()));
                },
              ),
            ),
            Card(
              color: Colors.cyan,
              //color: Colors.indigo.shade400,
              child: ListTile(
                leading: Icon(
                  Icons.iso,
                  size: 20,
                  color: Colors.white,
                ),
                title: Text(
                  'Images',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Images()));
                },
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        //backgroundColor: Colors.grey,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text("Welcome"),
      ),
      body: Container(
        child: conList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => CreateCon()));
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

class ConTile extends StatefulWidget {
  String name;
  var created;
  String image;
  String status;
  ConTile(this.name, this.created, this.image, this.status);
  @override
  _ConTileState createState() => _ConTileState();
}

class _ConTileState extends State<ConTile> {
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
  conAct(act,name,{isStatus,status})async{
    var url = "http://192.168.1.2/cgi-bin/docker_conAct.py?name=${name}&act=${act}";
    var response = await http.get(url);
    if(response.body != null){
      print(response.body);
      if(!response.body.contains("Error")){
        if(isStatus){

            var changeMap = {
              'status' : status
            };
            await db.changeStat(changeMap, name);
        }
        print("Action Done");
      }
      else{
        print("Error");
      }
    }
  }
  rmCon(act,name)async{
    var url = "http://192.168.1.2/cgi-bin/docker_conAct.py?name=${name}&act=${act}";
    var response = await http.get(url);
    if(response.body != null){
      print(response.body);
      if(!response.body.contains("Error")){
        await db.delCon(name);
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
      //    shape: RoundedRectangleBorder(
      //                         borderRadius: BorderRadius.circular(8)),
      // shadowColor: Colors.amber,
      //color: Colors.white54,

      child: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0)), //this right here
                  child: Container(
                      //    width: 50,
                      height: MediaQuery.of(context).size.height * 0.5,
                      //   width: MediaQuery.of(context).size.width ,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 18.0,
                          right: 25,
                          left: 25,
                          bottom: 8,
                        ),
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          //direction: Axis.vertical,
                          //spacing: 10,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                'Select an option',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: GestureDetector(
                                onTap: (){
                                  conAct("start", widget.name,status: "Running",isStatus: true);
                                },
                                child: Text(
                                  'Start',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: widget.status == "Running" ? Colors.black45 : Colors.black
                                  ),
                                ),
                              ),
                            ),
                            /* Container(
                              height: 2,
                             
                              decoration: BoxDecoration(color: Colors.blue),
                            ),*/
                            GestureDetector(
                              onTap: (){
                                conAct("stop", widget.name,status: "Stopped",isStatus: true);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Stop',
                                  style: TextStyle(fontSize: 20,color: widget.status == "Running" ? Colors.black : Colors.black45),
                                ),
                              ),
                            ),
                            
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Attach',
                                style: TextStyle(fontSize: 20,color: widget.status == "Running" ? Colors.black : Colors.black45),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Execute',
                                style: TextStyle(fontSize: 20,color: widget.status == "Running" ? Colors.black : Colors.black45),
                              ),
                            ),
                            GestureDetector(
                                onTap: (){
                                rmCon("rm", widget.name);
                                },
                                child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Remove',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Commit',
                                style: TextStyle(fontSize: 20,),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Pause',
                                style: TextStyle(fontSize: 20,color: widget.status == "Running" ? Colors.black : Colors.black45),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Unpause',
                                style: TextStyle(fontSize: 20,color: widget.status == "Running" ? Colors.black : Colors.black45),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Show Logs',
                                style: TextStyle(fontSize: 20,color: widget.status == "Running" ? Colors.black : Colors.black45),
                              ),
                            ),
                          ],
                        ),
                      )),
                );
              });
        },
        child: Container(
          // padding: EdgeInsets.all(20.0),
          height: 100,
          child: ListTile(
            // contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),
            leading: Container(
              padding: EdgeInsets.only(top: 15),
              //decoration: BoxDecoration(ima),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://pbs.twimg.com/profile_images/1273307847103635465/lfVWBmiW_400x400.png'),
                radius: 35,
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
                  Text('Created ' + readTimestamp(widget.created)),
                  Text('Image ' + widget.image)
                ],
              ),
            ),
            trailing: Column(
              children: [
                Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  widget.status,
                  style: TextStyle(
                      color: widget.status == 'Running'
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
