class AlarmModel {
  int? id;
  String? alarmName;
  String? alarmSortDesc;
  String? description;
  String? alarmPoa;
  String? createdAt;

  AlarmModel(
      {this.id,
        this.alarmName,
        this.alarmSortDesc,
        this.description,
        this.alarmPoa,
        this.createdAt});

  AlarmModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    alarmName = json['alarm_name'];
    alarmSortDesc = json['alarm_sort_desc'];
    description = json['description'];
    alarmPoa = json['alarm_poa'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['alarm_name'] = this.alarmName;
    data['alarm_sort_desc'] = this.alarmSortDesc;
    data['description'] = this.description;
    data['alarm_poa'] = this.alarmPoa;
    data['created_at'] = this.createdAt;
    return data;
  }
}
