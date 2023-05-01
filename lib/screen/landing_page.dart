import 'package:animated_bottom_bar/animated_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskapp/screen/createPost.dart';
import 'package:taskapp/screen/friend_screen.dart';
import 'package:taskapp/screen/homePost.dart';
import 'package:taskapp/screen/profile_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  int select = 0;

  List pages = [
    NewDiscover(),
    CreatePost(show: false,),
    FriendScreen(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        exitScreen("Exit MySpace");
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: AnimatedBottomBar(

          width: MediaQuery.of(context).size.width - 30,

          color: Colors.white,

          height: MediaQuery.of(context).size.height*0.085,

          selectedIndex: select,

          items: [

            AnimatedBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Icon(Icons.home),
              ),
              activeColor: Colors.black,
              inactiveColor: Colors.black.withOpacity(0.35),
              title: Text("Home"),
            ),

            AnimatedBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Icon(Icons.post_add),
              ),
              activeColor: Colors.black,
              inactiveColor: Colors.black.withOpacity(0.35),
              title: Text("Post"),
            ),

            AnimatedBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Icon(Icons.chat_outlined),
              ),
              activeColor: Colors.black,
              inactiveColor: Colors.black.withOpacity(0.35),
              title: Text("Chat"),
            ),

            AnimatedBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Icon(Icons.person),
              ),
              activeColor: Colors.black,
              inactiveColor: Colors.black.withOpacity(0.35),
              title: Text("Profile"),
            ),

          ],
          onItemSelected: (_){
            setState((){
              select = _;
            });
          },
        ),
        body: pages[select],
      ),
    );
  }

  exitScreen(String yo) {
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
                      onPressed: () {
                        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                      },
                      child: Text(
                        'Exit',
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

}
