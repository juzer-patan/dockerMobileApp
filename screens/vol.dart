import 'package:docker_app/helpers/database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
class Volumes extends StatefulWidget {
  @override
  _VolumesState createState() => _VolumesState();
}

class _VolumesState extends State<Volumes> {
  DataService db = new DataService();
  Stream vols;
  TextEditingController volController = new TextEditingController();
  Widget volList() {
    return StreamBuilder(
      stream: vols,
      builder: (context,snapshot){
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return VolTile(
                    snapshot.data.docs[index].data()['name'],
                    snapshot.data.docs[index].data()['created'],
                    snapshot.data.docs[index].data()['driver'],
                  );
                },
              )
            : Container();
      },
    );
  }
  launchVol()async{
    var volname;
    if(volController.text.isNotEmpty){
      volname = volController.text;
      var url = "http://192.168.1.2/cgi-bin/docker_vol.py?volname=${volname}";
      var response = await http.get(url);
      print(response.body == volController.text);
      if(!response.body.contains('Error')){
      var volMap = {
        'name' : volController.text,
        'created' : DateTime.now().millisecondsSinceEpoch,
        'driver' : 'local'
      };
      await db.createVol(volMap,volController.text);
      }
      print(response.body);

    }

  }

  

  getList() async {
    await db.getVolList().then((snapshot) {
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
            child: Container(
              height: MediaQuery.of(context).size.height * 0.48,
              child: Padding(
                padding: const EdgeInsets.only(top : 18.0,right: 18,left: 18,bottom: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                 // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add New Volume',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
                    
                    Padding(
                      padding: const EdgeInsets.only(left :  8.0,right: 8.0,top : 12),
                      child: TextField(
                        controller: volController,
                        decoration: InputDecoration(
                            filled: true,
                            isDense: true,
                          //  fillColor: Colors.lightBlue.shade50,
                            border: OutlineInputBorder(
                              
                              borderRadius: BorderRadius.circular(20)
                            ),
                            hintText: 'Volume Name..'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical : 15.0,horizontal: 8),
                      child: TextField(
                        decoration: InputDecoration(
                          helperStyle: TextStyle(fontSize: 14),
                            helperText: "Default local",
                            filled: true,
                            isDense: true,
                         //   fillColor: Colors.lightBlue.shade50,
                            border: OutlineInputBorder(
                              
                              borderRadius: BorderRadius.circular(20)
                            ),
                            hintText: 'River Name..(Optional)'),
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
                              child: 
                                  Text(
                                    "Create",
                                    style: TextStyle(
                                     // color: Colors.black54,
                                      fontSize: 18,
                                    ),
                                  ),
                                
                              
                            ),
                            onPressed: () {
                          //    launchCon();
                              launchVol();
                              print("something");
                     //         web();
                            },
                          ),
                        ),
                  ],
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
  VolTile(this.name, this.created,this.driv);
  @override
  _VolTileState createState() => _VolTileState();
}

class _VolTileState extends State<VolTile> {

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
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
//margin: EdgeInsets.only(bottom : 10),
          shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(8)),
      // shadowColor: Colors.amber,
      //color: Colors.white54,

      child: Container(
        // padding: EdgeInsets.all(20.0),
        height: 80,
        child: ListTile(
          // contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),
          leading: Padding(
            padding: const EdgeInsets.only(bottom : 7.0),
            child: Container(
             // padding: EdgeInsets.all(13),
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.blue
              ),
              //decoration: BoxDecoration(ima),
         //   child: CircleAvatar(
                child: Center(
                    child: Icon(Icons.sd_card,size: 22,color: Colors.white,),
                  //child: Text('V',style: TextStyle(fontSize: 27,fontWeight: FontWeight.bold,color: Colors.white),
         //     radius: 5,
                  
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
                Text('Created ' + readTimestamp(widget.created)),
             //   Text('Image ' + widget.driv)
              ],
            ),
          ),
          
        ),
      ),
    );
  }
}
