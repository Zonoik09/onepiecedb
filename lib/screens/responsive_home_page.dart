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
            color: Colors.red,
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFD700),
      ),
      body: groupProvider.groups.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : isMobile
              ? _buildMobileLayout(context, groupProvider)
              : _buildDesktopLayout(context, groupProvider, screenWidth),
    );
  }

  Widget _buildMobileLayout(BuildContext context, GroupProvider groupProvider) {
    return groupProvider.showMembers
        ? Column(
            children: [
              ListTile(
                leading: const Icon(Icons.arrow_back),
                title: const Text('Back to groups'),
                onTap: () {
                  setState(() {
                    groupProvider.showMembers = false;
                    groupProvider.selectedMember = {};
                  });
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: groupProvider.members.length,
                  itemBuilder: (context, index) {
                    final member = groupProvider.members[index];
                    return ListTile(
                      title: Text(member['name']),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        setState(() {
                          groupProvider.selectedMember = member;
                          groupProvider.showMembers = false;
                        });
                      },
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
              return ListTile(
                title: Text(group),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  groupProvider.fetchMembers(group);
                  setState(() {
                    groupProvider.showMembers = true;
                  });
                },
              );
            },
          );
  }

  Widget _buildDesktopLayout(
      BuildContext context, GroupProvider groupProvider, double screenWidth) {
    return Row(
      children: [
        Container(
          width: screenWidth / 4,
          color: Colors.grey[100],
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: groupProvider.selectedGroup.isNotEmpty
                    ? groupProvider.selectedGroup
                    : null,
                hint: const Text('Select group'),
                items: groupProvider.groups.map((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    groupProvider.fetchMembers(newValue);
                  }
                },
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: groupProvider.members.length,
                  itemBuilder: (context, index) {
                    final member = groupProvider.members[index];
                    return ListTile(
                      title: Text(member['name']),
                      onTap: () {
                        groupProvider.selectedMember = member;
                        groupProvider.notifyListeners();
                      },
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
                      'Details will be shown here.',
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
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.network(
        'http://localhost:3000/images/${member['image']}',
        height: 200,
      ),
      const SizedBox(height: 16),
      Text(
        member['name'],
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      Text(
        member['description'],
        style: const TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      Text(
        "Bounty: ${member['bounty']}",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      Text(
        "Crew: ${member['crew']}",
        style: const TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 10),
      Text(
        "Weapon: ${member['weapon']}",
        style: const TextStyle(fontSize: 16),
      ),
    ],
  );
}
