class ConferenceModel {
  String? meetId;
  String? subject;
  String? startDate;
  String? closeYn;
  String? registDate;
  String? registUser;
  String? modifyDate;
  String? modifyUser;

  ConferenceModel(
      {this.meetId,
      this.subject,
      this.startDate,
      this.closeYn,
      this.registDate,
      this.registUser,
      this.modifyDate,
      this.modifyUser});

  ConferenceModel.fromJson(Map<String, dynamic> json) {
    meetId = json['meet_id'];
    subject = json['subject'];
    startDate = json['start_date'];
    closeYn = json['close_yn'];
    registDate = json['regist_date'];
    registUser = json['regist_user'];
    modifyDate = json['modify_date'];
    modifyUser = json['modify_user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['meet_id'] = meetId;
    data['subject'] = subject;
    data['start_date'] = startDate;
    data['close_yn'] = closeYn;
    data['regist_date'] = registDate;
    data['regist_user'] = registUser;
    data['modify_date'] = modifyDate;
    data['modify_user'] = modifyUser;
    return data;
  }
}
