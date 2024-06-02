import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recyclear/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final AuthServices authServices = AuthServicesImpl();

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      final result =
          await authServices.signInWithEmailAndPassword(email, password);
      if (result) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userType = await authServices.getUserType(user.uid);
          if (userType != null) {
            print("User Type: $userType"); // Print to console
            emit(AuthSuccess(userType: userType));
          } else {
            emit(AuthFailure('User type is undefined.'));
          }
        } else {
          emit(AuthFailure('User is not logged in.'));
        }
      } else {
        emit(AuthFailure('Failed to sign in'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password,
      String name, String phone, String photoUrl, String type) async {
    emit(AuthLoading());
    try {
      final result = await authServices.signUpWithEmailAndPassword(
        email,
        password,
        name,
        phone,
        photoUrl,
        type,
      );
      if (result) {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure('Failed to sign up'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await authServices.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> getCurrentUser() async {
    emit(AuthLoading());
    try {
      final user = await authServices.currentUser();
      if (user != null) {
        emit(AuthSuccess());
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<bool> rememberMe() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool rememberMe = preferences.getBool('rememberMe') ?? false;
    if (rememberMe && FirebaseAuth.instance.currentUser != null){
      return true;
    }else {
      return false;
    }

  }

}
