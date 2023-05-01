import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:taskapp/screen/chat_screen.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({Key? key}) : super(key: key);

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  TextEditingController search = TextEditingController();
  List<String> connectionList = [];
  List<String> requestList = [];
  List<String> pendingList = [];

  @override
  void initState() {
    super.initState();
    getConnection();
  }

  getConnection() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("user_connection")
        .get()
        .then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        connectionList.add(value.docs.elementAt(i).get("uid"));
      }
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("user_request")
        .get()
        .then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        requestList.add(value.docs.elementAt(i).get("uid"));
      }
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("user_pending")
        .get()
        .then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        pendingList.add(value.docs.elementAt(i).get("uid"));
      }
    });
    setState(() {});
  }

  sendRequest(String uid) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("user_pending")
        .add({
      "date": DateTime.now(),
      "uid": uid,
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("user_request")
        .add({
      "date": DateTime.now(),
      "uid": FirebaseAuth.instance.currentUser!.uid,
    });

    setState(() {
      pendingList.add(uid);
    });
  }

  cancelPending(String uid) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("user_pending")
        .where("uid", isEqualTo: uid)
        .get()
        .then((value) async {
      if (value.docs.length > 0) {
        await value.docs.elementAt(0).reference.delete();
      }
      setState(() {
        pendingList.remove(uid);
      });
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("user_request")
        .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
      if (value.docs.length > 0) {
        await value.docs.elementAt(0).reference.delete();
      }
    });

    Navigator.of(context).pop();
  }

  cancelRequest(String uid,String name) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("user_request")
        .where("uid", isEqualTo: uid)
        .get()
        .then((value) async {
      if (value.docs.length > 0) {
        await value.docs.elementAt(0).reference.delete();
      }
      setState(() {
        requestList.remove(uid);
      });
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("user_pending")
        .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
      if (value.docs.length > 0) {
        await value.docs.elementAt(0).reference.delete();
      }
    });

    snackBar(name + " is Removed");

  }

  acceptRequest(String uid,String name) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("user_request")
        .where("uid", isEqualTo: uid)
        .get()
        .then((value) async {
      if (value.docs.length > 0) {
        await value.docs.elementAt(0).reference.delete();
      }
      setState(() {
        requestList.remove(uid);
      });
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("user_pending")
        .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
      if (value.docs.length > 0) {
        await value.docs.elementAt(0).reference.delete();
      }
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("user_connection").add({
      "date": DateTime.now(),
      "uid": uid,
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("user_connection").add({
      "date": DateTime.now(),
      "uid": FirebaseAuth.instance.currentUser!.uid,
    });

    setState(() {
      connectionList.add(uid);
    });

    snackBar(name + " is added to Friends List");

  }

  snackBar(String s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 2000),
        backgroundColor: Color(0xFFD30026),
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Text(
          s,
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        Map<String,dynamic> d = snap.data!.data() as Map<String,dynamic>;
        return Scaffold(
          backgroundColor: Color(0xFFFFFBFE),
          appBar: AppBar(
            elevation: 0,
            leadingWidth: 0,
            backgroundColor: Color(0xFFFFFBFE),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                d.containsKey("photo_url") && snap.data!.get("photo_url").length > 5
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: CachedNetworkImage(
                          imageUrl: snap.data!.get("photo_url"),
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          height: 35,
                          width: 35,
                        ),
                      )
                    : Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Color(0xFFD30026), width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          snap.data!
                              .get("display_name")
                              .toString()
                              .substring(0, 1),
                          style:
                              TextStyle(color: Color(0xFFD30026), fontSize: 18),
                        ),
                      ),
                Container(
                  width: MediaQuery.of(context).size.width - 80,
                  height: 47,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black.withOpacity(0.25)),
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextFormField(
                    controller: search,
                    onTap: () {
                      setState(() {
                        // tap = true;
                      });
                    },
                    cursorColor: Color(0xff94A3B8),
                    autofocus: false,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black.withOpacity(0.25),
                      ),
                      suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              search.clear();
                            });
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          child: Container(
                              child: Icon(
                            Icons.clear,
                            color: Colors.black.withOpacity(0.25),
                          ))),
                      hintText: " Search Friends",
                      hintStyle: TextStyle(
                          color: Color(0xff7E8493),
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4.0),
                          topRight: Radius.circular(4.0),
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4.0),
                          topRight: Radius.circular(4.0),
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.75),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    keyboardType: TextInputType.name,
                  ),
                ),
              ],
            ),
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [

              GestureDetector(
                onTap: (){
                  setState(() {
                    search.clear();
                  });
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height-150,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          requestList.length > 0 ?
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Friend Requests",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                itemCount: requestList.length,
                                shrinkWrap: true,
                                itemBuilder: (context,index){
                                  return StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance.collection("users").doc(requestList[index]).snapshots(),
                                    builder: (context,snaps){
                                      if(!snaps.hasData){
                                        return Center(child: CircularProgressIndicator());
                                      }
                                      Map<String,dynamic> da = snaps.data!.data() as Map<String,dynamic>;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [

                                                da.containsKey("photo_url") && da["photo_url"].length > 5
                                                    ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(40),
                                                  child: CachedNetworkImage(
                                                    imageUrl: snaps.data!.get("photo_url"),
                                                    placeholder: (context, url) =>
                                                        CircularProgressIndicator(),
                                                    errorWidget: (context, url, error) =>
                                                        Icon(Icons.error),
                                                    height: 35,
                                                    width: 35,
                                                  ),
                                                )
                                                    : Container(
                                                  height: 40,
                                                  width: 40,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border:
                                                    Border.all(color: Color(0xFFD30026), width: 1.5),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    snaps.data!
                                                        .get("display_name")
                                                        .toString()
                                                        .substring(0, 1),
                                                    style:
                                                    TextStyle(color: Color(0xFFD30026), fontSize: 18),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 12,
                                                ),
                                                Text(
                                                  snaps.data!.get("display_name"),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Row(
                                              children: [

                                                InkWell(
                                                  onTap:(){
                                                    cancelRequest(snaps.data!.get("uid"), snaps.data!.get("display_name"));
                                                  },
                                                  child: SizedBox(
                                                    height: 40,
                                                    width: 40,
                                                    child: Icon(Icons.cancel_outlined),
                                                  ),
                                                ),
                                                SizedBox(width: 10,),
                                                InkWell(
                                                  onTap:(){
                                                    acceptRequest(snaps.data!.get("uid"), snaps.data!.get("display_name"));
                                                  },
                                                  child: SizedBox(
                                                    height: 40,
                                                    width: 40,
                                                    child: Icon(Icons.check_circle_outline),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              SizedBox(height: 20,),
                            ],
                          ) : SizedBox(),


                          connectionList.length > 0 ?
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Friends",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                itemCount: connectionList.length,
                                shrinkWrap: true,
                                itemBuilder: (context,index){
                                  return StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance.collection("users").doc(connectionList[index]).snapshots(),
                                    builder: (context,snaps){
                                      if(!snaps.hasData){
                                        return Center(child: CircularProgressIndicator());
                                      }
                                      Map<String,dynamic> data = snaps.data!.data() as Map<String,dynamic>;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                data.containsKey("photo_url") && snaps.data!.get("photo_url").length > 5
                                                    ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(40),
                                                  child: CachedNetworkImage(
                                                    imageUrl: snaps.data!.get("photo_url"),
                                                    placeholder: (context, url) =>
                                                        CircularProgressIndicator(),
                                                    errorWidget: (context, url, error) =>
                                                        Icon(Icons.error),
                                                    height: 35,
                                                    width: 35,
                                                  ),
                                                )
                                                    : Container(
                                                  height: 40,
                                                  width: 40,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border:
                                                    Border.all(color: Color(0xFFD30026), width: 1.5),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    snaps.data!
                                                        .get("display_name")
                                                        .toString()
                                                        .substring(0, 1),
                                                    style:
                                                    TextStyle(color: Color(0xFFD30026), fontSize: 18),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 12,
                                                ),
                                                Text(
                                                  snaps.data!.get("display_name"),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            InkWell(
                                              onTap:(){
                                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                                  return ChatScreen(
                                                    name: snaps.data!.get("display_name"),
                                                    uid: snaps.data!.get("uid"),
                                                    friendDate: snaps.data!.get("date").toDate(),
                                                    myDate: snap.data!.get("date").toDate(),
                                                    myName: snap.data!.get("display_name"),
                                                    url: data.containsKey("photo_url") ? snaps.data!.get("photo_url") : "",
                                                    myUrl: d.containsKey("photo_url") ? snap.data!.get("photo_url") : "",
                                                  );
                                                }));
                                              },
                                              child: SizedBox(
                                                height: 40,
                                                width: 40,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: SvgPicture.asset("assets/postImages/chat.svg"),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ) : Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text("No Friends",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 10,
                child: search.text.length > 0 ?
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return Container(
                      height: 300,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFBFE),
                        border:
                            Border.all(color: Colors.black.withOpacity(0.25)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          QueryDocumentSnapshot<Object?> data =
                              snapshot.data!.docs.elementAt(index);
                          if(data.get("uid") == FirebaseAuth.instance.currentUser!.uid){
                            return SizedBox();
                          }
                          if(!data.get("display_name").toString().toLowerCase().contains(search.text.toString().toLowerCase().trim())){
                            return SizedBox();
                          }
                          Map<String,dynamic> dat = snapshot.data!.docs.elementAt(index).data() as Map<String,dynamic>;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    dat.containsKey("photo_url") && data.get("photo_url").length > 5
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            child: CachedNetworkImage(
                                              imageUrl: data.get("photo_url"),
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                              height: 35,
                                              width: 35,
                                            ),
                                          )
                                        : Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Color(0xFFD30026),
                                                  width: 1.5),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              data
                                                  .get("display_name")
                                                  .toString()
                                                  .substring(0, 1),
                                              style: TextStyle(
                                                  color: Color(0xFFD30026),
                                                  fontSize: 18),
                                            ),
                                          ),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Text(
                                      data.get("display_name"),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                connectionList.contains(data.get("uid"))
                                    ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.blue,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10),
                                          child: Text(
                                            "Chat",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      )
                                    : requestList.contains(data.get("uid"))
                                        ? Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.green,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 10),
                                              child: Text(
                                                "Accept",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          )
                                        : pendingList.contains(data.get("uid"))
                                            ? InkWell(
                                                onTap: () {
                                                  onPending(data.get("display_name"), data.get("uid"));
                                                },
                                                child: SizedBox(
                                                  height: 40,
                                                  width: 40,
                                                  child: Icon(
                                                    Icons.pending,
                                                    color: Color(0xFFD30026),
                                                  ),
                                                ),
                                              )
                                            : InkWell(
                                                onTap: () {
                                                  sendRequest(data.get("uid"));
                                                },
                                                child: SizedBox(
                                                  height: 40,
                                                  width: 40,
                                                  child: Icon(
                                                    Icons.person_add_alt_1,
                                                    color: Color(0xFFD30026),
                                                  ),
                                                ),
                                              ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ): SizedBox(),
              ),
            ],
          ),
        );
      },
    );
  }

  onPending(String yo, String uid) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: EdgeInsets.zero,contentPadding: EdgeInsets.zero,
            title: Center(
                child: Text(
              yo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(0.75),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            )),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        "cancel",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xff151515),
                        ),
                      ),
                    ),
                  ),
                  MaterialButton(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    color: Colors.red,
                    minWidth: MediaQuery.of(context).size.width * 0.25,
                    height: 50,
                    onPressed: () {
                      cancelPending(uid);
                    },
                    child: Text(
                      'Cancel Request',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ],
          );
        });
  }
}
