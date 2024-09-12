
class Checklist {
  final int ?id;
  final String name;
  final String date;
  final int remind;

  Checklist({this.id, required this.name, required this.date, required this.remind});

  factory Checklist.fromMap(Map<String, dynamic> json) => Checklist(
    id: json['id'],
    name: json['name'],
    date: json['date'],
    remind: json['remind'],
  );

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'name': name,
      'date': date,
      'remind': remind,
    };
  }
}


class Content {
  final int ?id;
  final int templateid;
  final String tabname;

  Content({this.id, required this.templateid, required this.tabname});

  factory Content.fromMap(Map<String, dynamic> json) => Content(
    id: json['id'],
    templateid: json['templateid'],
    tabname: json['tabname'],
  );

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'templateid': templateid,
      'tabname': tabname
    };
  }
}


class Field {
  final int ?id;
  final int templateid;
  final int contentid;
  final String checkbox;
  final String checklist;
  final String description;

  Field({this.id, required this.templateid, required this.contentid, required this.checkbox, required this.checklist, required this.description});

  factory Field.fromMap(Map<String, dynamic> json) => Field(
    id: json['id'],
    templateid: json['templateid'],
    contentid: json['contentid'],
    checkbox: json['checkbox'],
    checklist: json['checklist'],
    description: json['description']
  );
 
  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'templateid': templateid,
      'contentid': contentid,
      'checkbox': checkbox,
      'checklist': checklist,
      'description': description
    };
  }
}

class Imagepath {
  final int ?id;
  final int templateid;
  final int contentid;
  final int fieldid;
  final String path;

  Imagepath({this.id, required this.templateid, required this.path, required this.fieldid, required this.contentid});

  factory Imagepath.fromMap(Map<String, dynamic> json) => Imagepath(
    id: json['id'],
    templateid: json['templateid'],
    contentid: json['contentid'],
    fieldid: json['fieldid'],
    path: json['path'],
  );

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'templateid': templateid,
      'contentid': contentid,
      'fieldid': fieldid,
      'path': path
    };
  }
}

class Specialfield {
  final int ?id;
  final int templateid;
  final int contentid;
  final int fieldid;
  final String value;
  final String selection;

  Specialfield({this.id, required this.templateid, required this.fieldid, required this.contentid, required this.value, required this.selection});

  factory Specialfield.fromMap(Map<String, dynamic> json) => Specialfield(
    id: json['id'],
    templateid: json['templateid'],
    contentid: json['contentid'],
    fieldid: json['fieldid'],
    value: json['value'],
    selection: json['selection'],
  );

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'templateid': templateid,
      'contentid': contentid,
      'fieldid': fieldid,
      'value': value,
      'selection': selection
    };
  }
}