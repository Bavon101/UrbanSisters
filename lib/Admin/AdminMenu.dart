import 'package:backdrop/backdrop.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:urbansisters/Admin/AddProducts.dart';
import 'package:urbansisters/Admin/viewProducts.dart';
import 'package:urbansisters/Orders/AdminView.dart';
import 'package:urbansisters/Pages/SignIn.dart';
class AdminMenu extends StatefulWidget {
  final UserDetails user;
  AdminMenu(this.user);
  @override
  _AdminMenuState createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu> {
  @override
  Widget build(BuildContext context) {

    return BackdropScaffold(
      appBar: BackdropAppBar(
        title: Text('Admin user'),
      ),
      headerHeight: MediaQuery.of(context).size.height*.70,
      frontLayer: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 45),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddProducts())),
                  child: Container(
                    height: MediaQuery.of(context).size.height*.25,
                    decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Center(
                      child: Text('Add Product',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.3,
                            fontSize: 25
                        ),
                      ),

                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => AdminProductView(widget.user))),
                  child: Container(
                    height: MediaQuery.of(context).size.height*.25,
                    decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Center(
                      child: Text('View Products',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.3,
                            fontSize: 25
                        ),
                      ),

                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminView())),
                  child: Container(
                    height: MediaQuery.of(context).size.height*.25,
                    decoration: BoxDecoration(
                        color: Colors.purpleAccent,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Center(
                      child: Text('View Orders',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.3,
                            fontSize: 25
                        ),
                      ),

                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backLayer: Container(
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Container(
                  decoration:  BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(widget.user.photoUrl,
                        )
                    ),
                  )
              ),
              radius: MediaQuery.of(context).size.height*.05,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.user.userName,
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    icon: Icon(FontAwesomeIcons.signOutAlt),
                    onPressed: (){
                      GoogleSignIn _googleSignIn = GoogleSignIn();
                      _googleSignIn.signOut();
                      FirebaseAuth auth = FirebaseAuth.instance;
                      auth.signOut();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>SignIn()));
                      Fluttertoast.showToast(
                        backgroundColor: Colors.deepPurple,
                        textColor: Colors.white,
                        msg: "User Signed Out",
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    },
                  )
              ),
            ),
          ],
        ),
      )
    );
  }
}
