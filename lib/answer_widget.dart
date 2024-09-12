// @dart=2.9

import 'package:flutter/cupertino.dart';

class AnswerWidget{
  String type; 
  String question;
  AnswerWidget({this.type, this.question});
}

class DropdownWidget extends AnswerWidget {
  List <String> listOfChoices;
  String selection;
  DropdownWidget({type, question, this.listOfChoices, this.selection}) : super (type: type, question: question);
}

class ChecklistWidget extends AnswerWidget {
  bool checkbox;
  TextEditingController description;
  ChecklistWidget({type, question, this.checkbox, this.description}) : super (type: type, question: question);
}
