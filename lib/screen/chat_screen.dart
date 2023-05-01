import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String myName;
  final String uid;
  final DateTime friendDate;
  final DateTime myDate;
  final String url;
  final String myUrl;
  const ChatScreen({Key? key, required this.name, required this.uid, required this.url, required this.myUrl, required this.friendDate, required this.myDate, required this.myName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  String? catId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.myDate.difference(widget.friendDate).isNegative){
      catId = widget.uid + FirebaseAuth.instance.currentUser!.uid;
    }else{
      catId = FirebaseAuth.instance.currentUser!.uid + widget.uid;
    }
    setState(() {

    });
  }


  TextEditingController chat = TextEditingController();
  final ScrollController _controller = ScrollController();

  bool isMe = true;

  snackBar(String s){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 2000),
        backgroundColor: Color(0xFFD30026),
        padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Text(s,
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  sendTxt(String txt,bool img) async{
    if(txt.length == 0){
      return;
    }
    await FirebaseFirestore.instance.collection("chat").doc(DateTime.now().toString()).set({
      "msg": txt,
      "isImg": img,
      "date": DateTime.now(),
      "sender": FirebaseAuth.instance.currentUser!.uid,
      "receiver": widget.uid,
      "catId": catId,
    });
    setState(() {

    });
  }

  XFile? image;
  final ImagePicker picker = ImagePicker();

  pickImg()async{

    image = await picker.pickImage(source: ImageSource.gallery);

    if(image != null){
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {});
      await sendImg(image!.path);
      setState(() {
        chat.clear();
        _controller.jumpTo(_controller.position.maxScrollExtent);
      });
    }
  }


  sendImg(String imgPath) async{

    showLoad();

    try {
      await FirebaseStorage.instance
          .ref(
          "users/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now()}")
          .putFile(File(imgPath))
          .then((TaskSnapshot taskSnapshot) async{
        if (taskSnapshot.state == TaskState.success) {
          print("Image uploaded Successful");
          await taskSnapshot.ref.getDownloadURL().then((imageURL) async{
             await sendTxt(imageURL, true);
          });
        }
      });
    } catch (e) {
      print("Error $e");
    }

    Navigator.of(context).pop();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Container(child: Icon(Icons.keyboard_backspace,color: Colors.grey,))),
        title: InkWell(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: Container(
            child: Text(widget.name,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white.withOpacity(0.945),
        child: Stack(
          children: [
            Positioned(
              bottom: 80,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("chat")
                    .where("catId",isEqualTo: catId).snapshots(),
                builder: (context,snap){
                  if(!snap.hasData){
                    return Center(child: CircularProgressIndicator());
                  }
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height-180,
                    color: Colors.transparent,
                    alignment: Alignment.bottomCenter,
                    child: ListView.builder(
                      controller: _controller,
                      itemCount: snap.data!.docs.length,
                      shrinkWrap: true,
                      reverse: false,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context,index){
                        QueryDocumentSnapshot<Object?> data = snap.data!.docs.elementAt(index);
                        return data.get("sender") == FirebaseAuth.instance.currentUser!.uid ?
                        myMsg(data.get("msg"), data.get("date").toDate(), data.get("isImg")) :
                        friendsMsg(data.get("msg"), data.get("date").toDate(), data.get("isImg"));
                      },
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width*0.65,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(50),
                          bottomLeft: Radius.circular(50),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: TextFormField(
                        controller: chat,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.multiline,
                        maxLength: null,
                        maxLines: null,
                        decoration:
                        InputDecoration(
                          hintText: ' Type message here',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          enabledBorder:
                          OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          focusedBorder:
                          OutlineInputBorder(
                            borderSide: const
                            BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                        ),
                        style:  TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.35-20,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap:(){
                              pickImg();
                            },
                            child: SizedBox(
                              height: 60,
                              width: 60,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 17.5),
                                child: Icon(Icons.camera_alt_outlined),
                              ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: InkWell(
                              onTap: () async{
                                if(chat.text != "" && chat.text.isNotEmpty){
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  await sendTxt(chat.text.trim(),false);
                                  setState(() {
                                    chat.clear();
                                    _controller.jumpTo(_controller.position.maxScrollExtent);
                                  });
                                }
                              },
                              child: SvgPicture.asset("assets/postImages/send_msg.svg",height: 40,),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  myMsg(String s, DateTime dt, bool img){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          InkWell(
            onLongPress: ()async{
              if(img == false){
                await Clipboard.setData(ClipboardData(text: s));
                snackBar("Text copy successfully");
              }else{
                download("Download Image!", s);
              }
              
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFD30026),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(13),
                  topRight: const Radius.circular(13),
                  bottomLeft: const Radius.circular(13),
                  bottomRight: const Radius.circular(3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: s.length < 20 ? null : MediaQuery.of(context).size.width*0.6,
                      child: img == false ?
                      Text(s,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),) : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: s,
                            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text("${dt.hour.toString().padLeft(2,"0")}:${dt.minute.toString().padLeft(2,"0")}",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 11
                        ),),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children:  [
              SizedBox(width: 10,),
              widget.myUrl.length > 5 ?
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                    height: 37.5,
                    width: 37.5,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child:  CachedNetworkImage(
                      imageUrl: widget.myUrl,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )),
              ) :
              Container(
                  height: 37.5,
                  width: 37.5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFD30026),width: 1.5),
                  ),
                  child: Center(child: Text(widget.myName.substring(0,1),
                    style: TextStyle(
                        color: Color(0xFFD30026),
                        fontSize: 18,
                        fontWeight: FontWeight.w500
                    ),))
              ),

            ],
          ),
        ],
      ),
    );
  }

  friendsMsg(String s, DateTime dt, bool img){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          Row(
            children:  [
              SizedBox(width: 10,),
              widget.url.length > 5 ?
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Container(
                    height: 37.5,
                    width: 37.5,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child:  CachedNetworkImage(
                      imageUrl: widget.url,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )),
              ) :
              Container(
                  height: 37.5,
                  width: 37.5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFD30026),width: 1.5),
                  ),
                  child: Center(child: Text(widget.name.substring(0,1),
                    style: TextStyle(
                        color: Color(0xFFD30026),
                        fontSize: 18,
                        fontWeight: FontWeight.w500
                    ),))
              ),

            ],
          ),

          SizedBox(width: 5,),

          InkWell(
            onLongPress: ()async{
              if(img == false){
                await Clipboard.setData(ClipboardData(text: s));
                snackBar("Text copy successfully");
              }else{
                download("Download Image!", s);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(13),
                  topRight: const Radius.circular(13),
                  bottomLeft: const Radius.circular(13),
                  bottomRight: const Radius.circular(3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: s.length < 20 ? null : MediaQuery.of(context).size.width*0.6,
                      child: img == false ?
                      Text(s,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),) : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: s,
                            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text("${dt.hour.toString().padLeft(2,"0")}:${dt.minute.toString().padLeft(2,"0")}",
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 11
                        ),),
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
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

  download(String yo,String url) {
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
                      minWidth: MediaQuery.of(context).size.width*0.3,
                      height: 45,
                      onPressed: () async{
                        Future.delayed(Duration(milliseconds: 200),() async{
                          print(url);
                          down(url);
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Download',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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

  down(String url)async{
    showLoad();
    var response = await http.get(Uri.parse(url));
    final tempDir = await getTemporaryDirectory();
    File? file = await File('${tempDir.path}/image.png').create(recursive: true);
    file.writeAsBytesSync(response.bodyBytes);
    await GallerySaver.saveImage(file.path);
    Navigator.of(context).pop();
    snackBar("Image Downloaded");
  }

}
