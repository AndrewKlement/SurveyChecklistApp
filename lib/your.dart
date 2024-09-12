// @dart=2.9
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

Widget yourpage(BuildContext context, callback, file, list, answerclbck){
  double height=MediaQuery.of(context).size.height;
  double width=MediaQuery.of(context).size.width;
  return Stack(
    children: <Widget>[
      Container(
        margin: EdgeInsets.fromLTRB(width/100*4.2, 10, 0, 0),
        height: 680,
        width: 250,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: file.length,
          itemBuilder: (context, index){
          return 
          Container(
            height: 100,
            width: 250,
            child:Card(
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
            child:
              Stack(
                children:<Widget>[ 
                Container(
                  width: 170,
                  margin: EdgeInsets.fromLTRB(10, 25, 0, 10),
                  child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(file[index].path.split('/').last.toString().replaceAll('.chklst', ''),
                            style: Theme.of(context).textTheme.headline5,
                  )),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(105, 0, 0, 0),
                  child: DropdownButtonHideUnderline(
                    child:DropdownButton(
                      dropdownColor: Colors.white,
                      elevation: 0,
                      icon: Icon(Icons.menu,size: 25,),
                      isDense: false,
                      items: <String>['edit template', 'remove file', 'share file',  'answer'].map((String value) {
                        return DropdownMenuItem <String>(
                        value: value,
                        child: Text(value),
                      );}).toList(),
                      onChanged: (String value)async{
                        if(value == 'edit template'){
                          var content =await File(file[index].path).readAsString(); 
                          callback(content, file[index].path.split('/').last.toString().replaceAll('.chklst', ''));
                          print(content);
                        }

                        if(value == 'remove file'){
                          await File(file[index].path).delete();
                          list();                                   
                        }

                        if(value =='share file'){
                          Share.shareFiles(['${file[index].path}'], subject: '${file[index].path.split('/').last.toString().replaceAll('.chklst', '')} checklist template');
                        }

                        if(value == 'answer'){
                          answerclbck(file[index].path);              
                        }
                      }
                  )))
                ]
                )));
            })),

      Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
        border: Border.all(color: Colors.black87, width: 4.0),
        shape: BoxShape.circle,
        ),
        margin: EdgeInsets.fromLTRB(width/100*47.2, height/100*86, 0, 0),
        child: Align(
          alignment: Alignment.center, 
          child: IconButton(
            onPressed: (){
              callback('', '');
              print(file.length);
            }, 
            icon: Icon(Icons.add)))
      ),
    ],
  );
}