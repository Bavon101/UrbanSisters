import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:urbansisters/Items/AllCategories.dart';
import 'package:urbansisters/Pages/SignIn.dart';
import 'package:urbansisters/widgets/ItemCard.dart';
class AdminProductView extends StatefulWidget {
  final UserDetails user;
  AdminProductView(this.user);
  @override
  _AdminProductViewState createState() => _AdminProductViewState();
}

class _AdminProductViewState extends State<AdminProductView> {
  List<Product> products = [];
  List<Widget> productsView = [];
  bool getting = true;
  bool hasProducts = true;
  bool updateStock = false;
  String newStalk;
  final scaffoldState = GlobalKey<ScaffoldState>();
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
      print('Error is: ${e.toString()}');
      setState(() {
        getting = false;
        hasProducts = false;
      });
    });
  }
  deleteItem(String itemId){
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference()
        .child('Products');
    databaseReference.orderByChild('id').startAt(itemId).endAt(
        itemId + "\uf8ff").limitToFirst(1).once()
        .then((DataSnapshot snap) async {
      var Keys = snap.value.keys;
      //String itemKey = Keys;
      var Data = snap.value;
      for (var byKey in Keys) {
        DatabaseReference databaseReference1 = FirebaseDatabase.instance
            .reference().child('Products');
        await databaseReference1.child(byKey).remove().then((value) {
          Fluttertoast.showToast(
            backgroundColor: Colors.deepPurple,
            textColor: Colors.white,
            msg: "Product Deleted",
            toastLength: Toast.LENGTH_SHORT,
          );
        });
      }
    });
  }
  buildItemUi(){
    for(int b = 0; b < products.length;b++){
      setState(() {
        productsView.add(FocusedMenuHolder(
          onPressed: (){

          },
            menuItems: <FocusedMenuItem>[
              FocusedMenuItem(title: Row(
                children: [
                  Text('Current Stock: '),
                  Text(products[b].stalk,
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2
                    ),
                  ),
                ],
              ), onPressed: (){

              }),
              FocusedMenuItem(title: Row(
                children: [
                  Icon(Icons.update),
                  Text('Update Stock'),
                ],
              ), onPressed: (){
                showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder:(BuildContext context){
                      return Dialog(
                        shape:  RoundedRectangleBorder(
                            borderRadius:BorderRadius.circular(30.0)
                        ),
                        child: Container(
                          height: MediaQuery.of(context).size.height*.30,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Key in Stock'),
                              Padding(
                                padding: const EdgeInsets.only(left: 20,right: 10,top: 0),
                                child: TextFormField(
                                  cursorColor: Theme.of(context).cursorColor,
                                  decoration: InputDecoration(
                                    filled: true,
                                    icon: Icon(Icons.location_on),
                                    hintText: '7',
                                    labelText: 'Stock to Add',
                                    hintStyle: TextStyle(
                                        color: Colors.black45,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2
                                    ),
                                    labelStyle: TextStyle(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2
                                    ),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2
                                  ),
                                  maxLength: 3,
                                  maxLengthEnforced: true,
                                  onChanged: (value){
                                    setState(() {
                                      newStalk = value;
                                    });
                                  },
                                ),
                              ),

                              FlatButton(
                                child: Text('Update'),
                                onPressed: (){
                                  if (newStalk != null) {

                                    updateStalk(products[b].productId, int.parse(newStalk));
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => AdminProductView(widget.user)));
                                  } else{
                                    Navigator.pop(context);
                                    Fluttertoast.showToast(
                                      backgroundColor: Colors.deepPurple,
                                      textColor: Colors.white,
                                      msg: "Stalk not Valid",
                                      toastLength: Toast.LENGTH_SHORT,
                                    );
                                  }
                                },
                                color: Theme.of(context).primaryColor,
                              )

                            ],
                          ),
                        ),
                      );
                    }
                );
              }),

              FocusedMenuItem(title: Row(
                children: [
                  Icon(Icons.delete_forever),
                  Text('Delete Item'),
                ],
              ), onPressed: (){
                  deleteItem(products[b].productId);
                  productsView.removeAt(b);
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminProductView(widget.user)));
              })
            ],
            child: ProductCard(products[b],true,widget.user)));
        getting = false;
      });
    }
  }
  updateStalk(String id,int toAdd){
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference()
        .child('Products');
    databaseReference.orderByChild('id').startAt(id).endAt(id + "\uf8ff").limitToFirst(1).once()
    .then((DataSnapshot snap)  async {
        var Keys = snap.value.keys;
        var Data = snap.value;
        for(var byKey in Keys){
          Product product = new Product(
              Data[byKey]['name'], Data[byKey]['price'], Data[byKey]['stalk'], Data[byKey]['color'],
              Data[byKey]['desc'], Data[byKey]['image'],
              Data[byKey]['images'], Data[byKey]['id']);
          int newStalk = int.parse(product.stalk) + toAdd;
          await  databaseReference.child(byKey).update({
            'stalk': newStalk.toString()
          }).then((value) {
            Fluttertoast.showToast(
              backgroundColor: Colors.deepPurple,
              textColor: Colors.white,
              msg: "Stalk Updated",
              toastLength: Toast.LENGTH_SHORT,
            );
          });
        }
    });
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
      backgroundColor: Colors.purpleAccent,
      body: hasProducts && !getting ?Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //SizedBox(height: MediaQuery.of(context).size.height*.05,),
            Padding(
              padding: const EdgeInsets.only(top: 41),
              child: Align(
                alignment: Alignment.topLeft,
                  child: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: ()=> Navigator.pop(context))),
            ),
            Container(
              height: MediaQuery.of(context).size.height*.20,
              child: Center(
                child: Text('Your Products',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 35,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height*.7,
                decoration: BoxDecoration(
                  color: Colors.white,
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
              ),
            )
          ],
        ),
      ): hasProducts && getting ? Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            Text('Getting Items...'),
          ],
        ),
      ):Center(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*.35,),
            Text(
              'You have No Products',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2
              ),
            ),
          ],
        ),
      ),
    );
  }
}
