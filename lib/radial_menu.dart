// @dart=2.9
import 'package:flutter/material.dart';
import 'dart:math' as math;


class RadialMenu extends StatefulWidget {
  final List<Widget> children; 
  final double radius;
  final double itemMaxHeight;
  final double itemMaxWidth;
  final double spacing;
  final EdgeInsetsGeometry margin;
  RadialMenu({Key key, this.children=const <Widget>[], this.margin, this.spacing, this.radius= 100, this.itemMaxHeight, this.itemMaxWidth}) : super(key: key);

  @override
  _RadialMenuState createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> {
   double lastPosition;
  List<Widget> newchildren= [];
  double degreesRotated = 0;

  @override
  void initState() {
    setState(() {
      _calculateTransformItems();  
    });
    super.initState();
  }
  void _calculateTransformItems(){
    newchildren = [];
    for(int i = 0; i<widget.children.length; i++){
      double currentAngle = degreesRotated+((i/widget.children.length)*2*math.pi);
      newchildren.add(
        Transform(
          transform: Matrix4.identity()..translate(
            (widget.radius)*math.cos(currentAngle),
            (widget.radius)*math.sin(currentAngle),
          ),
          child: widget.children[i],
        ),
      );
    }
  }
  void _calculateScroll(DragUpdateDetails details){
    if (lastPosition == null){
      lastPosition = details.localPosition.dy;
      return;
    }
    double distance = details.localPosition.dy - lastPosition;
    lastPosition =details.localPosition.dy;
    // the formula that is used degree = s/r
    degreesRotated += distance/(widget.radius);
    _calculateTransformItems();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      height: widget.radius*2+widget.itemMaxHeight,
      width: widget.radius*2 + widget.itemMaxWidth,
        child: GestureDetector(
          onVerticalDragUpdate: (details)=>setState((){_calculateScroll(details);}),
          onVerticalDragEnd: (details){lastPosition=null;},
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.transparent,
            child: ClipRect(
              child: Align(
                alignment: Alignment.center,
                  child: Stack(
                    children: newchildren,
                  ),
                
              ),
            ),
          ),
        ),
    );
  }
}