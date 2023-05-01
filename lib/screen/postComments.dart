import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostComment extends StatefulWidget {
  final Map<String, dynamic> data;
  final String id;

  const PostComment({Key? key, required this.data, required this.id})
      : super(key: key);

  @override
  State<PostComment> createState() => _PostCommentState();
}

class _PostCommentState extends State<PostComment> {
  TextEditingController comment = TextEditingController();
  Map<String, dynamic> d = {};

  String dura(Duration d) {
    if (d.inSeconds > 2592000) {
      return (d.inDays / 30).toStringAsFixed(0) + " months";
    } else if (d.inSeconds > 86400) {
      return d.inDays.toStringAsFixed(0) + " days";
    } else if (d.inSeconds > 3600) {
      return d.inHours.toStringAsFixed(0) + " hr";
    } else if (d.inSeconds > 60) {
      return d.inMinutes.toStringAsFixed(0) + " min";
    } else {
      return " just now";
    }
  }

  @override
  void initState() {
    super.initState();
    d = widget.data;
    setPrefs();
  }

  late SharedPreferences prefs;

  setPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  bool getLike(String id) {
    return prefs.getBool(id) ?? false;
  }

  setLike(QueryDocumentSnapshot<Object?> id) async {
    if (getLike(id.id)) {
      await prefs.setBool(id.id, false);
      setState(() {});
      int l = id.get("like") - 1;
      await id.reference.update({
        "like": l,
      });
    } else {
      await prefs.setBool(id.id, true);
      setState(() {});
      int l = id.get("like") + 1;
      await id.reference.update({
        "like": l,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: SizedBox(
            child: Icon(
              Icons.keyboard_backspace,
              color: Colors.black.withOpacity(0.75),
            ),
          ),
        ),
        title: InkWell(
          onTap: () {
            setState(() {});
          },
          child: Text(
            "Comments",
            style: TextStyle(
              color: Colors.black.withOpacity(0.75),
            ),
          ),
        ),
        actions: [
          SizedBox(
            width: 60,
            child: Center(child: SvgPicture.asset("assets/postImages/share.svg",width: 20,)),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          d.containsKey("photo_url") && d["photo_url"].length > 5
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: CachedNetworkImage(
                                    imageUrl: d["photo_url"],
                                    placeholder: (context, url) =>
                                        Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                    height: 40,
                                    width: 40,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Color(0xFFD30026), width: 1.5),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      d["display_name"].toString().substring(0, 1),
                                      style: TextStyle(
                                          color: Color(0xFFD30026), fontSize: 18),
                                    ),
                                  ),
                                ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    d["display_name"],
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.75),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    dura(DateTime.now()
                                        .difference(d["date"].toDate())),
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.5),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width*0.65,
                                child: Text(
                                  d["txt"],
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.75),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("home_post")
                          .doc(widget.id)
                          .collection("comments")
                          .orderBy("date", descending: true)
                          .snapshots(),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ListView.builder(
                          itemCount: snap.data!.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(snap.data!.docs.elementAt(index).get("uid"))
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                                return commentPost(
                                    MediaQuery.of(context).size.width * 0.65,
                                    data,
                                    snap.data!.docs.elementAt(index),false,true);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: Column(
              children: [
                isReply == null ? SizedBox() : replyTo(isReply ?? ""),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return SizedBox();
                    }
                    Map<String, dynamic> data =
                    snap.data!.data() as Map<String, dynamic>;
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: TextFormField(
                        controller: comment,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.multiline,
                        maxLength: null,
                        maxLines: null,
                        decoration: InputDecoration(
                          prefixIcon: SizedBox(
                            width: 70,
                            height: 60,
                            child: data.containsKey("photo_url") && data["photo_url"].length > 5
                                ? Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CachedNetworkImage(
                                  imageUrl: data["photo_url"],
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                  height: 40,
                                  width: 40,
                                ),
                              ),
                            )
                                : Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Color(0xFFD30026),
                                      width: 1.5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  data["display_name"]
                                      .toString()
                                      .substring(0, 1),
                                  style: TextStyle(
                                      color: Color(0xFFD30026),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          hintText: ' Type message here',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          suffixIcon: InkWell(
                            onTap: () {
                              if (comment.text.length > 0) {
                                if(isReply == null){
                                  sendComment();
                                }else{
                                  sendComment2();
                                }

                              } else {
                                snackBar("Comment is empty");
                              }
                            },
                            child: SizedBox(
                              height: 60,
                              width: 60,
                              child: Center(child: Text("Post")),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                          ),
                          contentPadding:
                          const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  sendComment() async {
    await FirebaseFirestore.instance
        .collection("home_post")
        .doc(widget.id)
        .collection("comments")
        .add({
      "date": DateTime.now(),
      "uid": FirebaseAuth.instance.currentUser!.uid,
      "comment": comment.text,
      "like": 0,
      "reply": 0
    });
    setState(() {
      FocusManager.instance.primaryFocus?.unfocus();
      comment.clear();
    });
  }

  sendComment2() async {
    if (replyComment != null) {
      await replyComment!.reference.collection("reply").add({
        "date": DateTime.now(),
        "uid": FirebaseAuth.instance.currentUser!.uid,
        "comment": comment.text,
        "like": 0,
      });

      int l = replyComment!.get("reply") + 1;
      await replyComment!.reference.update({
        "reply": l
      });

      setState(() {
        isReply = null;
        replyComment = null;
        FocusManager.instance.primaryFocus?.unfocus();
        comment.clear();
      });
    }
  }

  String? isReply;
  QueryDocumentSnapshot<Object?>? replyComment;

  replyTo(String name) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.15),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                "Reply to @$name",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isReply = null;
                });
              },
              child: SizedBox(
                height: 50,
                width: 50,
                child: Icon(
                  Icons.close,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  commentPost(double width,Map<String, dynamic> data, QueryDocumentSnapshot<Object?> snap, bool show,bool comment){
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  data.containsKey("photo_url") && data["photo_url"].length > 5
                      ? ClipRRect(
                    borderRadius:
                    BorderRadius.circular(25),
                    child: CachedNetworkImage(
                      imageUrl: data["photo_url"],
                      placeholder: (context, url) =>
                          Center(
                              child:
                              CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) =>
                          Icon(Icons.error),
                      height: 40,
                      width: 40,
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Color(0xFFD30026),
                            width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        data["display_name"]
                            .toString()
                            .substring(0, 1),
                        style: TextStyle(
                            color: Color(0xFFD30026),
                            fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            data["display_name"],
                            style: TextStyle(
                              color: Colors.black
                                  .withOpacity(0.75),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            dura(DateTime.now().difference(
                                snap.get("date")
                                    .toDate())),
                            style: TextStyle(
                                color: Colors.black
                                    .withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        width: width,
                        child: Text(
                          snap.get("comment"),
                          style: TextStyle(
                            color: Colors.black
                                .withOpacity(0.75),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      comment == true ?
                      InkWell(
                        onTap: () {
                          setState(() {
                            isReply = data["display_name"];
                            replyComment = snap;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: SizedBox(
                            height: 18,
                            width: 50,
                            child: Text(
                              "reply",
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ): SizedBox(),
                      comment == true && snap.get("reply") > 0 ?
                      replyPost(snap)
                      //     show == false ?
                      // GestureDetector(
                      //   onTap: (){
                      //     setState(() {
                      //       show = true;
                      //     });
                      //     print(show);
                      //   },
                      //   child: Row(
                      //     children: [
                      //       Padding(
                      //         padding: const EdgeInsets.symmetric(vertical: 8.0),
                      //         child: Container(
                      //           height: 1,
                      //           width: 50,
                      //           color: Colors.black.withOpacity(0.5),
                      //         ),
                      //       ),
                      //       Text("  view ${snap.get("reply")} reply"),
                      //     ],
                      //   ),
                      // ) : replyPost(snap)
                          : SizedBox(),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5.0,top: 5),
                child: InkWell(
                  onTap: () {
                    setLike(snap);
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        height: 35,
                        child: Column(
                          children: [
                            !getLike(snap.id)
                                ? Icon(
                              Icons.favorite_border,
                              color: Colors.black
                                  .withOpacity(0.75),
                              size: 18,
                            )
                                : Center(child: SvgPicture.asset("assets/postImages/heart_filled.svg",width: 16,)),
                            Text(snap.get("like").toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  replyPost(QueryDocumentSnapshot<Object?> snap){
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width-110,
        child: StreamBuilder<QuerySnapshot>(
          stream: snap.reference.collection("reply").snapshots(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return SizedBox();
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              itemBuilder: (context,index){
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection("users").doc(snapshot.data!.docs.elementAt(index).get("uid")).snapshots(),
                  builder: (context, snaps){
                    if(!snaps.hasData){
                      return SizedBox();
                    }
                    Map<String,dynamic> data = snaps.data!.data() as Map<String,dynamic>;
                    return commentPost(MediaQuery.of(context)
                        .size
                        .width *
                        0.35,data, snapshot.data!.docs.elementAt(index), false,false);
                  },
                );
              },
            );
          },
        ),
      ),
    );
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
}

// class Comment extends StatefulWidget {
//   final Map<String, dynamic> data;
//   final Map<String, dynamic> snap;
//   final DocumentReference dr;
//   const Comment({Key? key, required this.data, required this.snap, required this.dr}) : super(key: key);
//
//   @override
//   State<Comment> createState() => _CommentState();
// }
//
// class _CommentState extends State<Comment> {
//
//   String dura(Duration d) {
//     if (d.inSeconds > 2592000) {
//       return (d.inDays / 30).toStringAsFixed(0) + " months";
//     } else if (d.inSeconds > 86400) {
//       return d.inDays.toStringAsFixed(0) + " days";
//     } else if (d.inSeconds > 3600) {
//       return d.inHours.toStringAsFixed(0) + " hr";
//     } else if (d.inSeconds > 60) {
//       return d.inMinutes.toStringAsFixed(0) + " min";
//     } else {
//       return " just now";
//     }
//   }
//
//   late Map<String, dynamic> data;
//   late Map<String, dynamic> snap;
//
//   @override
//   void initState() {
//     super.initState();
//     data = widget.data;
//     snap = widget.snap;
//     getLike();
//   }
//
//   bool myLike = false;
//
//   getLike() async{
//     await widget.dr.collection("like")
//         .doc(FirebaseAuth.instance.currentUser!.uid)
//         .get().then((value) {
//       if(value.exists){
//         if(value.get("like") == true){
//           setState(() {
//             myLike = true;
//           });
//         }
//       }
//     });
//   }
//
//   setLike()async{
//     if(myLike == false){
//       snap["like"] = snap["like"] + 1;
//       await widget.dr.update({
//         "like": snap["like"]
//       });
//       setState(() {
//         myLike = true;
//       });
//       await widget.dr.collection("like")
//           .doc(FirebaseAuth.instance.currentUser!.uid)
//           .set({
//         "like": true,
//       });
//     }else{
//       snap["like"] = snap["like"] - 1;
//       await widget.dr.update({
//         "like": snap["like"],
//       });
//       setState(() {
//         myLike = false;
//       });
//       await widget.dr.collection("like")
//           .doc(FirebaseAuth.instance.currentUser!.uid)
//           .set({
//         "like": false,
//       });
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return ;
//   }
// }
