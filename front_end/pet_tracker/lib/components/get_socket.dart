import 'package:http/http.dart' as http;

void getDataSocket() async {
  try {
    var response = await http.get(Uri.parse("https://bdfa-170-78-23-134.sa.ngrok.io/"));
    print(response.body);
  } catch (e) {
    print(e.toString());
  }
}