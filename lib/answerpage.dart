// @dart=2.9
import 'dart:typed_data';
import 'package:checklist/answer_widget.dart';
import 'package:checklist/databasemodel.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:checklist/databasehelper.dart';
import 'package:checklist/imageviewer.dart';

class Answer extends StatefulWidget {
  final List<dynamic> contents;
  final String filename;
  final Function setstate;
  final List <List> imagepath;
  final List <List> widget;
  final List tab;
  final String type;
  final int checklistid;
  final List contentid;
  final List <List> fieldid;
  final List <List> imageid;
  Answer(this.type, this.contents, this.filename, this.setstate, this.tab, this.imagepath, this.widget, this.checklistid, this.contentid, this.fieldid, this.imageid);

  @override
  _AnswerState createState() => _AnswerState();
}

class _AnswerState extends State<Answer> {
double width;
double height;
double horizontal; 
int pageindex = 0;
List tab = [];
List widgetValue = [];
List <List> imagepath = [];
List <UniqueKey> pagekey = [];
Map <int, File> pathid = {};

  void initState() {
    super.initState();
    var pixelRatio = window.devicePixelRatio;
    var logicalScreenSize = window.physicalSize / pixelRatio;
    width = logicalScreenSize.width;
    height = logicalScreenSize.height;

    if(widget.type == 'edit'){
      horizontal = 0;
      var indexi = 0;
      var fieldidx = 0;
      tab = widget.tab;
      widgetValue = widget.widget;
      for(int i = 0; i <= tab.length; i++){
        pagekey.add(UniqueKey());
      }
      for (var i in widget.imagepath){
        imagepath.add([]);
        for(var x in i){
          imagepath[indexi].add(<File>[]);
          for(var u in widget.imagepath[indexi][fieldidx]){
            File file = File(u.toString().substring(7,u.length-1));
            imagepath[indexi][fieldidx].add(file);
          }
          fieldidx++;
        }
        indexi++;
        fieldidx = 0; 
      }
      print(tab);
      print('aa');
      print(imagepath);
    }

    if(widget.type == 'continue'){
      horizontal = 0;
      var indexi = 0;
      var fieldidx = 0;
      tab = widget.tab;
      for(int i = 0; i <= tab.length; i++){
        pagekey.add(UniqueKey());
      }
      for (var a in widget.widget){
        widgetValue.add([]);
        imagepath.add([]);
        for(var x in a) {
          if(x.type == 'checklist'){
            widgetValue[indexi].add(
            ChecklistWidget(
              type: 'checklist',
              question: widget.widget[indexi][fieldidx].question,
              checkbox: widget.widget[indexi][fieldidx].checkbox,
              description: TextEditingController(),
            ));
          }
          if(x.type == 'dropdown'){
            widgetValue[indexi].add(
              DropdownWidget(
                type: 'dropdown',
                question: widget.widget[indexi][fieldidx].question,
                listOfChoices: widget.widget[indexi][fieldidx].listOfChoices,
                selection: null
              )
            );
          }
          imagepath[indexi].add(<File>[]);
          fieldidx ++;
        }
        fieldidx = 0;
        indexi++;
      }
      print(tab);
      print('aa');
      print(imagepath);
    }

    if(widget.type == 'answer'){
      List<dynamic> content = widget.contents;
      print(content);
      horizontal = 0;
      var indexi = 0;
      for(var i in content){
        String nkey = i.keys.toString().replaceAll(')','').replaceAll('(','');
        print('ini nkey $nkey');
        tab.add(nkey.toString());
        pagekey.add(UniqueKey());
        widgetValue.add([]);
        imagepath.add([]);
        for(var n in i[nkey]){
          imagepath[indexi].add([]);
          if(n['type'] == 'dropdown'){
            widgetValue[indexi].add(
              DropdownWidget(
                type: 'dropdown',
                question: n['controller'][0],
                listOfChoices: ((){
                  List <String> list = [];
                  for (var i = 0; i < n['controller'].length; i++) {
                   if(i!=0){
                     list.add(n['controller'][i]);
                   }                  
                  }
                  return list;
                }()),
            ));
          }
          if(n['type'] == 'checklist'){
            widgetValue[indexi].add(
              ChecklistWidget(
                type: 'checklist',
                question: n['controller'][0],
                checkbox: false,
                description: TextEditingController(),
              )
            );
          }
        }
        indexi ++;
      }
    }
  }


  void dispose() {
    for(var i in widgetValue){
      for(var x in i){
        if(x.type == 'checklist'){
          x.description.dispose();
        }
      }
    }
    super.dispose();
  }

  _getFromCamera(index) async {
    PickedFile pickedFile = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
    );  
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      Directory storage = await getExternalStorageDirectory();
      final externalpath = storage.path;
      print(imageFile.toString().substring(48));
      imageFile.copySync('$externalpath/${imageFile.toString().substring(48)}');
      imagepath[pageindex][index].add(File('$externalpath/${imageFile.toString().substring(48)}'));        
      imageFile.delete();
      setState(() {});
      print(storage.path);
    }
  }

  void tablechecklist(date, int remind)async{
    await Databasehelper.instance.addChecklist(Checklist(name: widget.filename, date: date.toString(), remind: remind));
  }

  void tablecontent(tcid, tabname)async{
    await Databasehelper.instance.addContent(Content(templateid: tcid, tabname: tabname.toString()));
  }

  void tablefield(tcid, pageid, String check, String question, String description)async{
    print('deskripsinya woi $description');
    await Databasehelper.instance.addField(Field(templateid: tcid, contentid: pageid, checkbox: check, checklist: question, description: description));
  }

  void tablepath(tcid, pageid, fieldid, String imagepath)async{
    await Databasehelper.instance.addPath(Imagepath(templateid: tcid, contentid: pageid, fieldid: fieldid, path: imagepath));
  }

  void tablespecialfield(tcid, pageid, fieldid, String value, String selection)async{
    print(value);
    await Databasehelper.instance.addValue(Specialfield(templateid: tcid, contentid: pageid, fieldid: fieldid, value: value.toString(), selection: selection));
  }

  void editchecklist(date, int remind)async{
    await Databasehelper.instance.updateChecklist(Checklist(id: widget.checklistid, name: widget.filename, date: date.toString(), remind: remind)).then((value){return;});
  }

  void editcontent(id, tcid, tabname)async{
    await Databasehelper.instance.updateContent(Content(id: id, templateid: tcid, tabname: tabname.toString())).then((value){return;});
  }

  void editfield(id, tcid, pageid, String check, String question, String description)async{
    await Databasehelper.instance.updateField(Field(id: id, templateid: tcid, contentid: pageid, checkbox: check, checklist: question, description: description)).then((value){return;});
  }

  void editspecialfield(id, tcid, pageid, fieldid, String value, String selection)async{
    await Databasehelper.instance.updateValue(Specialfield(id: id, templateid: tcid, contentid: pageid, fieldid: fieldid, value: value.toString(), selection: selection)).then((value){return;});
  }

  void editpath(id, tcid, pageid, fieldid, String imagepath)async{
    await Databasehelper.instance.updatePath(Imagepath(id: id, templateid: tcid, contentid: pageid, fieldid: fieldid, path: imagepath)).then((value){return;});
  }

  void deletepath(int id)async{
    await Databasehelper.instance.removePath(id).then((value){return;});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      body: Stack(
      children: <Widget>[
      AnimatedContainer(
        duration: Duration(milliseconds:50),
        curve: Curves.easeOut,
        margin : EdgeInsets.only(right:horizontal),
        child: 
          SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: 
            Stack(
              children: <Widget>[
                Container(
                  width: width/100*27.8,
                  height: height,
                  color: Colors.black87,
                ),

                Container(
                  width: width/100*27.9,
                  height: height,         
                  child: Column(
                  children: [
                    Container(
                      width: width/100*27.9,
                      height: height-170,
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: tab.length,
                        itemBuilder: (context, index){
                          print(tab.length);
                          return Stack(
                            children: [

                              Container(
                                height: height/100*8.5,
                                margin: EdgeInsets.fromLTRB(width/100*3.5, height/100*4.8, 0, 0),
                                child: RotatedBox(
                                  quarterTurns: -1,
                                  child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,//.horizontal
                                  child:Text(tab[index], style: TextStyle(color: Colors.white, fontWeight:FontWeight.w300, fontSize: 20)),
                                ))),

                                GestureDetector(
                                  onTap: (){
                                    pageindex = index;
                                    print(pageindex);
                                    setState(() {});
                                  },
                                  child:AnimatedContainer(
                                    width: width/100*11.1,
                                    height: height/100*10.2,
                                    margin: EdgeInsets.fromLTRB(width/100*17,  height/100*4.5, 0, 0),
                                    curve: Curves.fastOutSlowIn,
                                    duration: Duration(milliseconds:500),
                                    decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(200.0),
                                      topLeft: Radius.circular(200.0),
                                    ),
                                    color: pageindex == index ? Colors.white : Colors.transparent,
                                  )
                                )
                              )
                            ],
                          );
                        }
                      ), 
                    ),

                    Stack(
                      children: [
                        Container(
                          height: height/100*8.5,
                          margin: EdgeInsets.fromLTRB(width/100*3.5, height/100*4.8, 0, 0),
                          child: RotatedBox(
                            quarterTurns: -1,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,//.horizontal
                              child:Text('Done', style: TextStyle(color: Colors.white, fontWeight:FontWeight.w300, fontSize: 20)),
                            ))),
                            
                        GestureDetector(
                          onTap: () {
                            if(widget.type == 'edit'){
                              int remind = 0;
                              DateTime now = new DateTime.now();
                              DateTime date = new DateTime(now.year, now.month, now.day, now.hour, now.minute);
                              String datenow = date.toString().substring(0,16);
                              int tabindex = 0;
                              int fieldindex = 0;
                              for(var i in widgetValue){
                                for(var n in i){      
                                  if(n.type == 'checklist'){
                                    if(n.checkbox == false){
                                      remind = 1;
                                    }
                                  }
                                }
                              }
                              pathid.forEach((key, value){
                                deletepath(key);
                                value.delete();
                                print(value.toString());
                              });
                              for(var i in widget.contentid){
                                editcontent(i, widget.checklistid, tab[tabindex]);
                                for(var n in widget.fieldid[tabindex]){
                                  if(widgetValue[tabindex][fieldindex].type == 'checklist'){
                                    editfield(n, widget.checklistid, i, widgetValue[tabindex][fieldindex].checkbox.toString(), widgetValue[tabindex][fieldindex].question.toString(), widgetValue[tabindex][fieldindex].description.text.toString());
                                    if(widget.imagepath[tabindex][fieldindex].length != 0){
                                      for(var x in imagepath[tabindex][fieldindex]){
                                        if(widget.imagepath[tabindex][fieldindex].contains(x.toString()) != true){
                                          tablepath(widget.checklistid, i, fieldindex, x.toString());
                                        }
                                      }
                                    }
                                    else{
                                      for(var x in imagepath[tabindex][fieldindex]){
                                        tablepath(widget.checklistid, i, fieldindex, x.toString());
                                      }
                                    }
                                  }
                                  if(widgetValue[tabindex][fieldindex].type == 'dropdown'){
                                    editspecialfield(n, widget.checklistid, i, fieldindex, 
                                    ((){
                                      List list = [];
                                      list.add(widgetValue[tabindex][fieldindex].question);
                                      list.addAll(widgetValue[tabindex][fieldindex].listOfChoices);
                                      return list.join(',');
                                    }()),
                                    widgetValue[tabindex][fieldindex].selection);
                                  }
                                  fieldindex++;
                                }
                                fieldindex = 0;
                                tabindex++;
                              }
                              print('remind : $remind');
                              editchecklist(datenow, remind);
                              Navigator.of(context).pop();
                              widget.setstate();
                            }
                            else{
                              int remind = 0;
                              DateTime now = new DateTime.now();
                              DateTime date = new DateTime(now.year, now.month, now.day, now.hour, now.minute);
                              String datenow = date.toString().substring(0,16);
                              int tabindex = 0;
                              for(var i in widgetValue){
                                for(var n in i){      
                                  if(n.type == 'checklist'){
                                    if(n.checkbox == false){
                                      remind = 1;
                                    }
                                  }
                                }
                              }
                              int templateid = 0;
                              Databasehelper.instance.countChecklist().then((templateidx){
                                templateid = templateidx;
                                for(var i in tab){
                                  tablecontent(templateidx+1, i);
                                }
                              });
                              Databasehelper.instance.countContent().then((value){
                                int contentid = 0;
                                int fieldindex = 0;
                                print('ini value count oiiiii $value');
                                contentid = value == 0 ? 1 : value+1;
                                print('in content id nya woi $contentid');
                                print('ini widget value woiiii $widgetValue');
                                for(var i in widgetValue){
                                  for(var n in i){
                                    if(n.type == 'checklist'){
                                      print(n.question);
                                      tablefield(templateid+1, contentid, n.checkbox.toString(), n.question.toString(), n.description.text.toString());
                                      for(var e in imagepath[tabindex][fieldindex]){
                                        tablepath(templateid+1, contentid, fieldindex, e.toString());
                                      }
                                    }
                                    if(n.type == 'dropdown'){
                                      print('tulis ${n.listOfChoices}');
                                      tablespecialfield(
                                        templateid+1, 
                                        contentid, 
                                        fieldindex, 
                                        ((){
                                          List list = [];
                                          list.add(n.question);
                                          list.addAll(n.listOfChoices);
                                          return list.join(',');
                                        }()),
                                        n.selection
                                      );
                                    }
                                    fieldindex++;
                                  }
                                  fieldindex = 0;
                                  contentid ++;
                                }
                              });
                              print('remind : $remind');
                              tablechecklist(datenow, remind);
                              widget.setstate();                   
                              Navigator.of(context).pop();
                              widget.setstate();
                            }            
                          },
                          child: Container(
                            width: width/100*11.1,
                            height: height/100*10.2,
                            margin: EdgeInsets.fromLTRB(width/100*17,  height/100*4.5, 0, 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(200.0),
                              topLeft: Radius.circular(200.0),
                            ),
                            color: Colors.white,
                            )
                          )
                        )
                      ],
                    )
                  ],
                )
              )
            ],
          ),
        ),
      ),    
      
      AnimatedContainer(
        duration: Duration(milliseconds:500),
        curve: Curves.fastOutSlowIn,
        width: horizontal == 0 ? width - width/100*27.8 : width,
        height: height,
        margin : EdgeInsets.only(left:horizontal == 0 ? width/100*27.8 : 0),
        child: IndexedStack(
          index: this.pageindex,
          children: List.generate(tab.length, (indexa){
          return Container(
            key:pagekey[indexa],
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: widgetValue[indexa].length,
                itemBuilder: (context, index){
                return 
                ((){

                  if(widget.type == 'continue'){

                    if(widgetValue[indexa][index].type == 'checklist'){
                      return Container(
                        width: horizontal == 0 ? 200 : 550,
                        margin: EdgeInsets.only(top: 10),
                        child:Column(
                          children: <Widget>[
                            Row(
                              children: [
                                Transform.scale(
                                  scale: 0.7,                          
                                  child:Checkbox(
                                    value: widgetValue[indexa][index].checkbox,
                                    onChanged: (value){
                                      widgetValue[indexa][index].checkbox = value;
                                      setState(() {});
                                    },
                                  )
                                ),
                                Expanded(
                                  child:Text(
                                    widgetValue[indexa][index].question,
                                    style:TextStyle(fontWeight: FontWeight.w700, fontSize: 17),),
                                ),

                              Expanded(
                                child:IconButton(
                                  icon: Icon(Icons.add_a_photo),
                                  onPressed: (){
                                    _getFromCamera(index);
                                  },
                                ),
                              ),
                            ],
                            ),

                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              width: horizontal == 0 ? 140 : 250,
                              margin: EdgeInsets.fromLTRB(50, 10, 0, 0),
                              child:TextFormField(
                                keyboardType: TextInputType.multiline,
                                maxLines: null, 
                                textInputAction: TextInputAction.newline,
                                controller: widgetValue[indexa][index].description,
                                style:TextStyle(fontWeight: FontWeight.w500, 
                                  fontSize: 15),
                                  decoration: new InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintStyle: TextStyle(
                                    fontWeight: FontWeight.w500, 
                                    fontSize: 15),
                                    contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    hintText: 'Description'),
                              ),
                            )),

                            ((){
                              if(imagepath[indexa][index].length != 0){
                                return Container(
                                  width: 140,
                                  height: 150,
                                  margin: EdgeInsets.fromLTRB(0, 10, 70, 0),
                                  child:ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: imagepath[indexa][index].length,
                                    itemBuilder: (context, fileindex){
                                    return Stack(
                                          children: [
                                          GestureDetector(
                                            onTap: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ImageViewer(image: imagepath[indexa][index])));
                                            },
                                            child: Container(
                                              margin: EdgeInsets.fromLTRB(8, 10, 0, 0),
                                              child: Image.file(
                                                imagepath[indexa][index][fileindex],
                                                width: horizontal == 0 ? 200 : 300,
                                                height: horizontal == 0 ? 100 : 200,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () async{
                                              print(imagepath[indexa][index][fileindex]);
                                              await imagepath[indexa][index][fileindex].delete(); 
                                              imagepath[indexa][index].removeAt(fileindex); 
                                              setState(() {});}, 
                                              icon: Icon(Icons.close_rounded)
                                          ),
                                        ],
                                      );                                    
                                    }
                                  )
                                );
                              }
                              else {return Container();}
                            }()),
                            
                            ((){
                              if(widgetValue[indexa][index].checkbox == false){
                                return GestureDetector(
                                  onTap: (){
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Checklist'),
                                          content: new Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('Description : ${widgetValue[indexa][index].description.text}'),
                                              Container(
                                                margin: EdgeInsets.only(top:10),
                                                child: Text('Image :'),
                                              ),
                                              ((){
                                                if(widget.imagepath[indexa][index] != 'null'){
                                                  List <File> image = [];
                                                  for(var u in widget.imagepath[indexa][index]){
                                                    File file = File(u.toString().substring(7,u.length-1));
                                                    image.add(file);
                                                  }
                                                  return Container(
                                                    width: 300,
                                                    height: 300,
                                                    margin: EdgeInsets.only(top:15),
                                                    child: PageView.builder(
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: widget.imagepath[indexa][index].length,
                                                      itemBuilder: (context, fileindex){
                                                      File file = File(widget.imagepath[indexa][index][fileindex].toString().substring(7,widget.imagepath[indexa][index][fileindex].length-1));
                                                      return Stack(
                                                            children: [
                                                            GestureDetector(
                                                              onTap: (){
                                                                Navigator.push(context, MaterialPageRoute(builder: (context) => ImageViewer(image: image)));
                                                              },
                                                              child: Container(
                                                                margin: EdgeInsets.fromLTRB(8, 10, 0, 0),
                                                                child: Image.file(
                                                                  file,
                                                                ),
                                                              ),
                                                            ),
                                                          ]
                                                        );
                                                      }
                                                    )
                                                  );
                                                }
                                                else {return Container();}
                                              }()),
                                            ],
                                          ),
                                        
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('EXIT'),
                                            ),
                                          ],
                                        );
                                    });
                                  },
                                  child:Container(
                                    width: horizontal == 0 ? 235 : 300,
                                    height: 53,
                                    margin: EdgeInsets.fromLTRB(7, 15, 0, 0),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(155, 220, 248, 1.0),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20.0),
                                        bottomRight: Radius.circular(20.0)),
                                    ),
                                    child: Row (
                                      children: [
                                        Container(
                                          width: horizontal == 0 ? 197 : 200,
                                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                                child: Text(
                                                  '''Last Checklist Haven't Been Checked''',
                                                  style:TextStyle(fontWeight: FontWeight.w400, fontSize: 10)
                                                ),
                                              ),

                                              Container(
                                                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                child: Text(
                                                  '''Clicked Here To See''',
                                                  style:TextStyle(fontWeight: FontWeight.w400, fontSize: 10)
                                                ),
                                              ),
                                            ],
                                          ),  
                                        ),

                                        Container(
                                          margin: EdgeInsets.fromLTRB(horizontal == 0 ? 0 : 18, 0, 0, 0),
                                          child: Icon(Icons.arrow_forward_ios_rounded)
                                        )
                                      ],
                                    )
                                  )
                                );
                              }
                              else {
                                return Container();
                              }
                            }())

                          ],
                        ),
                      );
                    } 

                    if(widgetValue[indexa][index].type == 'dropdown'){
                      return Container(
                        margin: EdgeInsets.fromLTRB(20, 10, 0, 0),
                        alignment: Alignment.centerLeft,
                        child:Column(
                          children: <Widget>[
                            Container(
                              width: 150,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child : Text(
                                widgetValue[indexa][index].question,
                                style:TextStyle(fontWeight: FontWeight.w700, fontSize: 17),),
                            ),
                            Container(
                              width: 140,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: DropdownButton(
                                  dropdownColor: Colors.white,
                                  elevation: 0,
                                  isExpanded: true,
                                  value: widgetValue[indexa][index].selection == null ? null : widgetValue[indexa][index].selection,
                                  icon: Icon(Icons.menu,size: 25,),
                                  items: widgetValue[indexa][index].listOfChoices.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem <String>(
                                    value: value,
                                    child: Text(value.toString()),
                                  );}).toList(),
                                  onChanged: (value){
                                    widgetValue[indexa][index].selection = value;
                                    setState(() {});
                                  }
                            ))
                          ],
                        ),
                      ); 
                    }
                  }

                  if(widget.type == 'answer' || widget.type == 'edit'){

                    if(widgetValue[indexa][index].type == 'checklist'){
                      return Container(
                      margin: EdgeInsets.only(top: 10),
                      child:Column(
                        children: <Widget>[
                          Row(
                            children: [
                              Transform.scale(
                                scale: 0.7,                          
                                child:Checkbox(
                                  value: widgetValue[indexa][index].checkbox,
                                  onChanged: (value){
                                    widgetValue[indexa][index].checkbox = value;
                                    setState(() {});
                                  },
                                )
                              ),
                              Container(
                                width: 150,
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child : Text(
                                  widgetValue[indexa][index].question,
                                  style:TextStyle(fontWeight: FontWeight.w700, fontSize: 17),),
                              ),

                              IconButton(
                                icon: Icon(Icons.add_a_photo),
                                onPressed: (){
                                  _getFromCamera(index);
                                },
                              ),
                            ],
                          ),

                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: horizontal == 0 ? 140 : 250,
                            margin: EdgeInsets.fromLTRB(50, 10, 0, 0),
                            child:TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null, 
                              textInputAction: TextInputAction.newline,
                              controller: widgetValue[indexa][index].description,
                              style:TextStyle(fontWeight: FontWeight.w500, 
                                fontSize: 15),
                                decoration: new InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintStyle: TextStyle(
                                  fontWeight: FontWeight.w500, 
                                  fontSize: 15),
                                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  hintText: 'Description'),
                            ),
                          )),

                          ((){
                            if(imagepath[indexa][index].length != 0){
                              return Container(
                                width: 140,
                                height: 150,
                                margin: EdgeInsets.fromLTRB(0, 10, 70, 0),
                                child:ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: imagepath[indexa][index].length,
                                  itemBuilder: (context, fileindex){
                                   return Stack(
                                        children: [
                                        GestureDetector(
                                          onTap: (){
                                             Navigator.push(context, MaterialPageRoute(builder: (context) => ImageViewer(image: imagepath[indexa][index])));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(8, 10, 0, 0),
                                            child: Image.file(
                                              imagepath[indexa][index][fileindex],
                                              width: horizontal == 0 ? 200 : 300,
                                              height: horizontal == 0 ? 100 : 200,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () async{
                                            int pathindex = 0;
                                            if(widget.type == 'answer'){
                                              print(imagepath[indexa][index][fileindex]);
                                              await imagepath[indexa][index][fileindex].delete();
                                              imagepath[indexa][index].removeAt(fileindex); 
                                              setState(() {});
                                            }
                                            if(widget.type == 'edit'){
                                              for(var i in widget.imagepath[indexa][index]){
                                                if(i == imagepath[indexa][index][fileindex].toString()){
                                                  pathid[widget.imageid[indexa][index][pathindex]] = imagepath[indexa][index][fileindex];
                                                }
                                                pathindex++;
                                              }
                                              imagepath[indexa][index].removeAt(fileindex); 
                                              print(pathid);
                                              print(widget.imageid);
                                              setState(() {});
                                            }
                                            }, 
                                            icon: Icon(Icons.close_rounded)
                                        ),
                                      ],
                                    );                                    
                                  }
                                )
                              );
                            }
                            else {return Container();}
                          }())
                        ],
                      ),
                    ); 
                    }
                    if(widgetValue[indexa][index].type == 'dropdown'){
                      return Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child:Column(
                          children: <Widget>[
                            Container(
                              width: 150,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child : Text(
                                widgetValue[indexa][index].question,
                                style:TextStyle(fontWeight: FontWeight.w700, fontSize: 17),),
                            ),
                            Container(
                              width: 140,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: DropdownButton(
                                  dropdownColor: Colors.white,
                                  elevation: 0,
                                  isExpanded: true,
                                  value: widgetValue[indexa][index].selection == null ? null : widgetValue[indexa][index].selection,
                                  icon: Icon(Icons.menu,size: 25,),
                                  items: widgetValue[indexa][index].listOfChoices.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem <String>(
                                    value: value,
                                    child: Text(value.toString()),
                                  );}).toList(),
                                  onChanged: (changedvalue){
                                    widgetValue[indexa][index].selection = changedvalue;
                                    print('seleksi baru nya ${widgetValue[indexa][index].selection}');
                                    setState(() {
                                      
                                    });
                                  }
                            ))
                          ],
                        ),
                      ); 
                    }
                  }
                }());
              }) 
            );  
          })
        )
      ),
      ],
    ) 
    );
  }
}