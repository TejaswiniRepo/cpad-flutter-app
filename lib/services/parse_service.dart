import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ParseService {
  static Future<List<ParseObject>> fetchItems() async {
    final query = QueryBuilder(ParseObject('Person'));
    final response = await query.query();
    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    }
    return [];
  }

  static Future<void> addItem(String name, int age, String status) async {
    final person = ParseObject('Person')
      ..set('name', name)
      ..set('age', age)
      ..set('status', status);
    await person.save();
  }

  static Future<void> updateItem(ParseObject person, String name, int age, String status) async {
    person.set('name', name);
    person.set('age', age);
    person.set('status', status);
    await person.save();
  }

  static Future<void> deleteItem(ParseObject person) async {
    await person.delete();
  }
}
