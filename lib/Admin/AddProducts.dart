import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:urbansisters/Items/AllCategories.dart';
import 'package:urbansisters/widgets/LoadDialog.dart';
class AddProducts extends StatefulWidget {
  @override
  _AddProductsState createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';
  List<File> itemImages = [];
  int maxImages = 6;
  bool isSingle = true;
  bool donewithInfo = false;
  String PlatformError = 'No issue';
  int _currentPageIndex = 0;

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final key = new GlobalKey<FormState>();
  final name = TextEditingController();
  final price = TextEditingController();
  final stalk = TextEditingController();
  final color = TextEditingController();
  final desc = TextEditingController();
  bool filled = false;

  List<File> images = [];
  File aphaImage;
  File _image;
  File _image1;
  File _image2;
  File _image3;
  File _image4;
  File _image5;
  List<String> imageUrlList = [];
  String alphaImageUrl ;

  Future upLoadAlphaImage(BuildContext context) async{
    String fileName =  name.text.trim() +price.text.trim()+ 'alpha.png';
    StorageReference storageReference =FirebaseStorage.instance.ref().child('ItemImages').child(fileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(aphaImage);
    StorageTaskSnapshot downLoadUrl = (await storageUploadTask.onComplete);
    // ignore: missing_return
    alphaImageUrl = (await downLoadUrl.ref.getDownloadURL().then((value) {
      setState(() {
        alphaImageUrl = value.toString();
      });
    }));
    //(await storageUploadTask.onComplete).ref.getDownloadURL().then((value) => logo = value.toString());
    return alphaImageUrl;
  }
  Future uploadImageList(BuildContext context) async {
    String Url;
    for(int b = 0; b < images.length;b++){
      String fileName =  name.text.trim() +price.text.trim()+ 'other${images[b]}.png';
      StorageReference storageReference =FirebaseStorage.instance.ref().child('ItemImages').child(fileName);
      StorageUploadTask storageUploadTask = storageReference.putFile(images[b]);
      StorageTaskSnapshot downLoadUrl = (await storageUploadTask.onComplete);
      // ignore: missing_return
      Url = (await downLoadUrl.ref.getDownloadURL().then((value) {
        setState(() {
          imageUrlList.add(Url.toString());
        });
      }));

    }
    setState(() {
      alphaImageUrl = imageUrlList[0];
      imageUrlList = imageUrlList;
    });
    return imageUrlList;
  }

  validateDate(){
    if (name.text.length > 0 && aphaImage != null && price.text.length > 0 && color.text.length >0 && stalk.text.length > 0 && desc.text.length > 0) {
      setState(() {
        filled = true;
      });
    }
  }

  Future uploadeMultipleImages() async {
    try{
      for(int b = 0;b < images.length;b++){
        final StorageReference storageReference = FirebaseStorage().ref().child('ItemImages').child(name.text.trim() +price.text.trim() + 'other$b');
        final StorageUploadTask uploadTask = storageReference.putFile(images[b]);
        final StreamSubscription<StorageTaskEvent> streamSubscription = uploadTask
            .events.listen((event) {
          print('EVENT ${event.type}');
        });
        await uploadTask.onComplete;
        streamSubscription.cancel();
        String url = await storageReference.getDownloadURL();
        setState(() {
          imageUrlList.add(url);
        });
      }
      return imageUrlList;
    }catch(e){
      print(e);
    }
  }
  final _picker = ImagePicker();
  Future<Null>_pickFromgallery() async{
    final PickedFile pickedFile = await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (aphaImage == null) {
        this.aphaImage = File(pickedFile.path);
        images.add(aphaImage);
      } else if (_image == null && aphaImage != null) {
        this._image = File(pickedFile.path);
        images.add(_image);
      }
      else if (_image1 == null && aphaImage != null && _image != null) {
        this._image1 = File(pickedFile.path);
        images.add(_image1);
      }
      else if (_image2 == null && aphaImage != null && _image != null && _image1 != null) {
        this._image2 = File(pickedFile.path);
        images.add(_image2);
      }else if (_image3 == null && aphaImage != null && _image != null && _image1 != null && _image2 != null) {
        this._image3 = File(pickedFile.path);
        images.add(_image3);
      }else if (_image4 == null && aphaImage != null && _image != null && _image1 != null && _image2 != null && _image3 != null) {
        this._image4 = File(pickedFile.path);
        images.add(_image4);
      }else if (_image5 == null && aphaImage != null && _image != null && _image1 != null && _image2 != null && _image3 != null && _image4 != null) {
        this._image5 = File(pickedFile.path);
        images.add(_image5);
      }

    });
  }


  final _titleTabs = <Tab>[
    Tab(icon: Icon(Icons.description),text: 'Details',),
    Tab(icon: Icon(Icons.image),text: 'Images',),
    Tab(icon: Icon(Icons.done),text: 'Upload',),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    validateDate();
  }
  @override
  Widget build(BuildContext context) {
    final _TabsUI = <Widget>[
      getDetails(),
      getImages(),
      uploadProduct(),
    ];
    return DefaultTabController(
      length: _titleTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Upload Product'),
          backgroundColor: Colors.purpleAccent,
          bottom: TabBar(
            tabs: _titleTabs,
          ),
        ),
        body: TabBarView(
          children: _TabsUI,
        ),
      ),
    );
  }

   getDetails(){
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //SizedBox(height: MediaQuery.of(context).size.height *.1,),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: CloseButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
              ),
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height*.10,
              child: Lottie.network('https://assets6.lottiefiles.com/packages/lf20_gdsQlv.json',
                //height: 150
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height *.02,),
            Text(
              'Provide Product Details',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 18
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height *.02,),
            Container(
              child: SingleChildScrollView(
                child: Form(
                    key: key,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10,top: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              //color: Theme.of(context).accentColor,
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(color: Theme.of(context).primaryColor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5,right: 5),
                              child: TextFormField(
                                controller: name,
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                    color: Colors.black,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Product Label',
                                  hintText: 'Brazilian wig',
                                  labelStyle:TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      letterSpacing: 1.3
                                  ),
                                  icon: Icon(Icons.label,
                                    color: Colors.black,
                                  ),
                                ),
                                validator: (val) => val.isNotEmpty? null : "Required",
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10,top: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              //color: Theme.of(context).accentColor,
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(color: Theme.of(context).primaryColor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5,right: 5),
                              child: TextFormField(
                                controller: stalk,
                                keyboardType: TextInputType.phone,
                                style: TextStyle(
                                    color: Colors.black,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Product Stock',
                                  hintText: '10',
                                  labelStyle:TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      letterSpacing: 1.3
                                  ),
                                  icon: Icon(Icons.shopping_basket,
                                    color: Colors.black,
                                  ),
                                ),
                                validator: (val) => val.isNotEmpty? null : "Required",
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10,top: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              //color: Theme.of(context).accentColor,
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(color: Theme.of(context).primaryColor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5,right: 5),
                              child: TextFormField(
                                controller: price,
                                keyboardType: TextInputType.phone,
                                style: TextStyle(
                                    color: Colors.black,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Price',
                                  hintText: '1200',
                                  labelStyle:TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      letterSpacing: 1.3
                                  ),
                                  icon: Icon(Icons.attach_money,
                                    color: Colors.black,
                                  ),
                                ),
                                validator: (val) => val.isNotEmpty? null : "Required",
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10,top: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              //color: Theme.of(context).accentColor,
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(color: Theme.of(context).primaryColor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5,right: 5),
                              child: TextFormField(
                                controller: color,
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                    color: Colors.black,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Color ',
                                  hintText: '3',
                                  labelStyle:TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      letterSpacing: 1.3
                                  ),
                                  icon: Icon(Icons.format_paint,
                                    color: Colors.black,
                                  ),
                                ),
                                validator: (val) => val.isNotEmpty? null : "Required",
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10,top: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              //color: Theme.of(context).accentColor,
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(color: Theme.of(context).primaryColor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5,right: 5),
                              child: TextFormField(
                                controller: desc,
                                maxLines: 3,
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                    color: Colors.black,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  hintText: ' brown',
                                  labelStyle:TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      letterSpacing: 1.3
                                  ),
                                  icon: Icon(Icons.note,
                                    color: Colors.black,
                                  ),
                                ),
                                validator: (val) => val.isNotEmpty? null : "Required",
                              ),
                            ),
                          ),
                        ),

                      ],
                    )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  getImages(){
    return SingleChildScrollView(
      child: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //SizedBox(height: MediaQuery.of(context).size.height*.10,),
              Container(
                child: Lottie.network('https://assets6.lottiefiles.com/packages/lf20_34RWGs.json',
                    height: MediaQuery.of(context).size.height*.10
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text('Upload product Image/s',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 18
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0,bottom: 10),
                child: Text('Images chosen: ${aphaImage != null  && images.length != 0? (images.length): 0}/7',
                  style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height *.40,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: [
                          GestureDetector(
                            onLongPress: (){
                              setState(() {
                                aphaImage = null;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 10,right: 20),
                              height: 100,
                              child: this.aphaImage == null? Placeholder(
                                color: Theme.of(context).primaryColor,
                              ):ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(this.aphaImage,
                                  filterQuality: FilterQuality.high,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onLongPress: (){
                              setState(() {
                                _image = null;
                                images.removeAt(0);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 10,right: 20),
                              height: 100,
                              child: this._image == null? Placeholder(color: Theme.of(context).primaryColor,):ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(this._image,
                                    filterQuality: FilterQuality.high,
                                    fit: BoxFit.cover,
                                  )),
                            ),
                          ),
                          GestureDetector(
                            onLongPress: (){
                              setState(() {
                                _image1 = null;
                                images.removeAt(1);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 10,right: 20),
                              height: 100,
                              child: this._image1 == null? Placeholder(color: Theme.of(context).primaryColor,):ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(this._image1,
                                    filterQuality: FilterQuality.high,
                                    fit: BoxFit.cover,
                                  )),
                            ),
                          ),
                          GestureDetector(
                            onLongPress: (){
                              setState(() {
                                _image2 = null;
                                images.removeAt(2);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 10,right: 20),
                              height: 100,
                              child: this._image2 == null? Placeholder(color: Theme.of(context).primaryColor,):ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(this._image2,
                                    filterQuality: FilterQuality.high,
                                    fit: BoxFit.cover,
                                  )),
                            ),
                          ),
                          GestureDetector(
                            onLongPress: (){
                              setState(() {
                                _image3 = null;
                                images.removeAt(3);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 10,right: 20),
                              height: 100,
                              child: this._image3 == null? Placeholder(color: Theme.of(context).primaryColor,):ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(this._image3,
                                    filterQuality: FilterQuality.high,
                                    fit: BoxFit.cover,
                                  )),
                            ),
                          ),
                          GestureDetector(
                            onLongPress: (){
                              setState(() {
                                _image4 = null;
                                images.removeAt(4);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 10,right: 20),
                              height: 100,
                              child: this._image4 == null? Placeholder(color: Theme.of(context).primaryColor,):ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(this._image4,
                                    filterQuality: FilterQuality.high,
                                    fit: BoxFit.cover,
                                  )),
                            ),
                          ),
                          GestureDetector(
                            onLongPress: (){
                              setState(() {
                                _image5 = null;
                                images.removeAt(5);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 10,right: 20),
                              height: 100,
                              child: this._image5 == null? Placeholder(color: Theme.of(context).primaryColor,):ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(this._image5,
                                    filterQuality: FilterQuality.high,
                                    fit: BoxFit.cover,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Add Images'),
                  IconButton(
                    icon: Icon(
                      Icons.add_a_photo,
                    ),
                    iconSize: 45,
                    color: Theme.of(context).primaryColor,
                    onPressed: (){
                      if (images.length != 6) {
                        _pickFromgallery();
                      } else if(images.length == 6){
                        Fluttertoast.showToast(
                          msg: "Photo limit Reached!",
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      }
                    },
                  )
                ],
              ),
              Text('Long Press on an Image to delete',
                style: TextStyle(
                    color: Colors.black38
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  uploadProduct(){
    validateDate();
    final dataBaseWhole = FirebaseDatabase.instance.reference().child('Products');
    String id = DateTime.now().month.toString() + DateTime.now().day.toString() + DateTime.now().year.toString() + DateTime.now().second.toString()
    + DateTime.now().millisecond.toString() + DateTime.now().microsecond.toString();
    Product product = new Product(
        name.text, price.text, stalk.text, color.text,
        desc.text, alphaImageUrl, imageUrlList, id);
    return SingleChildScrollView(
      child: Container(
          child: filled? Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height*.2,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text('Product Details',
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      letterSpacing: 1.3,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Container(
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    aphaImage != null ?Container(
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          image: DecorationImage(
                              image: FileImage(aphaImage),
                              fit: BoxFit.cover
                          )
                      ),
                      height: MediaQuery.of(context).size.height *.35,
                      width: 150,
                    ):Placeholder(
                      color: Theme.of(context).primaryColor,
                    ),
                    Text('Ksh.${product.price.toString().replaceAllMapped(reg, mathFunc)}',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 1.3
                      ),
                    ),
                    Text('${product.name}',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          letterSpacing: 1.3
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: RaisedButton(
                  child: Text('Upload to market',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2
                    ),
                  ),
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  onPressed: () async {
                    Dialogs.showLoadingDialog(context, _keyLoader);
                    uploadeMultipleImages().then((value) {
                      product = new Product(
                          name.text, price.text, stalk.text, color.text,
                          desc.text, value[0], value, id);
                      dataBaseWhole.push().set(product.map()).then((value) {
                          Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
                          name.clear();
                          stalk.clear();
                          desc.clear();
                          price.clear();
                          setState(() {
                            alphaImageUrl = null;
                            itemImages.clear();
                            images.clear();
                            _image = null;
                            _image1 = null;
                            _image2 = null;
                            _image3 = null;
                            _image4 = null;
                            _image5 = null;
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              backgroundColor: Colors.deepPurple,
                              textColor: Colors.white,
                              msg: "Product Upload Success",
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          });

                      });

                    });
                  },
                ),
              )
            ],
          ):Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*.35,),
              Center(
                child: Text('Fill all fields to continue'),
              ),
            ],
          )
      ),
    );
  }
}
