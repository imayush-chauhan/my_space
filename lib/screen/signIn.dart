import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:taskapp/auth/auth.dart';
import 'package:taskapp/screen/main_screen.dart';
import 'package:taskapp/screen/sign_up.dart';
import 'package:taskapp/util/color.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool show = false;
  bool load = false;
  bool gLoad = false;

  navi(String? s){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
      return HomeScreen(name: s ?? "Guest Name",);
    }));
  }

  @override
  void dispose() {
    super.dispose();
    load = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: MyColor.black,
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SingleChildScrollView(
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
                            Text("Sign in",
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

                      SizedBox(height: MediaQuery.of(context).size.height*0.04,),

                      Form(
                        key: formKey,
                        child: Column(
                          children: [
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
                                  alignment: Alignment.centerLeft,
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
                                  alignment: Alignment.centerLeft,
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

                          ],
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.width*0.08,),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          load == false ?
                          InkWell(
                            onTap: () async{

                              if(!formKey.currentState!.validate()){
                                return;
                              }

                              FocusScope.of(context).requestFocus(FocusNode());

                              setState(() {
                                load = true;
                              });


                              try{

                                UserCredential user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: pass.text);

                                if(user.user!.uid.isNotEmpty){
                                  await FirebaseFirestore.instance.collection("users").doc(user.user!.uid).get().then((value) async{
                                    if(!value.exists){
                                      snackBar("Account Doesn't Exist");
                                    }else{
                                      navi(value.get("name"));
                                    }
                                  });

                                }

                              } on FirebaseAuthException catch (e){

                                if (e.code == 'network-request-failed') {
                                  snackBar('No Internet Connection');
                                } else if (e.code == "wrong-password") {
                                  snackBar('Please Enter correct password');
                                } else if (e.code == 'user-not-found') {
                                  snackBar('Email not found');
                                }  else if (e.code == 'too-many-requests') {
                                  snackBar('Too many attempts please try later');
                                }else {
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
                              child: Text("Log In",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),),
                            ),
                          ) : const Center(child: CircularProgressIndicator(color: Colors.white,)),

                          const SizedBox(height: 20,),

                          Text("Forgot Password?",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                            ),),
                        ],
                      ),

                      const SizedBox(height: 30,),

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

                                  if(user!= null && user.uid.isNotEmpty){

                                    await FirebaseFirestore.instance.collection("users").doc(user.uid).get().then((value) async{
                                      if(!value.exists){
                                        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
                                          "name": user.displayName,
                                          "age": "1",
                                          "email": user.email,
                                          "uid": user.uid,
                                          "date": DateTime.now(),
                                        });
                                      }
                                    });

                                    navi(user.displayName);
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
                                height: 56,
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
                    ],
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ",
                        style: GoogleFonts.poppins(
                          color: MyColor.greyText,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, PageTransition(
                            duration: const Duration(milliseconds: 500),
                            type: PageTransitionType.rightToLeft,
                            curve: Curves.linear,
                            child: const SignUp(),
                          ),);
                        },
                        child: Text("Register Now",
                          style: GoogleFonts.poppins(
                            color: MyColor.main2,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
