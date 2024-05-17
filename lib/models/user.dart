import '../helpers/custom_trace.dart';
import '../models/medium.dart';

enum UserState { available, away, busy }

class User {
  String id,
      name,
      email,
      password,
      apiToken,
      deviceToken,
      phone,
      address,
      bio,
      otp;
  Medium image;
  // used for indicate if client logged in or not
  bool auth, isRegistered;

  User();

  User.fromJSON(Map<String, dynamic> jsonMap) {
    print(jsonMap['usertype']);
    try {
      id = (jsonMap['id'] ?? jsonMap['user_id']).toString();
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      email = jsonMap['email'] != null ? jsonMap['email'] : '';
      apiToken = jsonMap['api_token'] ?? "";
      deviceToken = jsonMap['device_token'] ?? "";
      otp = jsonMap['otp'] == null ? "" : jsonMap['otp'].toString();
      isRegistered = jsonMap['usertype'] == null
          ? false
          : ((int.tryParse(jsonMap['usertype'] ?? "0") ?? 0) == 1);
      try {
        phone = jsonMap['mobileno'] ??
            jsonMap['alternative_mobileno'] ??
            jsonMap['custom_fields']['phone']['view'];
      } catch (e) {
        phone = "";
      }
      try {
        address = jsonMap['custom_fields']['address']['view'];
      } catch (e) {
        address = "";
      }
      try {
        bio = jsonMap['custom_fields']['bio']['view'];
      } catch (e) {
        bio = "";
      }
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0
          ? Medium.fromMap(jsonMap['media'][0])
          : new Medium(-1, "", "", "", "", "");
    } catch (e) {
      id = "";
      name = "";
      email = "";
      apiToken = "";
      deviceToken = "";
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map<String, dynamic> get json {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map["id"] = id;
    map["email"] = email;
    map["name"] = name;
    map["password"] = password;
    map["api_token"] = apiToken;
    if (deviceToken != null) {
      map["device_token"] = deviceToken;
    }
    map["phone"] = phone;
    map["address"] = address;
    map["bio"] = bio;
    map["media"] = image?.toMap();
    return map;
  }

  Map<String, dynamic> get map {
    Map<String, dynamic> body = new Map<String, dynamic>();
    body['name'] = this.name;
    body['contact'] = this.phone;
    body['email'] = this.email;
    body['fail_existing'] = "1";
    return body;
  }

  Map<String, dynamic> get loginMap {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map["email"] = email;
    map["password"] = password;
    return map;
  }

  Map<String, dynamic> get signInMap {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map["to"] = phone;
    return map;
  }

  @override
  String toString() {
    final map = this.json;
    map["auth"] = this.auth;
    return map.toString();
  }

  bool get profileCompleted =>
      this.address != null &&
      this.address.isNotEmpty &&
      this.phone != null &&
      this.phone.isNotEmpty &&
      int.tryParse(this.phone) != null;

  bool get isCompleteProfile =>
      this.id.isNotEmpty &&
      int.tryParse(this.id) != null &&
      this.apiToken.isNotEmpty &&
      this.name.isNotEmpty &&
      this.email.isNotEmpty &&
      this.phone.isNotEmpty &&
      int.tryParse(this.phone) != null;
}
