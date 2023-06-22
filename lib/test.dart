import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TextFF extends StatefulWidget {
  const TextFF({Key? key}) : super(key: key);

  @override
  State<TextFF> createState() => _TextFFState();
}

class _TextFFState extends State<TextFF> {

  setData() async{
   await FirebaseFirestore.instance.collection("data").where("name", isEqualTo: "ritesh").get().then((value) async{
     for(int i = 0; i < value.docs.length; i++){
       await value.docs.elementAt(i).reference.delete();
     }
   });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("users").snapshots(),
          builder: (context,snap){
            if(!snap.hasData){
              return Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              itemCount: snap.data!.docs.length,
              shrinkWrap: true,
              itemBuilder: (context,index){
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(snap.data!.docs.elementAt(index).get("email")),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
