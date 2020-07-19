import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:urbansisters/Items/AllCategories.dart';
import 'package:urbansisters/Orders/customerView.dart';
import 'package:urbansisters/Pages/SignIn.dart';
import 'package:urbansisters/widgets/ItemCard.dart';
class HomePage extends StatefulWidget {
  final UserDetails _user;
  HomePage(this._user);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  List<Product> products = [];
  List<Widget> productsView = [];
  bool getting = true;
  bool hasProducts = true;
  getItems(){
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('Products');
    databaseReference.once().then((DataSnapshot snap) {
      var Keys = snap.value.keys;
      var Data = snap.value;
      for(var byKey in Keys){
        Product product = new Product(
            Data[byKey]['name'], Data[byKey]['price'], Data[byKey]['stalk'], Data[byKey]['color'],
            Data[byKey]['desc'], Data[byKey]['image'],
            Data[byKey]['images'], Data[byKey]['id']
        );
        setState(() {
          products.add(product);
          products = products;
        });
      }
    }).then((value) => buildItemUi()).catchError((e){
      print("Error is ${e.toString()}");
      setState(() {
        getting = false;
        hasProducts = false;
      });
    });
  }

  buildItemUi(){
    for(int b = 0; b < products.length;b++){
      setState(() {
        productsView.add(ProductCard(products[b],false,widget._user));
        getting = false;
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
//          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 45),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.menu
                      ),
                      onPressed: (){
                        _scaffoldKey.currentState.openDrawer();
                      },
                      iconSize: 32,
                    ),
                    Text('Home',
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w900,
                        fontSize: 30
                      ),
                    ),
                    IconButton(icon: Icon(Icons.search),
                      onPressed: (){
                          ///search
                      },
                    )
                  ],
                ),
              ),
              hasProducts && !getting ?SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height*.9,
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)
                            )
                        ),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          children: productsView,
                        ),
                      )
                    ],
                  ),
                ),
              ): hasProducts && getting ? Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    ),
                    Text('Fetching...'),
                  ],
                ),
              ):Center(
                child: Column(
                  children: [
                    Text(
                        'No Products Available 😪'
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
  MyDrawer(){
    return Drawer(
      child: Container(
        padding: EdgeInsets.only(left: 16,right: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black54)],
        ),
        width: 300,
        child: SafeArea(child: SingleChildScrollView(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                    color: Colors.white70 ,
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Container(
                        //height: 50,
                          child: widget._user.photoUrl != null ?CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Container(
                                decoration:  BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(widget._user.photoUrl,
                                      )
                                  ),
                                )
                            ),
                            radius: 20.0,
                          ):CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 20.0,
                            child: Text("${widget._user.userName[0].toUpperCase()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  color: Colors.black54
                              ),
                            ),
                          )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 50,left: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            //color: Colors.white,
                            child: Row(
                              children: [
                                GestureDetector(
                                  //onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>userAccount(widget._user))),
                                  child: Column(
                                    children: [
                                      Text(widget._user.userName,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 0.0,),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: FlatButton(
                  onPressed: (){
                    //Navigator.push(context, MaterialPageRoute(builder: (context)=>Cart(widget._user)));
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.shopping_cart,

                        ),
                        SizedBox(width: 10,),
                        Text('My shopping Cart')
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 5.0,),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: FlatButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomerOrder(widget._user)));
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.list,

                        ),
                        SizedBox(width: 10,),
                        Text('Order History')
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 15,),

              Divider(
                color: Colors.grey[800],
              ),
              SizedBox(height: 5.0,),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: FlatButton(
                  onPressed: () async {
                    ///log out
                    GoogleSignIn _googleSignIn = GoogleSignIn();
                    _googleSignIn.signOut();
                    FirebaseAuth auth = FirebaseAuth.instance;
                    auth.signOut();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>SignIn()));
                      Fluttertoast.showToast(
                        backgroundColor: Colors.grey[900],
                        msg: "User Signed Out",
                        toastLength: Toast.LENGTH_SHORT,
                      );

                  },
                  child: Container(
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.signOutAlt,
                          color: Colors.black54,

                        ),
                        SizedBox(width: 10,),
                        Text('Sign Out'),
                      ],
                    ),
                  ),
                ),
              ),


            ],
          ),
        )),
      ),
    );
  }
}
