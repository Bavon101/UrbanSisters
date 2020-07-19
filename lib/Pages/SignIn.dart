import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:urbansisters/Admin/AdminMenu.dart';
import 'package:urbansisters/Pages/HomePage.dart';
import 'package:urbansisters/widgets/LoadDialog.dart';
class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  DateTime today = new DateTime.now();
   String userId;
   bool admin = false;
  buildId(){

    setState(() {
       String userId1 = today.year.toString() + today.weekday.toString() + today.month.toString() + today.day.toString() + today.hour.toString() + today.microsecond.toString() + today.minute.toString()+today.millisecond.toString();
        userId = userId1;
    });
  }
  //google sign in
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  logToFirebase fireLog = new logToFirebase();
  _login() async{
    try{
      Dialogs.showLoadingDialog(context, _keyLoader);
      await _googleSignIn.signIn();
     // UserDetails userDetails = new UserDetails(_googleSignIn.currentUser.displayName, _googleSignIn.currentUser.photoUrl, _googleSignIn.currentUser.email,promoCode,userId);
      //print(userDetails.userName);
      dynamic results = await fireLog.SignInAnn();
      if(results == null){
        print("Error logging user");

      }else{
        ///loguser
        try{
          DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('userData');
          databaseReference.orderByChild('mail').startAt(_googleSignIn.currentUser.email.toString().trim()).endAt(_googleSignIn.currentUser.email.toString().trim() +"\uf8ff").limitToFirst(1).once()
              .then((DataSnapshot snap) async {
            var Keys = snap.value.keys;
            var Data = snap.value;
            for(var byKey in Keys){
              if (Data[byKey]['mail'].toString().compareTo(_googleSignIn.currentUser.email) == 0) {
                String userId = Data[byKey]['id'];
                String userCode = Data[byKey]['code'];
                UserDetails _user = new UserDetails(
                    _googleSignIn.currentUser.displayName, _googleSignIn.currentUser.photoUrl,
                    _googleSignIn.currentUser.email, userCode, userId);
                Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
                Fluttertoast.showToast(
                  backgroundColor: Colors.deepPurple,
                  textColor: Colors.white,
                  msg: "welcome ${_user.userName}",
                  toastLength: Toast.LENGTH_SHORT,
                );
                if (admin) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminMenu(_user)));
                }
                else{
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage(_user)));
                }


              }
            }
          }).catchError((e) async {
            print('ERROR $e');
            Fluttertoast.showToast(
              backgroundColor: Colors.deepPurple,
              textColor: Colors.white,
              msg: "New User detected",
              toastLength: Toast.LENGTH_SHORT,
            );
            final dataBase = FirebaseDatabase.instance.reference().child("userData");
            final String userId = today.year.toString() + today.weekday.toString() + today.month.toString() + today.day.toString() + today.hour.toString() + today.microsecond.toString() + today.minute.toString()+today.millisecond.toString();
            final String promoCode = 'e${_googleSignIn.currentUser.displayName.substring(1,3)}${userId.substring(5,9)}';
            UserDetails _user = new UserDetails(
                _googleSignIn.currentUser.displayName, _googleSignIn.currentUser.photoUrl, _googleSignIn.currentUser.email,
                promoCode, userId);
            ///add items to sql
            dataBase.push().set(_user.map());
            Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
            Fluttertoast.showToast(
              backgroundColor: Colors.deepPurple,
              textColor: Colors.white,
              msg: "welcome ${_user.userName}",
              toastLength: Toast.LENGTH_SHORT,
            );
            if (admin) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AdminMenu(_user)));
            }
            else{
              Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage(_user)));
            }

          });
        }catch(e){
        }



//        Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
//        Navigate.goToHomeCompletely(context, userDetails);
      }
    } catch (err){
      print('Error in google sign in$err');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    buildId();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white70,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: MediaQuery.of(context).size.height*.15,
                          child: Lottie.network(
                            'https://assets4.lottiefiles.com/packages/lf20_KRkl9t.json'
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 10)),
                        Text('Welcome To Urban Sister\'s',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.3,
                              fontSize: 25
                          ),
                        ),
                      ],
                    ),
                  )
              ),
              //Expanded(child: Lottie.network('https://assets3.lottiefiles.com/packages/lf20_bHVEVT.json')),
              Expanded(
                flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
//                      GoogleSignInButton(
//                        darkMode: true,
//                        borderRadius: 20,
//                        splashColor: Colors.blue,
//                        onPressed: (){
//                          ///should login user and go to home page
//                         _login();
//                        },
//
//              ),
                    GestureDetector(
                      onTap: () => _login(),
                      child: Container(
                        width: MediaQuery.of(context).size.width*.70,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: Center(
                          child: Text('Login as Customer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2
                            ),
                          ),
                        ),
                      ),
                    ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              admin = true;
                            });
                            _login();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width*.70,
                            height: 45,
                            decoration: BoxDecoration(
                                color: Colors.deepPurpleAccent,
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Center(
                              child: Text('Login as Admin',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ))
            ],
          )
        ],
      ),
    );
  }
}

class logToFirebase{
  //firebase auth
  Future SignInAnn() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try{
      AuthResult result = await auth.signInAnonymously();
      FirebaseUser user = result.user;
      return user;
    }catch(e){
      print(e.toString());
      return null;
    }
  }
}

class UserDetails{
  final String userName;
  final String photoUrl;
  final String userEmail;
  final String userPromoCode;
  final String UserId;
  UserDetails(this.userName,this.photoUrl,this.userEmail,this.userPromoCode,this.UserId);
  Map<String,dynamic> map(){
    var map = <String,dynamic>{
      'name':this.userName,
      'photo':this.photoUrl,
      'mail':this.userEmail,
      'code':this.userPromoCode,
      'id':this.UserId
    };
    return map;
  }
}
