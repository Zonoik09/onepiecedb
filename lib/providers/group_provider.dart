import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroupProvider extends ChangeNotifier {
  List<String> groups = [];
  List<Map<String, dynamic>> members = [];
  String selectedGroup = '';
  Map<String, dynamic> selectedMember = {};
  bool showMembers = false;

  String serverUrl =
      'http://localhost:3000'; // Para escritorio o iOS (ajustar con IP real)

  /// **Obtener lista de grupos**
  Future<void> fetchGroupsAndMembers() async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/api/groups'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        groups = List<String>.from(json.decode(response.body));
        print('Grupos obtenidos: $groups');
        notifyListeners();
      } else {
        print(
            'Error al obtener grupos: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error de conexión al servidor: $e');
    }
  }

  /// **Obtener miembros de un grupo**
  Future<void> fetchMembers(String group) async {
    try {
      print('📡 Enviando solicitud a $serverUrl/api/members con group: $group');

      final response = await http.post(
        Uri.parse('$serverUrl/api/members'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'group': group}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        members = data.map((item) => Map<String, dynamic>.from(item)).toList();
        selectedGroup = group;
        selectedMember = {};
        showMembers = true;
        print('Miembros de $group: $members');
        notifyListeners();
      } else {
        print(
            'Error al obtener miembros: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error de conexión al servidor: $e');
    }
  }
}
