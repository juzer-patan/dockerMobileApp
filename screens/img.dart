import 'dart:convert';

import 'package:docker_app/helpers/database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Images extends StatefulWidget {
  @override
  _ImagesState createState() => _ImagesState();
}

class _ImagesState extends State<Images> {
  DataService db = new DataService();
  Stream vols;
  TextEditingController volController = new TextEditingController();
  TextEditingController rivController = new TextEditingController();
  TextEditingController gateController = new TextEditingController();
  TextEditingController subController = new TextEditingController();
  bool isLoading = false;
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
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return VolTile(
                    snapshot.data.docs[index].data()['name'],
                    snapshot.data.docs[index].data()['created'],
                    snapshot.data.docs[index].data()['tag'],
                    snapshot.data.docs[index].data()['id'],
                    snapshot.data.docs[index].data()['size'],
                  );
                },
              )
            : Container();
      },
    );
  }

  getSize(String size) {
    int sizeint = int.parse(size);
    int sizemb = sizeint ~/ 1000000;
    return (sizemb).toString();
  }

  launchNet() async {
    var netname;
    var rivname;
    var gatename;
    var subname;
    if (volController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      Navigator.pop(context);
      netname = volController.text;

      rivController.text.isNotEmpty
          ? rivname = rivController.text
          : rivname = "latest";
      gateController.text.isNotEmpty
          ? gatename = gateController.text
          : gatename = "None";
      subController.text.isNotEmpty
          ? subname = subController.text
          : subname = "None";
      var url =
          "http://192.168.43.73/cgi-bin/docker_img.py?name=${netname}&version=${rivname}";
      var response = await http.get(url);

      print(url);
      print(response.body);
      if (response.body != null) {
        setState(() {
          isLoading = false;
        });
        await db.checkImage(netname + ":" + rivname).then((value) async {
          print(value.docs.length);
          var op = jsonDecode(response.body);
          print(getSize(op['Size']));
          if (value.docs.length == 0) {
            var op = jsonDecode(response.body);

            var netMap = {
              'name': volController.text,
              // 'created': DateTime.now().millisecondsSinceEpoch,
              'created': convertDateTimeDisplay(DateTime.now()),
              'tag': op['Tag'].replaceAll('"', ""),
              'id': op['Id'].replaceAll('"', ""),
              'size': getSize(op['Size']),
              // 'gateway': op['Gateway']
            };

            await db.createImg(netMap);
          } else {
            Fluttertoast.showToast(
                msg: "Image Already exists!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.black45,
                textColor: Colors.white,
                fontSize: 18.0);
          }
        });
        /*   var op = jsonDecode(response.body);

        var netMap = {
          'name': volController.text,
         // 'created': DateTime.now().millisecondsSinceEpoch,
          'created' : convertDateTimeDisplay(DateTime.now()),
          'tag': op['Tag'],
          'id': op['Id'],
          'size': getSize(op['Size']),
         // 'gateway': op['Gateway']
        };*/
        //   print(getSize(op['Size']));
        //   await db.createImg(netMap);
      }
      // print("Response" + response.body);

    }
  }

  getList() async {
    await db.getImgList().then((snapshot) {
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
        child: Column(
          children: [
            volList(),
            isLoading
                ? Container(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.green,
                    ),
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.bottomCenter,
                  )
                : Container()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20.0)), //this right here
                        child: SingleChildScrollView(
                          //clipBehavior: Clip.antiAliasWithSaveLayer,
                          physics: ClampingScrollPhysics(),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 18.0, right: 18, left: 18, bottom: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pull Image',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                        top: 12,
                                        bottom: 10),
                                    child: TextField(
                                      controller: volController,
                                      decoration: InputDecoration(
                                          filled: true,
                                          isDense: true,
                                          //  fillColor: Colors.lightBlue.shade50,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          labelText: 'Image Name..'),
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
                                          labelText: 'Version..(Optional)'),
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
                                          "Pull",
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
                                  )
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
  String tag;
  String gateway;
  String size;
  String id;
  String exact;

  VolTile(this.name, this.created, this.tag, this.id, this.size);
  @override
  _VolTileState createState() => _VolTileState();
}

class _VolTileState extends State<VolTile> {
  var imgUrl = {
    'ubuntu':
        'https://e7.pngegg.com/pngimages/720/729/png-clipart-omg-ubuntu-installation-linux-feather-logo-design-computer-logo.png',
    'centos':
        'https://sitl.me/wp-content/uploads/2019/02/4fae2c05-6d9d-422a-a317-f501cd0ffd3c-centos.png',
    'fedora':
        'https://d1q6f0aelx0por.cloudfront.net/product-logos/library-fedora-logo.png',
    'httpd':
        'https://d1q6f0aelx0por.cloudfront.net/product-logos/library-httpd-logo.png',
    'mysql':
        'https://d1q6f0aelx0por.cloudfront.net/product-logos/library-mysql-logo.png',
    'wordpress':
        'https://d1q6f0aelx0por.cloudfront.net/product-logos/library-wordpress-logo.png',
    'joomla':
        'https://d1q6f0aelx0por.cloudfront.net/product-logos/library-joomla-logo.png',
  };
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

  String convertDateTimeDisplay(var date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss');
    // final DateFormat serverFormater = DateFormat('dd-MM-yyyy');
    // final DateTime displayDate = displayFormater.parse(date);
    final String formatted = displayFormater.format(date);
    return formatted;
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
        child: ListTile(
          // contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),
          trailing: GestureDetector(
              onTap: () {
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
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 18.0, right: 18, left: 18, bottom: 8),
                              child: Wrap(
                                // mainAxisAlignment: MainAxisAlignment.center,

                                direction: Axis.vertical,
                                spacing: 10,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Name : ',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(widget.name,
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Created at : ',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      //  Text(readTimestamp(widget.created),style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600))
                                      Text(
                                        widget.created,
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600),
                                      )
                                      // Expanded(child: Text(DateTime.now().year.toString() + "-" + DateTime.now().day.toString(),style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600)))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Id : ',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(widget.id,
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Tags : ',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(widget.tag.replaceAll('"', ""),
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Size : ',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                          widget.size.replaceAll('"', "") +
                                              "MB",
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600))
                                    ],
                                  ),
                                ],
                              ),
                            )),
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
                image: DecorationImage(
                  image: imgUrl.keys.contains(widget.name) ?
                  NetworkImage(
                    imgUrl[widget.name],
                  ) :
                  NetworkImage(
                    'https://d36jcksde1wxzq.cloudfront.net/be7833db9bddb4494d2a7c3dd659199a.png',
                  ),
                  fit: BoxFit.contain,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              //decoration: BoxDecoration(ima),
              //   child: CircleAvatar(
            ),
          ),

          /* Container(
            padding: EdgeInsets.only(bottom: 3),
            //decoration: BoxDecoration(ima),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://e7.pngegg.com/pngimages/720/729/png-clipart-omg-ubuntu-installation-linux-feather-logo-design-computer-logo.png',
                  ),
              radius: 35,
            ),
          ),*/
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
                Text('Size ' + widget.size + "MB"),
                //   Text('Image ' + widget.driv)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
