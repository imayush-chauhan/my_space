import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskapp/screen/signIn.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final formKey = GlobalKey<FormState>();

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  String profilePicUrl = "";

  bool load = true;

  getData() async{
    await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
      if(value.exists){
        Map<String,dynamic> data = value.data()!;

        if(data.containsKey("display_name")){
          name.text = data["display_name"];
        }

        if(data.containsKey("photo_url")){
          profilePicUrl = data["photo_url"];
        }

        if(data.containsKey("email")){
          email.text = data["email"];
        }

        if(data.containsKey("phone")){
          phone.text = data["phone"];
        }


        setState(() {});
      }
    });


    setState(() {
      load = false;
    });

  }

  XFile? photo;

  pickImage() async{
    photo = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  updateProfilePic() async{
    await FirebaseStorage.instance.ref("users/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now()}").putFile(File(photo!.path))
        .then((TaskSnapshot taskSnapshot) {
      if (taskSnapshot.state == TaskState.success) {
        print("Image uploaded Successful");
        // Get Image URL Now
        taskSnapshot.ref.getDownloadURL().then(
                (imageURL) {
              FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update({
                "photo_url": imageURL,
              });
              print("Image Download URL is $imageURL");
            });
      }
      else if (taskSnapshot.state == TaskState.running) {
        // Show Prgress indicator
      }
      else if (taskSnapshot.state == TaskState.error) {
        print("Error: ${TaskState.error}");
        // Handle Error Here
      }
    }).catchError((e){
      snackBar("Something went wrong");
    });
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

  updateProfile(String name, String phone)async{
    await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update({
      "display_name": name,
      "photo_url": profilePicUrl,
      "phone": phone,
    }).catchError((e){
      snackBar("Something went wrong");
    });
    if(photo != null){
      await updateProfilePic();
    }
    snackBar("Profile Updated Successfully");
  }

  @override
  Widget build(BuildContext context) {
    double mediaQH = MediaQuery.of(context).size.height;
    double mediaQW = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text("Profile",
          style: TextStyle(
            color: Colors.black,
          ),),
        actions: [
          InkWell(
            onTap: (){
              FocusManager.instance.primaryFocus?.unfocus();
              if(formKey.currentState!.validate()){
                updateProfile(name.text, phone.text);
              }
            },
            child: Container(
              width: mediaQW*0.2,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Text("Save",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: mediaQW*0.045,
                ),),
            ),
          ),
        ],
      ),
      body: load == false ?
      Container(
        height: mediaQH,
        width: mediaQW,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Form(
              key: formKey,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    profilePic(mediaQW),

                    SizedBox(height: 10,),

                    textField(mediaQW, name, "Name",TextInputType.text,false),

                    textField(mediaQW, email, "Email",TextInputType.text,true),

                    textFieldPhone(mediaQW, phone, "Phone",TextInputType.number,"+91"),

                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: InkWell(
                onTap: (){
                  logout("Log Out?");
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width*0.8,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text("Log out",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                    ),),
                ),
              ),
            ),

          ],
        ),
      ) : Center(child: CircularProgressIndicator()),
    );
  }

  profilePic(double mediaQW){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(mediaQW*0.18/2),
            child: Container(
              height: mediaQW*0.18,
              width: mediaQW*0.18,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey
              ),
              child: profilePicUrl != "" ?
              CachedNetworkImage(
                imageUrl: profilePicUrl,
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
              )
              // Image.network(profilePicUrl,fit: BoxFit.cover,)
                  :
              photo == null ?
              Icon(Icons.person,color: Colors.black.withOpacity(0.75),size: mediaQW*0.075,) :
              Image.file(File(photo!.path),fit: BoxFit.cover,),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: InkWell(
              onTap: (){
                pickImage();
              },
              child: Text("Change Profile Pic",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  textField(double mediaQW, TextEditingController controller, String name,TextInputType? type,bool? read){
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 55,
        width: mediaQW*0.85,
        child: TextFormField(
          controller: controller,
          keyboardType: type ?? TextInputType.multiline,
          cursorColor: Colors.black,
          readOnly: read ?? false,
          validator: (_){
            if(_!.length > 0){
              return null;
            }
            return "Empty";
          },
          decoration: InputDecoration(
            labelText: name,
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
    );
  }

  textFieldPhone(double mediaQW, TextEditingController controller, String name,TextInputType? type,String? suff){
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 55,
        width: mediaQW*0.85,
        child: TextFormField(
          controller: controller,
          keyboardType: type ?? TextInputType.multiline,
          cursorColor: Colors.black,
          validator: (_){
            if(_!.length == 10){
              return null;
            }
            return "Invalid Phone Number";
          },
          decoration: InputDecoration(
            labelText: name,
            labelStyle: TextStyle(color: Colors.black),
            prefix: Text(suff! + " "),
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
    );
  }

  logout(String yo) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  SizedBox(),
                  MaterialButton(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    color: Colors.red,
                    minWidth: MediaQuery.of(context).size.width * 0.25,
                    height: 50,
                    onPressed: () async{
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                        return SignIn();
                      }));
                    },
                    child: Text(
                      'Log out',
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
