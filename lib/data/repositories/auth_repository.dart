import '../../models/user_model.dart';

class AuthRepository {
  Future<UserModel> signInMockUser() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return UserModel(
      uid: 'mock_user_123',
      email: 'user@dogo.com',
      displayName: 'Alex',
      dogoScore: 150.5,
      dailyFocusTime: 180,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLogin: DateTime.now(),
    );
  }
}
