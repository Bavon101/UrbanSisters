import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:urbansisters/Items/AllCategories.dart';
import 'package:urbansisters/Pages/SignIn.dart';
class CustomerOrder extends StatefulWidget {
  final UserDetails user;
  CustomerOrder(this.user);
  @override
  _CustomerOrderState createState() => _CustomerOrderState();
}

class _CustomerOrderState extends State<CustomerOrder> {
  bool getting = true;
  bool hasOrders = false;
  Future ordsers;
  QuerySnapshot querySnapshotAlpha;
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';
  final scaffoldState = GlobalKey<ScaffoldState>();
  getOrders(){
    Firestore.instance
        .collection('Orders')
        .where('customer',
        isEqualTo: widget.user.userName)
        .getDocuments().then((QuerySnapshot querySnapshot){
      if(querySnapshot.documents.length > 0){
        setState(() {
          querySnapshotAlpha = querySnapshot;
          hasOrders = true;
          getting = false;
        });
      }else{
        setState(() {
          hasOrders = false;
          getting = false;
        });
      }

    }).catchError((e){
      setState(() {
        hasOrders = false;
        getting = false;
      });
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrders();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      body: getting ?Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            Text('Getting orders...'),
          ],
        ),
      ):!hasOrders && !getting ?SingleChildScrollView(
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: CloseButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*.45,
                ),
                Icon(Icons.not_interested,
                  color: Theme.of(context).primaryColor,
                ),
                Text('You have no Orders Yet \nyour Orders will appear here',
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      ):hasOrders && !getting? Container(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height*.30,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: CloseButton(
                          color: Theme.of(context).primaryColor,
                          onPressed: (){
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                Container(
                  child: Lottie.network(
                    'https://assets9.lottiefiles.com/packages/lf20_0vKKEb.json',
                    height: MediaQuery.of(context).size.height*.20,
                    ),
                  ),
                    Text('Your Orders',
                      style: TextStyle(
                          color: Colors.black,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height*.70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)
                  )
                ),
                child: Column(
                  children: [
                    Expanded(
                        child: ListView.builder(
                            itemCount: querySnapshotAlpha.documents.length,
                            itemBuilder: (BuildContext context,index){
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: (){
                                    Order order = new Order(
                                        querySnapshotAlpha.documents[index]['customer'], querySnapshotAlpha.documents[index]['item'], querySnapshotAlpha.documents[index]['quantity'], querySnapshotAlpha.documents[index]['color'],
                                        querySnapshotAlpha.documents[index]['received'], querySnapshotAlpha.documents[index]['price'], querySnapshotAlpha.documents[index]['paid'], querySnapshotAlpha.documents[index]['date'], querySnapshotAlpha.documents[index]['delivered'],
                                        querySnapshotAlpha.documents[index]['id'], querySnapshotAlpha.documents[index]['address'], querySnapshotAlpha.documents[index]['delDate'],
                                        querySnapshotAlpha.documents[index]['image']
                                    );
                                    viewOrder(order);
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.purpleAccent[100],
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                    child: Column(
                                      children: [
                                        Row(
                                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          //crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                height: 100,
                                                width: 100,
                                                decoration:  BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(10),
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                          querySnapshotAlpha.documents[index]['image']
                                                      )
                                                  ),
                                                )
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 20),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(querySnapshotAlpha.documents[index]['item'],
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                        letterSpacing: 1.2,
                                                        fontSize: 20
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('Payment Status:'),
                                                      Text(querySnapshotAlpha.documents[index]['paid']? 'Paid':'Pending',
                                                        textScaleFactor:  MediaQuery.of(context).size.width < 1080? 0.5:1,
                                                        style: TextStyle(
                                                            color: querySnapshotAlpha.documents[index]['paid'] ? Colors.green:Colors.red,
                                                            fontSize: 18,
                                                            letterSpacing: 1.2,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text('Price:'),
                                                      Text('Ksh.${querySnapshotAlpha.documents[index]['price'].toString().replaceAllMapped(reg, mathFunc)}',
                                                        textScaleFactor:  MediaQuery.of(context).size.width < 1080? 0.5:1,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          letterSpacing: 1.2,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 5),
                                                    child: Row(
                                                      children: [
                                                        Text('Delivery Status:'),
                                                        Text(querySnapshotAlpha.documents[index]['delivered']?'Delivered':'Pending',
                                                          textScaleFactor:  MediaQuery.of(context).size.width < 1080? 0.5:1,
                                                          style: TextStyle(
                                                            color: querySnapshotAlpha.documents[index]['delivered']? Colors.green:Colors.deepOrange,
                                                            letterSpacing: 1.2,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 20),
                                              child: CircleAvatar(
                                                backgroundColor: Colors.grey[600],
                                                child: Text(querySnapshotAlpha.documents[index]['quantity'].toString(),
                                                  style: TextStyle(
                                                      color: Colors.white
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('Delivery Address:'),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 5),
                                              child: Text(querySnapshotAlpha.documents[index]['address'],
                                                style: TextStyle(
                                                  color: Colors.grey[900],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                        )
                    )
                  ],
                ),
              )
            ],
          ),
      ):Container()
    );
  }
  viewOrder(Order order){
    scaffoldState.currentState
        .showBottomSheet((context) => Container(
      color: Colors.transparent,
      height: MediaQuery.of(context).size.height*.25,
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20)
            ),
            border: Border.all(color: Colors.deepPurple),
          ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(order.item,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35,top: 2),
              child: Row(
                children: [
                  Text('Order Date: '),
                  Text(order.date,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35,top: 5),
              child: Row(
                children: [
                  Text('Delivered ? '),
                  Text(order.received?'Received':'Not Received',
                    style: TextStyle(
                        color: order.received? Colors.green:Colors.brown[900],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35,top: 5),
              child: Row(
                children: [
                  Text('Date delivered:'),
                  Text(order.deliveryDate.isNotEmpty ? order.deliveryDate: 'Pending',
                    style: TextStyle(
                        color: order.received ? Colors.green:Colors.brown[900],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2
                    ),
                  ),
                ],
              ),
            ),
            !order.received ?FlatButton(
              child: Text(
                'Confirm Delivery',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold
                ),
              ),
              onPressed: () async {
                Fluttertoast.showToast(
                  msg: "Confirming Delivery... ",
                  toastLength: Toast.LENGTH_SHORT,
                );
                ///confirm delivry and rate
                var firestore = Firestore.instance;
                await firestore.collection('Orders').document(order.orderId).updateData(
                    {
                      'received':true,
                      'delDate':DateTime.now().toString().substring(0,18)
                    }
                ).then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomerOrder(widget.user)));
                  Fluttertoast.showToast(
                    msg: "Order Marked: Delivered",
                    toastLength: Toast.LENGTH_SHORT,
                  );
                });
              },
            ):Container()
          ],
        ),
      ),
    ));
  }
}
