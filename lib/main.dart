// @dart=2.9
import 'package:flutter/material.dart';
import 'addItem.dart';
import 'shared.dart';
import 'your.dart';
import 'answer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:core';
import 'dart:io';
import 'answerpage.dart';
import 'package:checklist/databasemodel.dart';
import 'package:checklist/databasehelper.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:checklist/answer_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
  
}

class MyApp extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'checklist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor:Colors.white
      ),
    
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {   
  int pageindex = 0;
  List fileu =[];
  List sharefile =[];
  List pdffile = [];
  List<Content> note;
  Future<List<Field>> field;
  Future<List<Checklist>> checklist;
  Future<List<Content>> content;
  Future<List<Imagepath>> imagepath;
  Future<List<Specialfield>> specialfield;


void initState(){
  field = Databasehelper.instance.getField();
  checklist = Databasehelper.instance.getChecklist();
  content = Databasehelper.instance.getContent();
  imagepath = Databasehelper.instance.getPath();
  specialfield = Databasehelper.instance.getValue();
  list();
  sharelist();
  super.initState();
}

void click(String content, String title){
  setState(() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => NewItem(this.list, content, title)));
  });
}

void answer(filepath)async{
    var contents =await File(filepath).readAsString();
    var filename = filepath.split('/').last.toString().replaceAll('.chklst', ''); 
    List<dynamic> content= json.decode(contents);
    print(content);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Answer('answer', content, filename, this.sestate, [], [], [], 0, [], [], [])));
    print(filename);
    setState((){});
}

void editanswer(String filename, List tab, List <List> imagepath, List <List> widget, int checklistid, List contentid, List <List> fieldid, List <List> imageid){
  print(tab);
  Navigator.push(context, MaterialPageRoute(builder: (context) => Answer('edit', [], filename, this.sestate, tab, imagepath, widget, checklistid, contentid, fieldid, imageid)));
  setState((){});
}

void continueanswer(String filename, List tab, List <List> imagepath, List <List> widget){
  print(tab);
  Navigator.push(context, MaterialPageRoute(builder: (context) => Answer('continue', [], filename, this.sestate, tab, imagepath, widget, 0, [], [], [])));
  setState((){});
}

void list()async{
    final Directory dir = await getApplicationDocumentsDirectory();
    final Directory dirfol = Directory('${dir.path}/checklist/yourtemplate');
  
    if(await dirfol.exists() == false){
      await dirfol.create(recursive: true);
    }
    setState(() {
      fileu = dirfol.listSync();
    });
    print(fileu);
}

void sharelist()async{
    final Directory dir = await getApplicationDocumentsDirectory();
    final Directory dirfol = Directory('${dir.path}/checklist/sharedtemplate');
    if(await dirfol.exists() == false){
      await dirfol.create(recursive: true);
    }
    setState(() {
      sharefile = dirfol.listSync();
    });
    print(sharefile);
}


void sestate()async{
  field = Databasehelper.instance.getField();
  checklist = Databasehelper.instance.getChecklist();
  content = Databasehelper.instance.getContent();
  imagepath = Databasehelper.instance.getPath();
  specialfield = Databasehelper.instance.getValue();
  setState(() {});
}

void deletefile(Map <int, File> path){
  path.forEach((key, value)async{
    await Databasehelper.instance.removePath(key);
    value.delete();
    print(value.toString());
  });
}

void deletespecialfield(List index)async{
  for(var i in index){
    await Databasehelper.instance.removeValue(i);
  }
}

void deletecontent(List index)async{
  for(var i in index){
    await Databasehelper.instance.removeContent(i);
  }
}

void deletefield(List index)async{
  for(var i in index){
    await Databasehelper.instance.removeField(i);
  }
}

void deletetemplate(int index)async{
  await Databasehelper.instance.removeChecklist(index);
  sestate();
}

Future savepdf(pdf, name, date) async{
  final Directory dir = await getApplicationDocumentsDirectory();
  final Directory dirfol = Directory('${dir.path}/checklist/pdf');
  
  if(await dirfol.exists() == false){
    await dirfol.create(recursive: true);
  }
  final File file = File('${dirfol.path}/${name+'_'+date}.pdf');
  file.writeAsBytesSync(await pdf.save());

  Share.shareFiles(['${dirfol.path}/${name+'_'+date}.pdf']).then((value) => file.delete());
}

  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    print(height);
    print(width);
    double navbar=width/100*27.9; 
  return 
  Scaffold(      
      resizeToAvoidBottomInset: false,
      body:Stack(
        children:<Widget>[
          Row(
            children: <Widget>[
              Stack(
                children: [
                  Container(
                    width: width/100*27.8,
                    height: height,
                    color: Colors.black87,
                  ),

                  Container(
                    width: width/100*28,
                    height: height,
                    child: ListView(
                          children : <Widget>[
                            Container(
                              margin: EdgeInsets.fromLTRB(0, height/100*5, 0, 0),
                              child: GestureDetector(
                              onTap: (){
                                pageindex = 0;
                                print(pageindex);
                                sestate();
                                setState(() {});
                              },
                              child: Row(
                                children: [
                                  Container(
                                    height: 80,
                                    width: 20,
                                    margin:EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    child: RotatedBox(
                                      quarterTurns: -1,
                                      child: Text('MY  LIST', style: TextStyle(color: Colors.white, fontWeight:FontWeight.w300, fontSize: 20)),
                                  )),
                                  
                                  AnimatedContainer(
                                    margin: EdgeInsets.fromLTRB(navbar-30-40.7, 0, 0, 0),
                                    height: 80,
                                    width: 40.8,
                                      duration: Duration(milliseconds:500),
                                      curve: Curves.fastOutSlowIn,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(200.0),
                                        topLeft: Radius.circular(200.0)),
                                        color: pageindex == 0 ? Colors.white : Colors.transparent,
                                      ),
                                    ),
                                ],
                              )
                            )),

                            Container(
                              margin: EdgeInsets.fromLTRB(0, height/100*5, 0, 0),
                              child: GestureDetector(
                              onTap: (){
                                pageindex = 1;
                                print(pageindex);
                                setState(() {});
                                },
                              child: Row(
                                children: [
                                  Container(
                                    height: 80,
                                    width: 20,
                                    margin:EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    child: RotatedBox(
                                    quarterTurns: -1,
                                    child: Text('SHARED', style: TextStyle(color: Colors.white, fontWeight:FontWeight.w300, fontSize: 20)),
                                  )),
                                  
                                    AnimatedContainer(
                                      margin: EdgeInsets.fromLTRB(navbar-30-40.7, 0, 0, 0),
                                      height: 80,
                                      width: 40.8,
                                        duration: Duration(milliseconds:500),
                                          curve: Curves.fastOutSlowIn,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(200.0),
                                            topLeft: Radius.circular(200.0)),
                                            color: pageindex == 1 ? Colors.white : Colors.transparent,
                                          ),
                                    ),
                                  ],
                                )
                              )
                            ),

                          Container(
                            margin: EdgeInsets.fromLTRB(0, height/100*5, 0, 0),
                            child: GestureDetector(
                              onTap: (){
                                pageindex = 2;
                                print(pageindex);
                                setState(() {});
                                },
                              child: Row(
                                children: [
                                  Container(
                                    height: 100,
                                    width: 20,
                                    margin:EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    child: RotatedBox(
                                      quarterTurns: -1,
                                      child: Text('TEMPLATE', style: TextStyle(color: Colors.white, fontWeight:FontWeight.w300, fontSize: 20)),
                                  )),
                                  
                                  AnimatedContainer(
                                      margin: EdgeInsets.fromLTRB(navbar-30-40.7, 0, 0, 0),
                                      height: 80,
                                      width: 40.8,
                                        duration: Duration(milliseconds:500),
                                          curve: Curves.fastOutSlowIn,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(200.0),
                                            topLeft: Radius.circular(200.0)),
                                            color: pageindex == 2 ? Colors.white : Colors.transparent,
                                          ),
                                        ),
                                ],
                              )
                            )
                          ),

                          ]
                        )
                      
                    ),
                ],
              ),
              
              
              Container(
                    width: width/100*72,
                    child: IndexedStack(
                    index: pageindex,
                    children: [
                          answerpage(context,this.sestate, this.field, this.checklist, this.content, this.imagepath, this.specialfield, this.deletefile, this.deletecontent, this.deletefield, this.deletespecialfield, this.deletetemplate,  this.editanswer, this.savepdf, this.continueanswer),
                  
                          sharepage(context, this.sharelist, this.sharefile, this.click, this.answer),

                          yourpage(context, this.click, this.fileu, this.list, this.answer),        
                          ],
                        ),
                      )
                    ],
                ),
              ]
            )
          );
        }
      }

      

