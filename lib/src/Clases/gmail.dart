// ignore_for_file: camel_case_types, prefer_const_declarations

import 'package:google_sign_in/google_sign_in.dart';

class gmail{

  //static final clienteId = '827934697987-79eoavs7jn8dnjcek3dfs70qn3eeuvso.apps.googleusercontent.com';
  
  //static final googleSignIn = GoogleSignIn(clientId: clienteId);

  static final googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> login() => googleSignIn.signIn();

  static Future<GoogleSignInAccount?> disconnect() => googleSignIn.disconnect();

  
}