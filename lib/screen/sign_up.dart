import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskapp/auth/auth.dart';
import 'package:taskapp/screen/landing_page.dart';
import 'package:taskapp/util/color.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool show = false;
  bool gLoad = false;

  double age = 1;

  bool load = false;

  @override
  void dispose() {
    super.dispose();
    load = false;
  }

  navi(){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
      return LandingPage();
    }));
  }

  snackBar(String s){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 4000),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Text(s,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // uploadPostImage(File file) async {
  //   print("in image");
  //   try {
  //     await FirebaseStorage.instance
  //         .ref(
  //         "users/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now()}")
  //         .putFile(file)
  //         .then((TaskSnapshot taskSnapshot) {
  //       if (taskSnapshot.state == TaskState.success) {
  //         print("Image uploaded Successful");
  //         taskSnapshot.ref.getDownloadURL().then((imageURL) {
  //           setState(() {
  //           });
  //         });
  //       }
  //     });
  //   } catch (e) {
  //     print("Error $e");
  //     Navigator.of(context).pop();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            // physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Register",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 32,
                          )),
                      Text("Welcome, Good to see you!",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          )),
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height*0.035,),

                Form(
                  key: formKey,
                  child: Column(
                    children: [

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Full Name:",
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              )),
                          const SizedBox(height: 5,),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: MyColor.lightBlack,
                            ),
                            alignment: Alignment.centerLeft,
                            child: TextFormField(
                              controller: name,
                              decoration: InputDecoration(
                                hintText: "  Full Name",
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.4),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.only(left: 10,top: 20),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return '  Field is required';
                                }

                                if(val.length < 2){
                                  return "  More than 1 character needed";
                                }

                                return null;
                              },
                              cursorColor: Colors.grey,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15,),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Email:",
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              )),
                          const SizedBox(height: 5,),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: MyColor.lightBlack,
                            ),
                            alignment: Alignment.center,
                            child: TextFormField(
                              controller: email,
                              decoration: InputDecoration(
                                hintText: "  name@example.com",
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.4),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.only(left: 10,top: 20),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return '  Field is required';
                                }

                                if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val)){
                                  return "  Invalid Email";
                                }

                                return null;
                              },
                              cursorColor: Colors.grey,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15,),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Password:",
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              )),
                          const SizedBox(height: 5,),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: MyColor.lightBlack,
                            ),
                            alignment: Alignment.center,
                            child: TextFormField(
                              controller: pass,
                              obscureText: !show,
                              decoration: InputDecoration(
                                hintText: "  ********",
                                hintStyle: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.4),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      show = !show;
                                    });
                                  },
                                  child: Icon(
                                    show == false ? Icons.remove_red_eye : Icons.close,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.only(left: 10,top: 20),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return '  Field is required';
                                }

                                if (val.length < 6) {
                                  return '  6 digits required';
                                }

                                return null;
                              },
                              cursorColor: Colors.grey,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              keyboardType: TextInputType.name,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15,),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Age:",
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              )),
                          const SizedBox(height: 5,),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: MyColor.lightBlack,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 50,
                                  width: 60,
                                  alignment: Alignment.center,
                                  child: Text(
                                    age.toStringAsFixed(0),
                                    style: GoogleFonts.poppins(
                                      color: MyColor.greyText,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay),
                                    child: Slider(
                                      onChanged: (_){
                                        setState(() {
                                          age = _;
                                        });
                                      },
                                      min: 0,
                                      max: 100,
                                      value: age,
                                      activeColor: MyColor.main,
                                      inactiveColor: const Color(0xffE5E5E5).withOpacity(0.3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),

                SizedBox(height: 35,),

                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 20.0),
                //   child: InkWell(
                //     onTap: () async{
                //       XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                //       if(image != null){
                //         await uploadPostImage(File(image.path));
                //         if(profilePic != null){
                //           setState(() {});
                //           snackBar("Profile Pic Uploaded Successfully");
                //         }
                //       }
                //     },
                //     child: Container(
                //       height: 56,
                //       width: MediaQuery.of(context).size.width,
                //       decoration: BoxDecoration(
                //         color: profilePic == null ? Colors.grey : Colors.green,
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //       alignment: Alignment.center,
                //       child: Text("Upload Profile Pic",
                //         style: GoogleFonts.poppins(
                //           color: Colors.white,
                //           fontWeight: FontWeight.w600,
                //           fontSize: 15,
                //         ),),
                //     ),
                //   ),
                // ),


                load == false ?
                InkWell(
                  onTap: () async{

                    if(!formKey.currentState!.validate()){
                      return;
                    }

                    // if(profilePic != null && profilePic!.length > 5){
                    //   return;
                    // }

                    FocusScope.of(context).requestFocus(FocusNode());

                    setState(() {
                      load = true;
                    });

                    try{

                      UserCredential user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text, password: pass.text);

                      if(user.user!.uid.isNotEmpty){
                        await FirebaseFirestore.instance.collection("users").doc(user.user!.uid).set({
                          "display_name": name.text,
                          "email": email.text,
                          "age": age.toStringAsFixed(0),
                          "date": DateTime.now(),
                          "uid": user.user!.uid,
                        });
                        navi();
                      }

                    } on FirebaseAuthException catch (e){

                      if (e.code == 'network-request-failed') {
                        snackBar('No Internet Connection');
                      } else if (e.code == "email-already-in-use") {
                        snackBar('Email already in use');
                      } else if (e.code == 'invalid-email') {
                        snackBar('Invalid Email');
                      }  else if (e.code == 'too-many-requests') {
                        snackBar('Too many attempts please try later');
                      } else if (e.code == 'weak-password') {
                        snackBar('Weak Password');
                      } else {
                        snackBar("Something went wrong");
                      }

                      setState(() {
                        load = false;
                      });

                      return;

                    }



                    setState(() {
                      load = false;
                    });

                  },
                  child: Container(
                    height: 56,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: MyColor.main,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text("Register",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),),
                  ),
                ) :const Center(child: CircularProgressIndicator(color: Colors.white,)),

                const SizedBox(height: 20,),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("OR",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: gLoad == false ?
                      InkWell(
                        onTap: () async{

                          setState(() {
                            gLoad = true;
                          });

                          try{

                            final user = await Auth().signInWithGoogle(context);

                            if(user != null && user.uid.isNotEmpty){

                              await FirebaseFirestore.instance.collection("users").doc(user.uid).get().then((value) async{
                                if(!value.exists){
                                  await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
                                    "display_name": user.displayName,
                                    "age": "1",
                                    "photo_url": user.photoURL,
                                    "email": user.email,
                                    "uid": user.uid,
                                    "date": DateTime.now(),
                                  });
                                }
                              });
                              navi();
                            }

                          }catch(e){
                            setState(() {
                              gLoad = false;
                            });
                          }

                          setState(() {
                            gLoad = false;
                          });
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset("assets/images/image 19.png",),
                              const SizedBox(width: 10,),
                              Text("Continue with Google",
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ) : const Center(child: CircularProgressIndicator(color: Colors.white,)),
                    ),
                  ],
                ),

                const SizedBox(height: 30,),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
