import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urbansisters/Items/AllCategories.dart';
import 'package:urbansisters/Orders/customerView.dart';
import 'package:urbansisters/Pages/SignIn.dart';
class ViewProduct extends StatefulWidget {
  final Product product;
  final UserDetails _user;
  ViewProduct(this.product,this._user);
  @override
  _ViewProductState createState() => _ViewProductState();
}
String GeoLog = 'Unknown';
String location = 'unknown';
int groupValue = 0;
String deliveryLocation = GeoLog;
double deliveryFee = 0.0;
String keyedLocation;
List<Widget> images = [];
bool done = false;

class _ViewProductState extends State<ViewProduct> {
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';
  double price;
  int itemCount = 1;
  int stalk ;
  void getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var  addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      GeoLog = first.featureName;
      location = first.addressLine;
    });
  }
  updateStalk(int subtract,String id){
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
        int newStalk = int.parse(product.stalk) - subtract;
        await  databaseReference.child(byKey).update({
          'stalk': newStalk.toString()
        });
      }
    });
  }
  getPice(){
    setState(() {
      price = double.parse(widget.product.price);
    });
    return price;
  }
  getStalk(){
    setState(() {
      stalk = int.parse(widget.product.stalk);
    });
  }
  showImage(BuildContext context, String image, String tag){
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (ivar) => Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Hero(
                  tag: tag,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Image.network(image,
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            )
        )
    );
  }
  getImages(){
    for(int b = 0;b < widget.product.images.length;b++){
      setState(() {
        images.add(
            GestureDetector(
              onTap: (){
                showImage(context, widget.product.images[b],b.toString());
              },
              child: Hero(
                tag: b.toString(),
                child: Container(
                  padding: EdgeInsets.only(left: 20,right: 20),
                  height: MediaQuery.of(context).size.height*0.35,
                  //width: 200,
                  //width:  MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(widget.product.images[b],
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.contain,
                      loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null ?
                            loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            )
        );
      });
    }
    setState(() {
      done = true;
    });
    return images;
  }
  updateCustomerOrder(Order order) async {
    var firestore = Firestore.instance;
    await firestore.collection('Orders').document(order.orderId).setData(order.map(),merge: true);

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
    getStalk();
    getPice();
    //getImages();
  }
  @override
  Widget build(BuildContext context) {
    getImages();
    return Scaffold(
      backgroundColor: Colors.purpleAccent,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 35,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: ()=> Navigator.pop(context)),
                IconButton(icon: Icon(CupertinoIcons.heart), onPressed: (){
                  ///mark item as liked
                })
              ],
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: images,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height *.60,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(widget.product.name,
                          style: TextStyle(
                            color: Colors.black87,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Text('KES.${price.toString().replaceAllMapped(reg, mathFunc)}',
                          style: TextStyle(
                            color: Colors.black54,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.color_lens,
                              color: Colors.purple,
                              size: 15,
                            ),

                            Text(widget.product.color,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.1
                              ),
                            ),
                          ],
                        ),
                        Text('Description',

                          style: TextStyle(
                            color: Colors.deepPurple,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        Text(widget.product.description,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: (){
                                    if (itemCount != 1) {
                                      setState(() {
                                        itemCount -=1;
                                        price = (double.parse(widget.product.price) * itemCount);
                                      });
                                    }else if (itemCount == 1) {
                                      setState(() {
                                        price = double.parse(widget.product.price);
                                        Fluttertoast.showToast(
                                          msg: "Quantity limit",
                                          toastLength: Toast.LENGTH_SHORT,
                                        );
                                      });
                                    }
                                  },
                                ),
                                Text(itemCount < 10? '0${itemCount.toString()}':itemCount.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.2
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add,
                                  ),
                                  onPressed: (){
                                    if(itemCount < stalk){
                                      setState(() {
                                        itemCount +=1;
                                        price = double.parse(widget.product.price) * itemCount;
                                      });
                                    }else{
                                      Fluttertoast.showToast(
                                        backgroundColor: Colors.deepPurple,
                                        textColor: Colors.white,
                                        msg: "Stalk exceeded",
                                        toastLength: Toast.LENGTH_SHORT,
                                      );
                                    }

                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        Text('Suggest Delivery Location',
                          style: TextStyle(
                              color: Colors.black,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline
                          ),
                        ),
                        RadioListTile(
                          groupValue: groupValue,
                          value: 0,
                          activeColor: Theme.of(context).primaryColor,
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pick from Shop',
                                textScaleFactor: MediaQuery.of(context).size.width < 1080? 0.5:1,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    fontSize: 25
                                ),
                              ),
                            ],
                          ),
                          onChanged: (t){
                            setState(() {
                              deliveryLocation = "Pick from Shop";
                              groupValue = 0;
                            });
                          },
                        ),
                        RadioListTile(
                          groupValue: groupValue,
                          value: 1,
                          activeColor: Theme.of(context).primaryColor,
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Home Delivery',
                                textScaleFactor: MediaQuery.of(context).size.width < 1080? 0.5:1,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    fontSize: 25
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.location_on

                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(location != null?location:'Home Location',
                                          textAlign: TextAlign.start,
                                        ),
                                        Text(GeoLog != null?GeoLog:'Unknown',
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onChanged: (t){
                            setState(() {
                              groupValue = 1;
                              deliveryLocation = GeoLog;
                              deliveryFee = 150;
                            });
                          },
                        ),
                        groupValue == 1?FlatButton(
                          child: Text('Change Home location',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: (){
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
                                          Text('Change Delivery Location'),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20,right: 10,top: 0),
                                            child: TextFormField(
                                              cursorColor: Theme.of(context).cursorColor,
                                              decoration: InputDecoration(
                                                filled: true,
                                                icon: Icon(Icons.location_on),
                                                hintText: GeoLog,
                                                labelText: 'Home Address',
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
                                              keyboardType: TextInputType.text,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 1.2
                                              ),
                                              maxLength: 30,
                                              maxLengthEnforced: true,
                                              onChanged: (value){
                                                setState(() {
                                                  keyedLocation = value;
                                                });
                                              },
                                            ),
                                          ),

                                          FlatButton(
                                            child: Text('Done'),
                                            onPressed: (){
                                              if (keyedLocation != null && keyedLocation.length > 4) {
                                                setState(() {
                                                  GeoLog = keyedLocation;
                                                });
                                                Navigator.pop(context);
                                                Fluttertoast.showToast(
                                                  msg: "delivering to: $keyedLocation",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                );
                                              } else{
                                                Navigator.pop(context);
                                                Fluttertoast.showToast(
                                                  msg: "location not Changed",
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
                          },
                        ):Container(  ),
                        groupValue == 1? Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text('Delivery Fee Ksh.$deliveryFee',
                            style: TextStyle(
                                color: Colors.blue[500]
                            ),
                          ),
                        ):Container(),


                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            topLeft: Radius.circular(15),
          )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(CupertinoIcons.shopping_cart),
              onPressed: (){
                Fluttertoast.showToast(
                  msg: "Item Added To Cart",
                  toastLength: Toast.LENGTH_SHORT,
                );
              },
            ),
            GestureDetector(
              onTap: () async {
                String orderId = DateTime.now().year.toString() + DateTime.now().day.toString() + DateTime.now().millisecond.toString() +
                    DateTime.now().second.toString() + DateTime.now().microsecondsSinceEpoch.toString();
                Order order = new Order(
                    widget._user.userName, widget.product.name, itemCount,
                    widget.product.color, false, price.toString(), false,
                    DateTime.now().toString().substring(0,18), false, orderId,deliveryLocation,DateTime.now().toString().substring(0,18),
                  widget.product.alphaImage
                );
                var firestore = Firestore.instance;
                await firestore.collection('Orders').document(order.orderId).setData(order.map()).then((value) {
                  updateStalk(itemCount, widget.product.productId);
                  Fluttertoast.showToast(
                    backgroundColor: Colors.deepPurple,
                    textColor: Colors.white,
                    msg: "Order Confirmation Success",
                    toastLength: Toast.LENGTH_SHORT,
                  );
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>CustomerOrder(widget._user)));
                });

              },
              child: Container(
                width: MediaQuery.of(context).size.width*.7,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Center(
                  child: Text('Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
