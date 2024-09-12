// @dart=2.9
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:core';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

Widget sharepage (BuildContext context, sharelist, sharefile, callback, answerclbck){
  double height=MediaQuery.of(context).size.height;
  double width=MediaQuery.of(context).size.width;

  return Stack(
  children:<Widget> [
      Container(
        margin: EdgeInsets.fromLTRB(width/100*4.2, 10, 0, 0),
        height: 680,
        width: 250,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: sharefile.length,
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
                              child: Text(sharefile[index].path.split('/').last.toString().replaceAll('.chklst', ''),
                              style: Theme.of(context).textTheme.headline5,
                    )),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(120, 0, 0, 0),
                    child: DropdownButtonHideUnderline(
                      child:DropdownButton(
                        dropdownColor: Colors.white,
                        elevation: 0,
                        icon: Icon(Icons.menu,size: 25,),
                        isDense: false,
                        items: <String>['remove file', 'share file', 'answer'].map((String value) {
                          return DropdownMenuItem <String>(
                          value: value,
                          child: Text(value),
                        );}).toList(),
                        onChanged: (String value) async{

                          if(value == 'remove file'){
                            await File(sharefile[index].path).delete();
                            sharelist();                                   
                          }

                          if(value =='share file'){
                            Share.shareFiles(['${sharefile[index].path}'], subject: '${sharefile[index].path.split('/').last.toString().replaceAll('.chklst', '')} checklist template');
                          }

                          if(value == 'answer'){
                            answerclbck(sharefile[index].path);  

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
      child: Align(alignment: Alignment.center, child: IconButton(
        onPressed: ()async{
          FilePickerResult result = await FilePicker.platform.pickFiles();
          if(result != null) {
            final Directory dir = await getApplicationDocumentsDirectory();
            final Directory dirfol = Directory('${dir.path}/checklist/sharedtemplate');
            if(await dirfol.exists() == false){
              await dirfol.create(recursive: true);
            }
            final File file = File(result.files.single.path);
            String filename;
            if(file.path.toString().contains(RegExp('[(,)]'))){
              String filepath = file.path.split('/').last.toString();
              filename = filepath.substring(0, filepath.indexOf('(')).replaceAll(' ', '');
            }else{
              filename = file.path.split('/').last.toString().replaceAll('.chklst', '');
            }
            try{
              String content = await File(file.path).readAsString(); 
              File oldfile;
              
              for(var i in sharefile){
                String oldname = i.path.split('/').last.toString().replaceAll('.chklst', '');
                print(filename.toString());
                print(oldname.toString());
                if(filename.toString() == oldname.toString()){
                  oldfile = File(i.path);
                }
              }

              if(oldfile != null){
                await oldfile.delete();
              }
              final File filepath = File('${dirfol.path}/$filename.chklst');
              await filepath.writeAsString(content.toString());
              sharelist();
            }
            on Exception{}
            
          } else {

          }
        }, 
        icon: Icon(Icons.add)))
  )]);
}