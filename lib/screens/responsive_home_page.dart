import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';

class ResponsiveHomePage extends StatefulWidget {
  const ResponsiveHomePage({super.key});

  @override
  State<ResponsiveHomePage> createState() => _ResponsiveHomePageState();
}

class _ResponsiveHomePageState extends State<ResponsiveHomePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<GroupProvider>(context, listen: false)
          .fetchGroupsAndMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 685;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          'One Piece DB',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
            fontFamily: 'PirataOne',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFDAA520),
        elevation: 8,
        shadowColor: Colors.black54,
      ),
      backgroundColor: const Color(0xFFFFF3CD),
      body: groupProvider.groups.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : isMobile
              ? _buildMobileLayout(context, groupProvider)
              : _buildDesktopLayout(context, groupProvider, screenWidth),
    );
  }

  Widget _buildMobileLayout(BuildContext context, GroupProvider groupProvider) {
    return groupProvider.selectedMember.isNotEmpty
        ? Column(
            children: [
              ListTile(
                leading: const Icon(Icons.arrow_back, color: Colors.red),
                title: const Text('Back to members',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  setState(() {
                    groupProvider.selectedMember = {};
                  });
                },
              ),
              Expanded(
                  child: _buildMemberDetails(groupProvider.selectedMember)),
            ],
          )
        : (groupProvider.showMembers
            ? Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.arrow_back, color: Colors.red),
                    title: const Text('Back to groups',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      setState(() {
                        groupProvider.showMembers = false;
                      });
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: groupProvider.members.length,
                      itemBuilder: (context, index) {
                        final member = groupProvider.members[index];
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(member['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            trailing: const Icon(Icons.arrow_forward,
                                color: Colors.red),
                            onTap: () {
                              setState(() {
                                groupProvider.selectedMember = member;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: groupProvider.groups.length,
                itemBuilder: (context, index) {
                  final group = groupProvider.groups[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text(group,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing:
                          const Icon(Icons.arrow_forward, color: Colors.red),
                      onTap: () {
                        groupProvider.fetchMembers(group);
                        setState(() {
                          groupProvider.showMembers = true;
                        });
                      },
                    ),
                  );
                },
              ));
  }

  Widget _buildDesktopLayout(
      BuildContext context, GroupProvider groupProvider, double screenWidth) {
    return Row(
      children: [
        Container(
          width: screenWidth / 4,
          color: Colors.black87,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Select Group',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButton<String>(
                dropdownColor: Colors.black,
                value: groupProvider.selectedGroup.isNotEmpty
                    ? groupProvider.selectedGroup
                    : null,
                hint: const Text(
                  'Select group',
                  style: TextStyle(color: Colors.white),
                ),
                items: groupProvider.groups.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    groupProvider.fetchMembers(newValue);
                  }
                },
                style: const TextStyle(color: Colors.white),
                iconEnabledColor: Colors.white,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: groupProvider.members.length,
                  itemBuilder: (context, index) {
                    final member = groupProvider.members[index];
                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        title: Text(member['name'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () {
                          groupProvider.selectedMember = member;
                          groupProvider.notifyListeners();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: groupProvider.selectedMember.isEmpty
                ? const Center(
                    child: Text(
                      'Select a character to view details',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : _buildMemberDetails(groupProvider.selectedMember),
          ),
        ),
      ],
    );
  }
}

Widget _buildMemberDetails(Map<String, dynamic> member) {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    color: Colors.amber[100],
    shadowColor: Colors.black,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'http://localhost:3000/images/${member['image']}',
              height: 350,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            member['name'],
            style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 10),
          Text(
            member['description'],
            style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const Divider(thickness: 1, color: Colors.black54),
          const SizedBox(height: 10),
          _buildInfoRow("💰 Bounty:", member['bounty']),
          _buildInfoRow("🏴‍☠️ Crew:", member['crew']),
          _buildInfoRow("⚔️ Weapon:", member['weapon']),
        ],
      ),
    ),
  );
}

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    ),
  );
}
