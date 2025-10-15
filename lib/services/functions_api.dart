import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class FunctionsApi {
  static Future<void> fetchTrendsNow() async {
    final url = Uri.parse('https://<region>-<project-id>.cloudfunctions.net/fetchTrendsNow');
    final r = await http.get(url);
    if (r.statusCode != 200) {
      throw Exception('fetchTrendsNow failed: ${r.body}');
    }
  }

  static Future<List<dynamic>> suggestOutfits({int limit = 6}) async {
    final uid = FirebaseAuth.instance.currentUser!.uid; // auth gerekli
    final callable = FirebaseFunctions.instance.httpsCallable('suggestOutfits');
    final res = await callable.call({'limit': limit});
    return List.from(res.data);
  }
}
