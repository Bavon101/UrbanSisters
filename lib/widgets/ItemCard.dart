import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:urbansisters/Items/AllCategories.dart';
import 'package:urbansisters/Pages/SignIn.dart';
import 'package:urbansisters/widgets/viewProduct.dart';
class ProductCard extends StatefulWidget {
  final Product product;
  final UserDetails user;
  final bool admin;
  ProductCard(this.product,this.admin,this.user);
  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if (!widget.admin) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProduct(widget.product, widget.user)));
        } else{
          Fluttertoast.showToast(
            backgroundColor: Colors.deepPurple,
            textColor: Colors.white,
            msg: "Long Press for Options",
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      },
      child: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                width: 170,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(widget.product.alphaImage,
                    ),
                    fit: BoxFit.cover,
                  )
                ),
              ),
              Text(widget.product.name,
                style: TextStyle(
                  color: Colors.black,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Ksh.${widget.product.price.toString().replaceAllMapped(reg, mathFunc)}',
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w900
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
