// class UserModel {
//   final String username;
//   final String password;
//   final String starLocations;
//
//   UserModel({required this.username, required this.password, required this.starLocations});
//
//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       username: json['username'],
//       starLocations: json['starLocations']
//     );
//   }
//
//   Map<String, dynamic> toMap(){
//     return {
//       'username': username,
//       'password': password
//     };
//   }
// }