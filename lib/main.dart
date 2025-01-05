import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'One Piece DB',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const ResponsiveHomePage(),
    );
  }
}

class ResponsiveHomePage extends StatefulWidget {
  const ResponsiveHomePage({super.key});

  @override
  State<ResponsiveHomePage> createState() => _ResponsiveHomePageState();
}

class _ResponsiveHomePageState extends State<ResponsiveHomePage> {
  late String selectedGroup; // Usamos late y lo inicializamos más tarde
  List<String> groups = [];
  List<Map<String, dynamic>> members = [];
  late Map<String, dynamic> selectedMember; // Usamos late y lo inicializamos más tarde
  bool showMembers = false;

  @override
  void initState() {
    super.initState();
    selectedGroup = '';
    selectedMember = {}; // Inicializamos con un Map vacío para evitar valores nulos
    fetchGroupsAndMembers();
  }

  Future<void> fetchGroupsAndMembers() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/groups'));

      if (response.statusCode == 200) {
        setState(() {
          groups = List<String>.from(json.decode(response.body));
        });
      } else {
        print('Error fetching groups: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchMembers(String group) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/members/$group'));

      if (response.statusCode == 200) {
        setState(() {
          List<dynamic> data = jsonDecode(response.body);
          members = data.map((item) => Map<String, dynamic>.from(item)).toList();
          selectedGroup = group;
          selectedMember = {}; // Limpiar el miembro seleccionado
          showMembers = true;
        });
      } else {
        print('Error fetching members for $group: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 685;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          'One Piece DB',
          style: TextStyle(
            color: Colors.red,
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFD700),
      ),
      body: isMobile ? _buildMobileLayout(context) : _buildDesktopLayout(context, screenWidth),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return showMembers
        ? Column(
      children: [
        ListTile(
          leading: const Icon(Icons.arrow_back),
          title: const Text('Back to groups'),
          onTap: () {
            setState(() {
              showMembers = false;
              selectedMember = {}; // Limpiar el personaje seleccionado
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return ListTile(
                title: Text(member['name']),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  setState(() {
                    selectedMember = member; // Establecer el personaje seleccionado
                    showMembers = false;
                  });
                },
              );
            },
          ),
        ),
      ],
    )
        : selectedMember.isNotEmpty
        ? Column(
      children: [
        ListTile(
          leading: const Icon(Icons.arrow_back),
          title: const Text('Back to members'),
          onTap: () {
            setState(() {
              selectedMember = {}; // Limpiar la selección del personaje
              showMembers = true;
            });
          },
        ),
        Expanded(child: _buildMemberDetails(selectedMember)), // Muestra los detalles del personaje
      ],
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return ListTile(
          title: Text(group),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            fetchMembers(group);
          },
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context, double screenWidth) {
    return Row(
      children: [
        // Left panel (1/4 de la pantalla)
        Container(
          width: screenWidth / 4,
          color: Colors.grey[100],
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dropdown centrado (el dropdown es como un ComboBox)
              DropdownButton<String>(
                value: selectedGroup.isNotEmpty ? selectedGroup : null,
                hint: const Text('Select group'),
                items: groups.map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedGroup = newValue;
                      fetchMembers(newValue);
                      selectedMember = {}; // Limpiar el personaje seleccionado
                    });
                  }
                },
              ),
              const SizedBox(height: 30),
              // ListView
              Expanded(
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return ListTile(
                      title: Text(member['name']),
                      onTap: () {
                        setState(() {
                          selectedMember = member; // Establecer el personaje seleccionado
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Right panel (2/3 de la pantalla)
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: selectedMember.isEmpty
                ? const Center(
              child: Text(
                'Details will be shown here.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : _buildMemberDetails(selectedMember), // Muestra los detalles si hay un personaje seleccionado
          ),
        ),
      ],
    );
  }


  // Widget que muestra los detalles
  Widget _buildMemberDetails(Map<String, dynamic> member) {
    String imageUrl = 'http://localhost:3000/images/${member['image']}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.network(imageUrl, height: 200),
        const SizedBox(height: 16),
        Text(
          member['name'],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          member['description'],
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        Text(
          'Bounty: ${member['bounty']}',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        Text(
          'Devil Fruit: ${member['devilFruit']}',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        Text(
          'Crew: ${member['crew']}',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        Text(
          'Weapon: ${member['weapon']}',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
