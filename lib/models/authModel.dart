class AuthModel {
  int? companyNo;
  int? accountNo;
  String? userId;
  String? userName;
  String? email;
  String? password;
  String? useYn;
  String? registDate;
  String? registUser;
  String? modifyDate;
  String? modifyUser;
  String? userAuth;
  String? companyName;

  AuthModel(
      {this.companyNo,
      this.accountNo,
      this.userId,
      this.userName,
      this.email,
      this.password,
      this.useYn,
      this.registDate,
      this.registUser,
      this.modifyDate,
      this.modifyUser,
      this.userAuth,
      this.companyName});

  AuthModel.fromJson(Map<String, dynamic> json) {
    companyNo = json['company_no'];
    accountNo = json['account_no'];
    userId = json['user_id'];
    userName = json['user_name'];
    email = json['email'];
    password = json['password'];
    useYn = json['use_yn'];
    registDate = json['regist_date'];
    registUser = json['regist_user'];
    modifyDate = json['modify_date'];
    modifyUser = json['modify_user'];
    userAuth = json['user_auth'];
    companyName = json['company_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['company_no'] = companyNo;
    data['account_no'] = accountNo.toString();
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['email'] = email;
    data['password'] = password;
    data['use_yn'] = useYn;
    data['regist_date'] = registDate;
    data['regist_user'] = registUser;
    data['modify_date'] = modifyDate;
    data['modify_user'] = modifyUser;
    data['user_auth'] = userAuth;
    data['company_name'] = companyName;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthModel &&
          runtimeType == other.runtimeType &&
          accountNo == other.accountNo;

  @override
  int get hashCode => accountNo.hashCode;
}
