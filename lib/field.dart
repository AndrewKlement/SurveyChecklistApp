// @dart=2.9
import 'package:flutter/material.dart';

class Type{
  String type; 
  List <TextEditingController> controller;
  Type(this.type, this.controller);

  Map<String, dynamic> toJson(){
    return {
      'type': type,
      'controller': List.generate(controller.length, (index) => controller[index].text),
    };
  }
}
