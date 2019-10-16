class ClassesInfo {
  String id;
  String classesName;

  static ClassesInfo createFromJson(Map<String, dynamic> json) {
    ClassesInfo info = new ClassesInfo();
    info.id = json['id'];
    info.classesName = json['class_name'];
    return info;
  }
}
