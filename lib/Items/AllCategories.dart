class Product{
  final String name;
  final String price;
  final String stalk;
  final String color;
  final String description;
  final String alphaImage;
  final List images;
  final String productId;
  Product(this.name,this.price,this.stalk,this.color,this.description,this.alphaImage,this.images,this.productId);

  Map<String,dynamic> map(){
    var map = <String,dynamic>{
      'name':this.name,
      'price':this.price,
      'stalk':this.stalk,
      'color':this.color,
      'desc':this.description,
      'image':this.alphaImage,
      'images':this.images,
      'id':this.productId
    };
    return map;
  }
}

class Order{
  final String customer;
  final String item;
  final int quantity;
  final String color;
  final bool received;
  final String price;
  final bool paid;
  final String date;
  final bool delivered;
  final String orderId;
  final String deeliveryAddress;
  final String deliveryDate;
  final String image;

  Order(this.customer,this.item,this.quantity,this.color,this.received,this.price,this.paid,this.date,this.delivered,this.orderId,this.deeliveryAddress,this.deliveryDate,this.image);

  Map<String,dynamic> map(){
    var map = <String,dynamic>{
      'customer':this.customer,
      'image':this.image,
      'item':this.item,
      'quantity':this.quantity,
      'color':this.color,
      'received':this.received,
      'price':this.price,
      'paid':this.paid,
      'date':this.date,
      'delivered':this.delivered,
      'id':this.orderId,
      'address':this.deeliveryAddress,
      'delDate':this.deliveryDate

    };
    return map;
  }

}