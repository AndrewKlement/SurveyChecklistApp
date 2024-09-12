// @dart=2.9
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final List image;
  ImageViewer({Key key, this.image}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: Container(child: Body(image)));
  }
}

class Body extends StatefulWidget {
  final List image;
  Body(this.image);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.image.length,
          itemBuilder: (context, index){
            return InteractiveViewer(
              child: Image.file(
                widget.image[index],
              ) 
            );
          }
        ),

         Container(
          margin: EdgeInsets.fromLTRB(0, 34, 0, 0),
          child: IconButton(
            onPressed: (){
              Navigator.of(context).pop();
              setState(() {});
            }, 
            icon: Icon(Icons.arrow_back_ios_sharp)),
        ),
      ]
    );
  }
}