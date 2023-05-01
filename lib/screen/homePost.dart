import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:taskapp/screen/createPost.dart';
import 'package:taskapp/screen/landing_page.dart';
import 'package:taskapp/screen/post.dart';
import 'package:taskapp/screen/postData.dart';

class NewDiscover extends StatefulWidget {
  const NewDiscover({Key? key}) : super(key: key);

  @override
  State<NewDiscover> createState() => _NewDiscoverState();
}

class _NewDiscoverState extends State<NewDiscover> {

  // TextEditingController search = TextEditingController();
  // String? searchresult;

  String displayName(String name) {
    int i = name.indexOf(" ");
    if (i != -1) {
      return name.substring(0, i);
    } else {
      return name;
    }
  }

  // List<QueryDocumentSnapshot<Object?>> getSearchResult(List<QueryDocumentSnapshot<Object?>> list,){
  //   return list.where((element) => element.get("txt").toString().contains(search.text)).toList();
  // }


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
        Map<String, dynamic> data = snap.data!.data() as Map<String, dynamic>;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("home_post").orderBy("date",descending: true)
              .snapshots(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator());
            }
            return Scaffold(
              backgroundColor: Colors.grey.withOpacity(0.075),
              appBar: AppBar(
                elevation: 5,
                centerTitle: true,
                title: Text("MySpace",
                style: TextStyle(
                  color: Colors.black,
                ),),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                backgroundColor: Colors.white,
                actions: [
                  data.containsKey("photo_url") && data["photo_url"].length > 5
                      ? Padding(
                    padding: const EdgeInsets.all(9.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: InkWell(
                        onTap: () {
                          // Navigator.pushReplacement(context,
                          //     MaterialPageRoute(builder: (context) {
                          //       return MyProfileWidget();
                          //     }));
                        },
                        child: CachedNetworkImage(
                          imageUrl: data["photo_url"],
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: InkWell(
                      onTap: () {
                        // Navigator.pushReplacement(context,
                        //     MaterialPageRoute(builder: (context) {
                        //       return MyProfileWidget();
                        //     }));
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Color(0xFFD30026), width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          data["display_name"].toString().substring(0, 1),
                          style: TextStyle(
                              color: Color(0xFFD30026), fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Text(
                          "Hi ${displayName(data["display_name"])}!",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.025),
                              blurRadius: 5,
                              spreadRadius: 3,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                data.containsKey("photo_url") && data["photo_url"].length > 5
                                    ? SizedBox(
                                  height: 60,
                                  width: 60,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: InkWell(
                                        onTap: () {
                                          // Navigator.pushReplacement(context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) {
                                          //           return MyProfileWidget();
                                          //         }));
                                        },
                                        child: CachedNetworkImage(
                                          imageUrl: data["photo_url"],
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget:
                                              (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                    : InkWell(
                                  onTap: () {
                                    // Navigator.pushReplacement(context,
                                    //     MaterialPageRoute(builder: (context) {
                                    //       return MyProfileWidget();
                                    //     }));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Color(0xFFD30026),
                                            width: 1.5),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        data["display_name"].toString().substring(0, 1),
                                        style: TextStyle(
                                          color: Color(0xFFD30026),
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.bottomToTop,
                                            child: CreatePost(
                                              show: true,
                                            ))).then((value){
                                      if(PostData.newPost == true){
                                        setState(() {
                                          PostData.newPost = false;
                                        });
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                                          return LandingPage();
                                        }));
                                      }
                                    });
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width - 160,
                                    height: 60,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Create a post now.",
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.35),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.bottomToTop,
                                        child: CreatePost(
                                          show: true,
                                        ))).then((value) {
                                  if(PostData.newPost == true){
                                    setState(() {
                                      PostData.newPost = false;
                                    });
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                                      return LandingPage();
                                    }));
                                  }
                                });
                              },
                              child: Container(
                                height: 60,
                                width: 60,
                                alignment: Alignment.center,
                                child: SvgPicture.asset("assets/postImages/image.svg"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          Map<String,dynamic> d = snapshot.data!.docs.elementAt(index).data() as Map<String,dynamic>;
                          return Post(
                            d: d,
                            id: snapshot.data!.docs.elementAt(index).id,
                          );
                        },
                      ),
                      SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

