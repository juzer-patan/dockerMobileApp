import 'package:cloud_firestore/cloud_firestore.dart';

class DataService {
  var fsconnect = FirebaseFirestore.instance;

  getVolumes()async{
    return await fsconnect.collection('volumes').get();

  }
  getImages()async{
    return await fsconnect.collection('images').get();

  }

  getNet()async{
    return await fsconnect.collection('networks').get();

  }
   getContainerList() async{
    return await fsconnect.collection('containers').orderBy('created').snapshots();
  }

  getVolList() async{
    return await fsconnect.collection('volumes').orderBy('created').snapshots();
  }

  getImgList() async{
    return await fsconnect.collection('images').orderBy('created').snapshots();
  }

  getNetList() async{
    return await fsconnect.collection('networks').orderBy('created').snapshots();
  }

  createVol(volMap,name) async{
    print("Inside");
    return await fsconnect.collection('volumes').add(volMap).catchError((e){
      print(e);
    });
  }

  createNet(volMap,name) async{
    return await fsconnect.collection('networks').doc(name).set(volMap).catchError((e){
      print(e);
    });
  }

  createCon(volMap,name) async{
    return await fsconnect.collection('containers').doc(name).set(volMap).catchError((e){
      print(e);
    });
  }
  checkImage(name)async{
    print(name);
    return await fsconnect.collection('images').where('tag', isEqualTo: name).get();
  }
  createImg(volMap) async{
    return await fsconnect.collection('images').add(volMap).catchError((e){
      print(e);
    });
  }

  changeStat(volMap,name) async{
    return await fsconnect.collection('containers').doc(name).update(volMap).catchError((e){
      print(e);
    });
  }
  delCon(name) async{
    return await fsconnect.collection('containers').doc(name).delete().catchError((e){
      print(e);
    });
  }
  delNet(name) async{
    return await fsconnect.collection('networks').doc(name).delete().catchError((e){
      print(e);
    });
  }
}