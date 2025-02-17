class VideoModel {
  int? id;
  String? title;
  String? category;
  String? url;
  String? createdAt;
  int? alarm;
  String? thumbnail;

  VideoModel(
      {this.id,
        this.title,
        this.category,
        this.url,
        this.createdAt,
        this.alarm,
      this.thumbnail});

  VideoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    category = json['category'];
    url = json['url'];
    createdAt = json['created_at'];
    alarm = json['alarm'];
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['category'] = this.category;
    data['url'] = this.url;
    data['created_at'] = this.createdAt;
    data['alarm'] = this.alarm;
    data['thumbnail'] = this.thumbnail;
    return data;
  }
}
