import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taskapp/screen/postComments.dart';

class Post extends StatefulWidget {
  final Map<String,dynamic> d;
  final String id;
  const Post({Key? key, required this.d, required this.id}) : super(key: key);

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {

  Map<String,dynamic> d = {};
  String? dropDownIndex;
  var dropDownList = ["Like","Share","Comment"];

  bool more = false;


  String dura(Duration d){
    if(d.inSeconds > 2592000){
      return (d.inDays/30).toStringAsFixed(0) + " months ago";
    }else if(d.inSeconds > 86400){
      return d.inDays.toStringAsFixed(0) + " days ago";
    }else if(d.inSeconds > 3600){
      return d.inHours.toStringAsFixed(0) + " hours ago";
    }else if(d.inSeconds > 60){
      return d.inMinutes.toStringAsFixed(0) + " minutes ago";
    }else{
      return " just now";
    }
  }

  @override
  void initState() {
    super.initState();
    d = widget.d;
    setLikeFirebase2();
  }

  bool myLike = false;

  setLikeFirebase() async{
    await FirebaseFirestore.instance.collection("home_post").doc(widget.id).update({
      "like": d["like"],
    });
  }

  setLikeFirebase2() async{
    await FirebaseFirestore.instance.collection("home_post").doc(widget.id).collection("like").doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
      if(value.exists){
        if(value.get("like") == true){
          setState(() {
            myLike = true;
          });
        }
      }
    });
  }

  setLike(bool like)async{
    try{
      if(like){
        setState(() {
          d["like"] = d["like"] - 1;
        });
        await FirebaseFirestore.instance.collection("home_post").doc(widget.id).collection("like").doc(FirebaseAuth.instance.currentUser!.uid).set({
          "like": false,
        });

        myLike = false;
      }else{
        setState(() {
          d["like"] = d["like"] + 1;
        });
        await FirebaseFirestore.instance.collection("home_post").doc(widget.id).collection("like").doc(FirebaseAuth.instance.currentUser!.uid).set({
          "like": true,
        });
        myLike = true;
      }
      setLikeFirebase();
    }catch (e){
      print("Error: $e");
    }
    setState(() {

    });
  }

  snackBar(String s){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 3000),
        backgroundColor: Color(0xFFD30026),
        padding: EdgeInsets.symmetric(horizontal: 25,vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Text(s,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: d.containsKey("txt") ?
      Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent,
        child: Column(
          children: [
            SizedBox(
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      d.containsKey("photo_url") && d["photo_url"].length > 5
                          ? ClipRRect(
                        borderRadius:
                        BorderRadius.circular(25),
                        child: CachedNetworkImage(
                          imageUrl: d["photo_url"],
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget:
                              (context, url, error) =>
                              Icon(Icons.error),
                          height: 40,
                          width: 40,
                        ),
                      ) : Padding(
                        padding: const EdgeInsets.all(5),
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
                            d["display_name"]
                                .toString()
                                .substring(0, 1),
                            style: TextStyle(
                                color: Color(0xFFD30026),
                                fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d["display_name"],
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.75),
                                fontWeight: FontWeight.w500,
                                fontSize: 14
                            ),),
                          Text(dura(DateTime.now().difference(d["date"].toDate())),
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,

                            ),),
                        ],
                      ),
                    ],
                  ),

                  DropdownButton(
                    icon: const Icon(Icons.more_vert),
                    underline: SizedBox(),
                    items: dropDownList.map((value) => DropdownMenuItem(value: value,child:
                    Text(value,
                    style: TextStyle(
                      color: Colors.black
                    ),),)).toList(),
                    onChanged: (String? index) {
                      if(index == "Like"){
                        setLike(myLike);
                      }else if(index == "Share"){
                        share(d["img"].length > 5 ? d["img"] : "", d["display_name"], d["txt"]);
                      }else if(index == "Comment"){
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: PostComment(
                                  data: d,
                                  id: widget.id,
                                ))).then((value) {
                          setState(() {});
                        });
                      }else if(index == "Delete"){
                        showDelete("Delete post");
                      }
                    },

                  ),
                  // InkWell(
                  //   onTap: (){
                  //     if(d["uid"] == FirebaseAuth.instance.currentUser!.uid){
                  //       showDelete("Delete?");
                  //     }else{
                  //       snackBar("Permission denied");
                  //     }
                  //
                  //   },
                  //   child: SizedBox(
                  //     height: 45,
                  //     width: 45,
                  //     child: Icon(Icons.more_vert),
                  //   ),
                  // ),

                ],
              ),
            ),

            SizedBox(height: 10,),

            d["img"].length > 5 ?
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: d["img"],
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
                width: MediaQuery.of(context).size.width,
                height: 250,
                fit: BoxFit.fitWidth,
              ),
            ) : SizedBox(),

            Padding(
              padding: const EdgeInsets.only(left: 8.0,top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          more == true || d["txt"].length < 100 ? d["txt"] : d["txt"].toString().substring(0,99),
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.75),
                              fontWeight: FontWeight.w500,
                              fontSize: 14
                          ),),
                        d["txt"].length > 100 ?
                        Column(
                          children: [
                            SizedBox(height: 8,),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  more = !more;
                                });
                              },
                              child: Text(more == false ? "more.." : "less...",
                                style: TextStyle(
                                    color: Colors.blue.withOpacity(0.75),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14
                                ),),
                            ),
                            SizedBox(height: 2,),
                          ],
                        ) : SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 5,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [

                    InkWell(
                      onTap: (){
                        setLike(myLike);
                      },
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: myLike == false ?
                        Icon(Icons.favorite_border,) :
                        Center(child: SvgPicture.asset("assets/postImages/heart_filled.svg",width: 20,)),
                      ),
                    ),

                    InkWell(
                      onTap: ()async{
                        await Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: PostComment(
                                  data: d,
                                  id: widget.id,
                                ))).then((value) {
                          setState(() {});
                        });
                      },
                      child: SizedBox(
                        height: 40,
                        width: 30,
                        child: Center(child: SvgPicture.asset("assets/postImages/chat.svg",width: 20,)),
                      ),
                    ),

                    InkWell(
                      onTap: (){
                        share(d["img"].length > 5 ? d["img"] : "", d["display_name"], d["txt"]);
                      },
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: Center(child: SvgPicture.asset("assets/postImages/share.svg",width: 20,)),
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.favorite_border,size: 12,color: Colors.black.withOpacity(0.5),),
                        ),
                        SizedBox(width: 8,),
                        Text(d["like"].toString(),
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 12,
                          ),),
                      ],
                    ),
                    // Text("  .  "),
                    // Row(
                    //   children: [
                    //     Text("Comments",
                    //       style: TextStyle(
                    //         color: Colors.black.withOpacity(0.5),
                    //         fontSize: 12,
                    //       ),),
                    //     SizedBox(width: 8,),
                    //     Text(d["comment"].toString(),
                    //       style: TextStyle(
                    //         color: Colors.black.withOpacity(0.5),
                    //         fontSize: 12,
                    //       ),),
                    //   ],
                    // ),
                  ],
                ),

              ],
            ),

          ],
        ),
      ) : Center(child: CircularProgressIndicator()),
    );
  }

  share(String string,String name, String content)async{

    if(string.length > 0){
      final http.Response responseData = await http.get(Uri.parse(string));
      Uint8List uint8list = responseData.bodyBytes;
      var buffer = uint8list.buffer;
      ByteData byteData = ByteData.view(buffer);
      var tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/img').writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      Future.delayed(Duration(milliseconds: 250),(){
        Share.shareFiles([file.path], text: name + "\n\n" + content);
      });

    }else{
      Future.delayed(Duration(milliseconds: 250),(){
        Share.share(name + "\n\n" + content);
      });
      Navigator.of(context).pop();
    }
  }

  showDelete(String yo) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
                child: Text(
                  yo,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.75),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                )),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                child: Row(
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
                          "Cancel",
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
                      color: Color(0xFFD30026),
                      minWidth: MediaQuery.of(context).size.width*0.25,
                      height: 40,
                      onPressed: () async{
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        });
  }

}
