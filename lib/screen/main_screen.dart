import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskapp/screen/signIn.dart';
import 'package:taskapp/util/color.dart';

class HomeScreen extends StatefulWidget {
  final String? name;
  const HomeScreen({Key? key, this.name}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String? name;
  
  getData()async{
    await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get().then((value){
      setState(() {
        name = value.get("name");
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.name != null){
      name = widget.name;
    }else{
      getData();
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.black,
        title: Text("Hey, ${name ?? "Guest User"}"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 10),
            child: InkWell(
              onTap: ()async{
                await FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                    return const SignIn();
                  }));
                });
              },
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: Text("Log out",
                style: TextStyle(
                  color: MyColor.black,
                  fontWeight: FontWeight.w600,
                ),),
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context,snap){
          if(!snap.hasData){
            return const Center(child: CircularProgressIndicator());
          }
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              itemCount: snap.data!.docs.length,
              itemBuilder: (context,index){
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                          child: Text(snap.data!.docs.elementAt(index).get("name"),
                          style:const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),),
                        ),),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
