// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'package:checklist/field.dart';

class NewItem extends StatefulWidget {
  final Function callback;
  final String content;
  final String title;
  
  NewItem(this.callback, this.content, this.title);


  @override
  _NewItemState createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
List <TextEditingController>tab=[];
List <List> field=[];
int pageindex=0;
List scrollcont=[];
bool deletemode = true ;
List template=[];
String filename;
double width;
double height;
bool savemode = false; 
List columnkey = [];
List fieldkey = [];
bool choosefield = true;

void initState() {
  var pixelRatio = window.devicePixelRatio;
  var logicalScreenSize = window.physicalSize / pixelRatio;
  width = logicalScreenSize.width;
  height = logicalScreenSize.height;
  print(width);
  print(height);
  if(widget.title == ''){
      tab.add(TextEditingController(text: 'Untitled'));
      field.add(<Type>[]);
      fieldkey.add(<UniqueKey>[]);
      columnkey.add(UniqueKey());
      scrollcont.add(ScrollController(keepScrollOffset: true));
  }
  if(widget.title != ''){
    List<dynamic> content= json.decode(widget.content); 
    filename = widget.title;
    int nindex = 0;
    for(var n in content){
      String nkey = n.keys.toString().replaceAll(')','').replaceAll('(','');
      scrollcont.add(ScrollController(keepScrollOffset: true));
      columnkey.add(UniqueKey());
      fieldkey.add(<UniqueKey>[]);
      tab.add(TextEditingController(text: '$nkey'));
      field.add(<Type>[]);
      for(var x in n[nkey]){
        if(x['type'] == 'dropdown'){
          field[nindex].add(Type('dropdown', List.generate(x['controller'].length, (index) => 
            TextEditingController(text: x['controller'][index])
          )));
        }
        if(x['type'] == 'checklist'){
          field[nindex].add(Type('checklist', [TextEditingController(text: x['controller'][0])]));
        }
        fieldkey[nindex].add(UniqueKey());
      }
      nindex++;
    }
  }
  super.initState();
}


void dispose() {
  var pageidx = 0;
  for(var n in field){
    tab[pageidx].dispose();
    scrollcont[pageidx].dispose();
    for(var i in n){
      if(i.controller.length == 1){
        i.controller[0].dispose();
      }
      if(i.controller.length > 1){
        for(var x in i.controller){
          x.dispose();
        }
      }
    }
    pageidx++;
  }
  super.dispose();
}

void save() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final Directory dirfolder = Directory('${directory.path}/checklist/yourtemplate');
  
  if(await dirfolder.exists()){
    print(template);
    final File file = File('${dirfolder.path}/$filename.chklst');
    await file.writeAsString(template.toString());
  }else{//if folder not exists create folder and then return its path
    final Directory _appDocDirNewFolder=await dirfolder.create(recursive: true);
    final File file = File('${_appDocDirNewFolder.path}/$filename.chklst');
    await file.writeAsString(template.toString());
  }
  widget.callback();
}

void addtemplate(){
  var pageidx = 0;
  for(var n in field){
    template.add({'"${tab[pageidx].text}"':[]});
    if(n.length != 0 ){
      for(var i in field[pageidx]){
        template[pageidx]['"${tab[pageidx].text}"'].add(jsonEncode(i));
      }
    }
    pageidx++;
  }
  print(template);
  print('berhasil');
}


@override
Widget build(BuildContext context) {
  double navbar=width/100*27.9; 
  return 
  Scaffold(  
    body: 
    GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {});
        if(choosefield == false){
          choosefield = true;
          setState(() {});
        }
        if(deletemode == false){
          deletemode = true;
          setState(() {});
        }
      },
    child : Stack(
      children:<Widget> [    
            Container(
              width: width/100*72,
              margin: EdgeInsets.only(left: width/100*27.9) ,
              padding: EdgeInsets.fromLTRB(0, 55, 0, 0),
              child:IndexedStack(
                index: this.pageindex,
                children: List.generate(tab.length, (indexa){
                  return 
                  Column(
                    key:columnkey[indexa],
                    children: <Widget>[
                      Container(
                        width: 100,
                        margin: EdgeInsets.fromLTRB(0, 0, 100, 0),
                        child:TextFormField(
                          controller: tab[indexa],
                          style: TextStyle(fontWeight: FontWeight.w700, 
                          fontSize: 25),
                          decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintStyle: TextStyle(
                          fontWeight: FontWeight.w700, 
                          fontSize: 25),
                          contentPadding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          hintText: 'Checklist Name'),
                          ),
                      ),

                  Flexible(
                    child: Container(
                      height: 590,
                      child: Scrollbar(
                        controller: scrollcont[indexa],
                        child:
                        ReorderableListView(
                          physics: BouncingScrollPhysics(),
                          scrollController: scrollcont[indexa],
                          children: List.generate(field[indexa].length, (index){
                          return 
                          ((){
                            if(field[indexa][index].type == 'checklist'){
                              return Container(
                                height: 100,
                                key:fieldkey[indexa][index],
                                decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(5))),
                                child: Stack(
                                    children: <Widget>[
                                      Transform.scale(
                                        scale: 0.7,
                                        child:
                                      Checkbox(
                                        value: true,
                                        onChanged: (_){},
                                      )),
                                      Container(
                                        width: 115,
                                        margin: EdgeInsets.only(left: 50),
                                        child: TextFormField(
                                          maxLines: null, 
                                          textInputAction: TextInputAction.newline,
                                          controller: field[indexa][index].controller[0],
                                          style:TextStyle(fontWeight: FontWeight.w700, 
                                          fontSize: 15),
                                          decoration: InputDecoration(
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          hintStyle: TextStyle(
                                          fontWeight: FontWeight.w700, 
                                          fontSize: 15),
                                          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          hintText: 'Instruction'),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 150),
                                        child:IconButton(
                                          onPressed: (){
                                            setState(() {
                                              field[indexa].removeAt(index);
                                            });}, 
                                          icon: Icon(Icons.close_rounded))
                                      )
                                    ],
                                )
                              );
                            }
                            if(field[indexa][index].type == 'dropdown'){
                              return Container(
                                key:fieldkey[indexa][index],
                                decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(5))),
                                child: ListTile(
                                  key:fieldkey[indexa][index],
                                  title: Stack(
                                      children: [
                                        Container(
                                          width: 150,
                                          child: TextFormField(
                                            maxLines: null, 
                                            textInputAction: TextInputAction.done,
                                            controller: field[indexa][index].controller[0],
                                            style:TextStyle(fontWeight: FontWeight.w700, 
                                            fontSize: 15),
                                            decoration: new InputDecoration(
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            hintStyle: TextStyle(
                                              fontWeight: FontWeight.w700, 
                                            fontSize: 15),
                                            contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            hintText: 'Instruction'),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 150),
                                          child:IconButton(
                                          onPressed: (){
                                            setState(() {
                                            field[indexa].removeAt(index);
                                          });}, 
                                          icon: Icon(Icons.close_rounded))
                                        )
                                      ],
                                    ),
                                  subtitle:Column(
                                    children: List.generate(field[indexa][index].controller.length, (indexe){
                                      if(indexe != 0){
                                        return Container(
                                          width: 90,
                                          margin: EdgeInsets.only(right: 105),
                                          child: TextFormField(
                                            maxLines: null, 
                                            textInputAction: TextInputAction.done,
                                            controller: field[indexa][index].controller[indexe],
                                            style:TextStyle(fontWeight: FontWeight.w700, 
                                            fontSize: 14),
                                            decoration: new InputDecoration(
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              hintStyle: TextStyle(
                                                fontWeight: FontWeight.w700, 
                                                fontSize: 14),
                                                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                hintText: 'choice'),
                                                onTap: (){
                                                  setState(() {
                                                    if(field[indexa][index].controller.length-1 == indexe){
                                                      field[indexa][index].controller.add(TextEditingController());
                                                    }
                                                  });
                                                },
                                          ),
                                        );
                                      }
                                      else{
                                        return new Container(width: 0.0, height: 0.0);
                                      }
                                    })
                                  )
                                )
                            );
                          }
                        }());
                      }),
                      
                      onReorder:(int oldIndex, int newIndex) {
                        setState(() {
                            FocusScope.of(context).requestFocus(new FocusNode());
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }                           
                            final item = field[pageindex].removeAt(oldIndex);
                            field[pageindex].insert(newIndex, item);
                            final key = fieldkey[pageindex].removeAt(oldIndex);
                            fieldkey[pageindex].insert(newIndex, key);
                            print('ini fieldnya $field');
                        });
                      },
                    ),
                  )))
                ],
              );
            }
          )),
        ),
          IgnorePointer(
            ignoring: choosefield,
            child: AnimatedOpacity(
              opacity: choosefield?0:1, 
              duration: Duration(milliseconds: 0), 
              child:
              Container(
                margin: EdgeInsets.fromLTRB(navbar+20, height/100*75, 0, 0),
                width: 130,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 4,
                      blurRadius: 6,
                      offset: Offset(0, 3),// changes position of shadow
                    ),
                  ]
                ),
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){
                        field[pageindex].add(new Type('checklist', [TextEditingController()]));
                        fieldkey[pageindex].add(UniqueKey());
                        setState(() {});
                      },
                      child: Container(
                        width:100,
                        height: 50,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Checklist', style: TextStyle(color: Colors.black, fontWeight:FontWeight.w500, fontSize: 20)),
                        )
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        field[pageindex].add(new Type('dropdown', [TextEditingController(), TextEditingController()]));
                        fieldkey[pageindex].add(UniqueKey());
                        setState(() {});
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          )
                        ),
                        width:100,
                        height: 50,
                        child: Align(
                          alignment: Alignment.center,
                          child:  Text('Dropdown', style: TextStyle(color: Colors.black, fontWeight:FontWeight.w500, fontSize: 20)),
                        )
                      ),
                    ),
                  ],
                )))),

            SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child:Container(
                width: width/100*27.8,
                height: height,
                color: Colors.black87,
            )),

            SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child:Container(
              width: width/100*28,
              child: Column(
                  children: <Widget>[
                    Container(
                        height: 476,
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount:tab.length,
                            itemBuilder: (context, index){
                              return RotatedBox(
                                  quarterTurns: -1,
                                  child: Container(
                                  height: width/100*27.9,
                                  margin: EdgeInsets.fromLTRB(0, 0, 33, 0),
                                  child: GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        pageindex = index;
                                      });
                                    },
                                    onLongPress: (){
                                      setState(() {
                                        deletemode = false;        
                                      });
                                    },
                                    child:Column(
                                      children: <Widget>[
                                        Container(
                                          height: 45,
                                          width: 100,
                                          margin:EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          child: TextFormField(
                                            style:TextStyle(
                                              color: Colors.white, 
                                              fontWeight:FontWeight.w300, 
                                              fontSize: 20
                                            ),
                                            textAlign: TextAlign.center,
                                            enabled: false,
                                            controller: tab[index],
                                            decoration: InputDecoration(
                                            disabledBorder:
                                            UnderlineInputBorder(borderSide: BorderSide.none)),
                                          )
                                        ),
                                        AnimatedContainer(
                                          margin: EdgeInsets.fromLTRB(0, navbar-45-40.7, 0, 0),
                                          width: 80,
                                          height: 40.8,
                                          duration: Duration(milliseconds:500),
                                          curve: Curves.fastOutSlowIn,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(200.0),
                                            topLeft: Radius.circular(200.0)),
                                            color: index == pageindex ? Colors.white : Colors.transparent,
                                          ),
                                          child: IgnorePointer(
                                            ignoring: deletemode,
                                              child: AnimatedOpacity(opacity: deletemode?0:1, duration: Duration(milliseconds: 500), 
                                              child:IconButton(
                                                onPressed: (){
                                                  setState(() {
                                                    tab.remove(tab[index]);
                                                    if(pageindex == 0){
                                                      pageindex = 1;
                                                    }
                                                    if(pageindex >= index){
                                                      pageindex--;
                                                    }
                                                    field.removeAt(index);
                                                  });                                                                                           
                                                }, icon: Icon(Icons.close_rounded) ,color: Colors.red),
                                              ) ,
                                            )
                                          ),                                   
                                        ],
                                      )
                                    )
                                  )
                                );
                              }
                            )
                          ),

                    RotatedBox(
                      quarterTurns: -1,
                      child: Container(
                        margin:EdgeInsets.only(right: 25),
                        child: GestureDetector(
                          onTap: (){
                            field.add(<Type>[]);
                            tab.add(TextEditingController(text: 'Untitled'));
                            pageindex = tab.length-1;
                            scrollcont.add(ScrollController(keepScrollOffset: true));
                            columnkey.add(UniqueKey());
                            fieldkey.add(<UniqueKey>[]);
                            print(field);
                            print(tab);
                            setState(() {});
                          },
                          child: Column(
                            children: <Widget>[
                            Container(
                              height: 20,
                              margin:EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Text('NEW PAGE', style: TextStyle(color: Colors.white, fontWeight:FontWeight.w300, fontSize: 20)),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, navbar-30-40.7, 0, 0),
                              width: 80,
                              height: 40.8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                topRight: Radius.circular(200.0),
                                topLeft: Radius.circular(200.0)),
                                color: Colors.white,
                              ),
                              child: Icon(Icons.add),
                            ),
                        ],
                      ),  
                    )
                  )
                ),
                    
                   RotatedBox(
                      quarterTurns: -1,
                      child: Container(
                        margin:EdgeInsets.only(right: 25),
                        child:GestureDetector(
                          onTap: (){
                            if(choosefield == false){
                              choosefield = true;
                            }else{
                              choosefield = false;
                            }
                            setState(() {});
                          },
                          child:
                          Column(
                            children: <Widget>[  
                              Container(
                                height: 20,
                                margin:EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text('ADD FIELD', style: TextStyle(color: Colors.white, fontWeight:FontWeight.w300, fontSize: 20)),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, navbar-30-40.7, 0, 0),
                                width: 80,
                                height: 40.8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(200.0),
                                  topLeft: Radius.circular(200.0)),
                                  color: Colors.white,
                                ),
                                child: Icon(Icons.add),
                              ),  
                            ]
                          ),
                        )
                      ),  
                    )
                  ],
                ),
              )
            ),
            
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
              border: Border.all(color: Colors.black87, width: 4.0),
              shape: BoxShape.circle,
              ),
              margin: EdgeInsets.fromLTRB(width/100*75, height/100*88.5, 0, 0),
              child: Align(alignment: Alignment.center, child: 
              IconButton(
                onPressed: (){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('File Name'),
                      content: new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextFormField(
                            inputFormatters: [FilteringTextInputFormatter.deny(RegExp('[()]'))],
                            initialValue: filename,
                            style: TextStyle(
                              fontWeight: FontWeight.w600, 
                              fontSize: 20
                            ),
                            decoration: new InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w600, 
                              fontSize: 20),
                              hintText: 'FORM',),
                            onChanged: (value){
                              filename = value;
                            },
                            ),

                        ],
                      ),
                     
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            if(filename == null){
                                filename = 'form';
                                print(field);
                                addtemplate();
                                save();

                              }else{
                                addtemplate();
                                save();
                              }
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    );
                });
              }, icon: Icon(Icons.add)))
            ),
   
    ]
)));}}
