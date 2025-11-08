// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String email;
  final String? displayName;

  final double dogoScore;
  final int dailyFocusTime;

  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.dogoScore = 0.0,
    this.dailyFocusTime = 480,
    required this.createdAt,
    required this.lastLogin,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    double? dogoScore,
    int? dailyFocusTime,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      dogoScore: dogoScore ?? this.dogoScore,
      dailyFocusTime:
          dailyFocusTime ?? this.dailyFocusTime, // ⬅️ Ceci corrige l'erreur
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      dogoScore: (json['dogoScore'] as num).toDouble(),
      dailyFocusTime: json['dailyFocusTime'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: DateTime.parse(json['lastLogin'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'dogoScore': dogoScore,
      'dailyFocusTime': dailyFocusTime,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }
}
