// @dart=2.9
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:checklist/answer_widget.dart';
import 'package:printing/printing.dart'; 


Widget answerpage (BuildContext context, setstate, field, checklist, content, path, specialfield, deletefile, deletecontent, deletefield, deletespecialfield, deletetemplate, editanswer, savepdf, continueanswer){
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  
  return Stack(
    children: [
      Container(
        margin: EdgeInsets.fromLTRB(width/100*4.2, 10, 0, 0),
        height: 680,
        width: 250,
        child:FutureBuilder<List<dynamic>>(
          future: Future.wait([checklist, field, content, path, specialfield]),
          builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot){
            if ( snapshot.hasData) {
              return ListView(
                physics: BouncingScrollPhysics(),
                children: List.generate(snapshot.data[0].length, (index) {
                  List <String> dropdown = ['edit', 'share as PDF', 'remove file'];
                  if(snapshot.data[0][index].remind == 1){dropdown.insert(1, 'follow up');}
                  print(snapshot.data[0][index].remind);
                  return Container(
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
                            child: Text(snapshot.data[0][index].name,
                            style: Theme.of(context).textTheme.headline5,
                          )),
                        ),
                        Container(
                          width: 170,
                          margin: EdgeInsets.fromLTRB(10, 65, 0, 0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(snapshot.data[0][index].date,
                            style: TextStyle(fontWeight: FontWeight.w500, 
                            fontSize: 15),
                          )),
                        ),
                        
                        Container(
                          margin: EdgeInsets.fromLTRB(103, 0, 0, 0),
                          child: DropdownButtonHideUnderline(
                            child:DropdownButton(
                              dropdownColor: Colors.white,
                              elevation: 0,
                              icon: Icon(Icons.menu,size: 25,),
                              isDense: false,
                              items: dropdown.map((String value) {
                                return DropdownMenuItem <String>(
                                value: value,
                                child: Text(value),
                              );}).toList(),
                              onChanged: (String value) async{
                                if(value == 'share as PDF'){
                                  List <List> path = [];
                                  List <List> fieldidx = [];
                                  List <List> widgetType = [];
                                  List <int> contentidx = [];
                                  List <List> pdfwidget = [];
                                  int fieldindex = 0;
                                  int pageindex = 0;
                                  for(var x in snapshot.data[2]){
                                    if(x.templateid == snapshot.data[0][index].id){
                                      contentidx.add(x.id);
                                      path.add(<List> []); 
                                      fieldidx.add([]);
                                      widgetType.add([]);                                     
                                      for(var n in  snapshot.data[1]){
                                        if(n.templateid == snapshot.data[0][index].id){
                                          if(n.contentid == x.id){
                                            fieldidx[pageindex].add(n.id);
                                            widgetType[pageindex].add('checklist');
                                            path[pageindex].add(<File> []);
                                            for(var e in snapshot.data[3]){
                                              if (e.contentid == n.contentid){
                                                  if(e.fieldid == fieldindex){
                                                    path[pageindex][fieldindex].add(File(e.path.substring(7,e.path.length-1)));
                                                  }
                                                }
                                              }
                                            fieldindex++;
                                          }
                                        }
                                      }
                                      for(var c in snapshot.data[4]){
                                        if(c.templateid == snapshot.data[0][index].id){
                                          if(c.contentid == x.id){
                                            path[pageindex].insert(c.fieldid, <File> []);
                                            fieldidx[pageindex].insert(c.fieldid, c.id);
                                            widgetType[pageindex].insert(c.fieldid,'dropdown');
                                          }
                                        }
                                      }

                                      pdfwidget.add(<pw.Widget>[
                                        pw.Header(
                                           level: 0,
                                           child: pw.Text("${x.tabname}")
                                        ),

                                        for (var i = 0; i < widgetType[pageindex].length; i++)
                                          if(widgetType[pageindex][i] == 'checklist')
                                            pw.Container(
                                              margin: pw.EdgeInsets.only(top: 15),
                                              child: pw.Column(
                                              children: [
                                                pw.Align(
                                                  alignment: pw.Alignment.topLeft,
                                                  child: pw.Row(
                                                  mainAxisSize: pw.MainAxisSize.min,
                                                  children: [
                                                    pw.Transform.scale(
                                                      scale: 0.7,                          
                                                      child: snapshot.data[1][fieldidx[pageindex][i]-1].checkbox == 'true' ? pw.Icon(pw.IconData(0xe834)) : pw.Icon(pw.IconData(0xf230))
                                                    ),
                                                    pw.Text(
                                                      snapshot.data[1][fieldidx[pageindex][i]-1].checklist,
                                                      style:pw.TextStyle(fontSize: 17)
                                                    ),
                                                  ],
                                                ),
                                              ),  
                                              pw.Align(
                                                alignment: pw.Alignment.topLeft,
                                                  child: pw.Container(
                                                  margin: pw.EdgeInsets.fromLTRB(25, 10, 0, 0),
                                                  child: pw.Text(
                                                    snapshot.data[1][fieldidx[pageindex][i]-1].description,
                                                    style:pw.TextStyle(fontSize: 17)
                                                  )
                                                )
                                              ),                                                  
                                            ])
                                          )

                                          else if(widgetType[index][i] == 'dropdown')
                                            pw.Container(
                                              margin: pw.EdgeInsets.fromLTRB(0, 10, 400, 0),
                                              child: pw.Column(
                                                children: [
                                                  pw.Text(
                                                    'Dropdown : ${snapshot.data[4][fieldidx[pageindex][i]-1].value.split(',')[0]}',
                                                    style:pw.TextStyle(fontSize: 17)
                                                  ),
                                                  pw.Text(
                                                    'Selection : ${snapshot.data[4][fieldidx[pageindex][i]-1].selection}',
                                                    style:pw.TextStyle(fontSize: 17)  
                                                  )
                                                ]
                                              ),
                                            ),
                                      ]);
                                      
                                        for(var i = 0; i < widgetType[pageindex].length; i++){
                                          if(widgetType[pageindex][i] == 'checklist'){
                                            for(var f = 0; f < path[pageindex][i].length; f++){
                                              pdfwidget[pageindex].insert(i+f+2,
                                                pw.Container(
                                                    width: 100,
                                                    height: 100,
                                                    margin: pw.EdgeInsets.fromLTRB(0, 10, 400, 0),
                                                    child: pw.Image(pw.MemoryImage(path[pageindex][i][f].readAsBytesSync(),))
                                                ) 
                                              );
                                            }
                                          }
                                        }
                                      
                                      fieldindex = 0;
                                      pageindex++;
                                    }
                                  }
                                  final pdf = pw.Document();
                                  pdf.addPage(
                                    pw.MultiPage(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      theme: pw.ThemeData.withFont(
                                        icons: await PdfGoogleFonts.materialIcons()
                                      ),
                                      build: (pw.Context context) => List.generate(contentidx.length, (index) => 
                                        pw.Column(
                                          children: pdfwidget[index]
                                        )
                                      )
                                    ),
                                  );
                                  savepdf(pdf, snapshot.data[0][index].name, snapshot.data[0][index].date);
                                }
                                if(value == 'edit'){       
                                  List <List> widget = [];                         
                                  List tab = [];
                                  List <List> imagepath = [];
                                  int pageindex = 0;
                                  List contentid = [];
                                  List <List> fieldid = [];
                                  List <List> imageid = [];
                                  for(var i in snapshot.data[2]){
                                    if(i.templateid == snapshot.data[0][index].id){
                                      contentid.add(i.id);
                                      fieldid.add([]);
                                      tab.add(i.tabname);
                                      imagepath.add([]);
                                      widget.add([]);
                                      imageid.add([]);
                                      for(var n in  snapshot.data[1]){
                                        if(n.templateid == snapshot.data[0][index].id){
                                          if(n.contentid == i.id){
                                            fieldid[pageindex].add(n.id);
                                            imagepath[pageindex].add([]);
                                            imageid[pageindex].add([]);
                                            widget[pageindex].add(ChecklistWidget(
                                              type: 'checklist',
                                              question: n.checklist,
                                              checkbox: ((){
                                                if(n.checkbox == 'true'){
                                                  return true;
                                                }
                                                if(n.checkbox == 'false'){
                                                  return false;
                                                }
                                              }
                                              ()),
                                              description: TextEditingController(text: n.description),
                                              ));
                                          }
                                        }
                                      }
                                      for(var x in snapshot.data[4]){
                                        if(x.templateid == snapshot.data[0][index].id){
                                          if(x.contentid == i.id){
                                            imagepath[pageindex].add([]);
                                            imageid[pageindex].add([]);
                                            fieldid[pageindex].insert(x.fieldid, x.id);
                                            widget[pageindex].insert(x.fieldid, 
                                              DropdownWidget(
                                                type: 'dropdown',
                                                question: x.value.split(',')[0],
                                                listOfChoices:((){
                                                  List <String> list = [];
                                                  for (var i = 0; i < x.value.split(',').length; i++) {
                                                    if(i!=0){
                                                      list.add(x.value.split(',')[i]);
                                                    }                  
                                                  }
                                                  return list;
                                                }()),
                                                selection: x.selection
                                              )
                                            );
                                          }
                                        }
                                      }
                                      for(var x in snapshot.data[3]){
                                        if(x.templateid == snapshot.data[0][index].id){
                                          if(x.contentid == i.id){
                                            imagepath[pageindex][x.fieldid].add(x.path);
                                            imageid[pageindex][x.fieldid].add(x.id);
                                          }
                                        }
                                      }
                                    pageindex++;
                                    }
                                  }
                                  print('ini imagepath nya $imagepath');
                                  editanswer(await snapshot.data[0][index].name, tab, imagepath, widget, await snapshot.data[0][index].id, contentid, fieldid, imageid);
                                }

                                if(value == 'remove file'){
                                  Map <int, File> path = {};
                                  List <int> fieldidx = [];
                                  List <int> contentidx = [];
                                  List <int> specialfieldidx = [];
                                  for(var n in snapshot.data[1]){
                                    if(n.templateid == snapshot.data[0][index].id){
                                      fieldidx.add(n.id);
                                    }
                                  }
                                  for(var e in snapshot.data[3]){
                                    if (e.templateid == snapshot.data[0][index].id){
                                      path[e.id] = File(e.path.toString().substring(7,e.path.length-1));
                                    }
                                  }
                                  for(var i in snapshot.data[2]){
                                    if(i.templateid == snapshot.data[0][index].id){
                                      contentidx.add(i.id);
                                    }
                                  }
                                  for(var a in snapshot.data[4]){
                                    if(a.templateid == snapshot.data[0][index].id){
                                      specialfieldidx.add(a.id);
                                    }
                                  }
                                  await deletefile(path);
                                  await deletefield(fieldidx);
                                  await deletecontent(contentidx);
                                  await deletespecialfield(specialfieldidx);
                                  await deletetemplate(snapshot.data[0][index].id);
                                }

                                if(value == 'follow up'){
                                  List tab = [];
                                  List <List> imagepath = [];
                                  List <List> widget = [];
                                  int pageindex = 0;
                                  for(var i in snapshot.data[2]){
                                    if(i.templateid == snapshot.data[0][index].id){
                                      tab.add(i.tabname);
                                      imagepath.add([]);
                                      widget.add([]);
                                      for(var n in  snapshot.data[1]){
                                        if(n.templateid == snapshot.data[0][index].id){
                                          if(n.templateid == snapshot.data[0][index].id){
                                            if(n.contentid == i.id){
                                              imagepath[pageindex].add([]);
                                              widget[pageindex].add(ChecklistWidget(
                                                type: 'checklist',
                                                question: n.checklist,
                                                checkbox: ((){
                                                  if(n.checkbox == 'true'){
                                                    return true;
                                                  }
                                                  if(n.checkbox == 'false'){
                                                    return false;
                                                  }
                                                }()),
                                                description: TextEditingController(text: n.description)
                                              ));
                                            }
                                          }
                                        }
                                      }
                                      for(var x in snapshot.data[4]){
                                        if(x.templateid == snapshot.data[0][index].id){
                                          if(x.contentid == i.id){
                                            imagepath[pageindex].add([]);
                                            widget[pageindex].insert(x.fieldid, 
                                            DropdownWidget(
                                              type: 'dropdown',
                                              question: x.value.split(',')[0],
                                              listOfChoices:((){
                                                List <String> list = [];
                                                  for (var i = 0; i < x.value.split(',').length; i++) {
                                                    if(i!=0){
                                                      list.add(x.value.split(',')[i]);
                                                    }                  
                                                  }
                                                  return list;
                                                }()),
                                                selection: x.selection
                                              )
                                            );
                                          }
                                        }
                                      }
                                      for(var x in snapshot.data[3]){
                                        if(x.templateid == snapshot.data[0][index].id){
                                          if(x.contentid == i.id){
                                            imagepath[pageindex][x.fieldid].add(x.path);
                                          }
                                        }
                                      }
                                      pageindex++;
                                    }
                                  }
                                  continueanswer(await snapshot.data[0][index].name, tab, imagepath, widget);
                                }
                              }
                          ))),
                        ]
                      )
                    )
                  );
                })
              );
            } else {
              return new Center(child: new Text(''));
            }
          },
        ),
      ),

    ],
  );
}