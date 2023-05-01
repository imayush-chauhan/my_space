import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taskapp/screen/postData.dart';
import 'package:http/http.dart' as http;

class CreatePost extends StatefulWidget {
  final bool show;
  CreatePost({required this.show});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  TextEditingController txt = TextEditingController();
  TextEditingController forum = TextEditingController();
  final ImagePicker picker = ImagePicker();

  String key = "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";

  bool ai = false;
  String? aiUrl;

  XFile? image;
  XFile? video;

  post(String s,String photo, String name) async {
    print("in post");
    print(s);
    await FirebaseFirestore.instance.collection("home_post").add({
      "date": DateTime.now(),
      "uid": FirebaseAuth.instance.currentUser!.uid,
      "txt": txt.text,
      "img": s,
      "display_name": name,
      "photo_url": photo,
      "like": 0,
      "comment": 0,
    });
    Navigator.of(context).pop();
    snackBar("Successfully Posted");
    if(widget.show == true){
      Future.delayed(Duration(milliseconds: 2200), () {
        setState(() {
          PostData.newPost = true;
        });
        Navigator.of(context).pop();
      });
    }
    setState(() {
      ai = false;
      txt.clear();
      aiUrl = null;
      forum.clear();
    });
  }

  uploadPostImage(File file,String photo, String name) async {
    print("in image");

    try {
      await FirebaseStorage.instance
          .ref(
              "users/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now()}")
          .putFile(file)
          .then((TaskSnapshot taskSnapshot) async{
        if (taskSnapshot.state == TaskState.success) {
          print("Image uploaded Successful");
          await taskSnapshot.ref.getDownloadURL().then((imageURL) async{
            await post(imageURL,photo,name);
          });
        }
      });
    } catch (e) {
      print("Error $e");
      Navigator.of(context).pop();
    }
  }

  bool load = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
      builder: (context,snap){
        if(!snap.hasData){
          return Center(child: CircularProgressIndicator());
        }
        Map<String,dynamic> da = snap.data!.data() as Map<String,dynamic>;
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            titleSpacing: 0,
            title:
            da.containsKey("photo_url") && snap.data!.get("photo_url").length > 5
                ? ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: CachedNetworkImage(
                imageUrl: snap.data!.get("photo_url"),
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
                height: 35,
                width: 35,
              ),
            )
                : Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFFD30026), width: 1.5),
              ),
              alignment: Alignment.center, child: Text(
                snap.data!.get("display_name").toString().substring(0,1),
                style: TextStyle(color: Color(0xFFD30026), fontSize: 18),
              ),
            ),
            leading: widget.show == true ?
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: SizedBox(
                height: 80,
                width: 80,
                child: Icon(
                  Icons.close,
                  color: Colors.black.withOpacity(0.75),
                ),
              ),
            ) : SizedBox(),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                child: InkWell(
                  onTap: () {
                    if (load == false) {
                      setState(() {
                        load = true;
                      });
                      showLoad();
                      if (txt.text.length > 0) {
                        if(ai == false){
                          if (image == null) {
                            post("",snap.data!.get("photo_url"),snap.data!.get("display_name"));
                          } else {
                            uploadPostImage(File(image!.path),snap.data!.get("photo_url"),snap.data!.get("display_name"));
                          }
                        }else{
                          if(ai == true && aiUrl != null){
                            _asyncMethod(aiUrl!,snap.data!.get("photo_url"),snap.data!.get("display_name"));
                          }else{
                            snackBar("Empty Post");
                          }
                        }
                      } else {
                        snackBar("Empty Post");
                      }
                      setState(() {
                        load = false;
                      });
                    }
                  },
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      color: load == false ? Color(0xFFD30026) : Colors.grey,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    alignment: Alignment.center,
                    child: load == false
                        ? Text(
                      "Post",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                        : Text(
                      "...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          body: Column(
            children: [
              SizedBox(
                height: 10,
              ),

              ai == false ?
              Column(
                children: [
                  image == null
                      ? SizedBox(
                    height: 0,
                  )
                      : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(image!.path),
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.width * 0.6,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      Positioned(
                        top: 5,
                        left: 5,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              image = null;
                            });
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: TextFormField(
                      maxLines: null,
                      maxLength: null,
                      keyboardType: TextInputType.multiline,
                      controller: txt,
                      cursorColor: Colors.black.withOpacity(0.75),
                      decoration: InputDecoration(
                        hintText: " What do you want to talk about?",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  image == null
                      ? InkWell(
                    onTap: () async {
                      image = await picker.pickImage(source: ImageSource.gallery);
                      setState(() {
                        video = null;
                      });
                    },
                    child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Icon(
                              Icons.image,
                              color: Colors.black.withOpacity(0.75),
                              size: 25,
                            ),
                          ),
                          Text(
                            "Add a photo",
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.75),
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ) : SizedBox(),

                  InkWell(
                    onTap: () {
                      setState(() {
                        ai = true;
                        txt.clear();
                      });
                    },
                    child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Icon(
                              Icons.blur_circular,
                              color: Colors.black.withOpacity(0.75),
                              size: 25,
                            ),
                          ),
                          Text("Create post with AI",
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.75),
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ) : SizedBox(
                height: MediaQuery.of(context).size.height-100,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: load == false && txt.text.length <= 2 ?
                  Column(
                    children: [
                      Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width*0.85,
                        child: TextFormField(
                          controller: forum,
                          maxLines: null,
                          maxLength: null,
                          keyboardType: TextInputType.multiline,
                          cursorColor: Colors.black,
                          validator: (_){
                            if(_!.length > 0){
                              return null;
                            }
                            return "Empty";
                          },
                          decoration: InputDecoration(
                            labelText: "Post Title",
                            labelStyle: TextStyle(color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),

                      SizedBox(height: 15,),

                      InkWell(
                        onTap: ()async{
                          setState(() {
                            load = true;
                          });
                          await getTxt(forum.text,snap.data!.get("photo_url"),snap.data!.get("display_name"));
                          setState(() {
                            load = false;
                          });
                        },
                        child:
                        Container(
                          width: 150,
                          height: 45,
                          decoration: BoxDecoration(
                            color: load == false ? Color(0xFFD30026) : Colors.grey,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Generate Post",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 25,),

                      InkWell(
                        onTap: () {
                          setState(() {
                            ai = false;
                            txt.clear();
                          });
                        },
                        child: SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Icon(
                                  Icons.download,
                                  color: Colors.black.withOpacity(0.75),
                                  size: 25,
                                ),
                              ),
                              Text("Upload from devive",
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.75),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ) : Column(
                    children: [
                      txt.text.length > 0 ?
                          Column(
                            children: [

                              aiUrl == null ?
                                  Center(child: CircularProgressIndicator()):
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: aiUrl!,
                                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                  height: MediaQuery.of(context).size.width*0.6,
                                  width: MediaQuery.of(context).size.width*0.6,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20),
                                child: Text(txt.text),
                              ),
                            ],
                          ) :
                      Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),

              // video == null ? SizedBox():
              // Image.file(File(image!.path)),



            ],
          ),
        );
      },
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

  getTxt(String text,String photo, String name)async{

    print("in");

    try{

      final res = await http.post(Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $key"
        },

        body: json.encode({
          "model": "gpt-3.5-turbo",
          "messages": [{"role": "user", "content": text}],
        }),);

      Map<String,dynamic> d = jsonDecode(res.body);

      print(d);

      if(res.statusCode == 200){
        setState(() {
          txt.text = d["choices"][0]["message"]["content"].toString().trim();
        });
        if(txt.text.length > 0){
          await getImg(text,photo,name);
        }else{
          snackBar("something went wrong");
        }

      }

    }catch (e) {

      print("Error: $e");

    }

    print("out");

  }

  getImg(String txt,String photo, String name)async{

    print("in");

    try{

      final res = await http.post(Uri.parse("https://api.openai.com/v1/images/generations"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $key"
        },

        body: json.encode({
          "prompt": txt + " in english",
          "n": 1,
          "size": "1024x1024"
        }),);

      Map<String,dynamic> d = jsonDecode(res.body);

      print(d);
      if(res.statusCode == 200){
        setState(() {
          aiUrl = d["data"][0]["url"];
        });
        // await _asyncMethod(d["data"][0]["url"],photo,name);
      }


    }catch (e) {

      print("Error: $e");

    }

    print("out");

  }

  _asyncMethod(String url,String photo, String name) async {
    var response = await http.get(Uri.parse(url));
    final tempDir = await getTemporaryDirectory();
    File? file = await File('${tempDir.path}/image.png').create(recursive: true);
    file.writeAsBytesSync(response.bodyBytes);
    await uploadPostImage(file,photo,name);
  }

  showLoad() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(child: CircularProgressIndicator()),
                Text(
                  "Loading...",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                )
              ],
            ),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          );
        });
  }
}
