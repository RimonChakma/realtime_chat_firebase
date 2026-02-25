import 'package:chat_app/chat_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  void handleSearch(String query) {
    setState(() {
      searchQuery = query.trim().toLowerCase(); // lowercase & trim
    });
  }

  Stream<QuerySnapshot> searchUsersStream() {
    final usersCollection = FirebaseFirestore.instance.collection("users");

    if (searchQuery.isEmpty) {
      return usersCollection.limit(10).snapshots();
    } else {
      final q = searchQuery;
      return usersCollection
          .where("name", isGreaterThanOrEqualTo: q)
          .where("name", isLessThanOrEqualTo: q + "\uf8ff")
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loggedInUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Search Users"),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: handleSearch,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: searchUsersStream(),
              builder: (context, snapshot) {
                if (searchQuery.isEmpty) {
                  // খালি হলে কিছু দেখাবে না
                  return const Center(child: Text("Start typing to search users"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                final users = snapshot.data!.docs;
                List<Widget> userWidgets = [];

                for (var user in users) {
                  final userData = user.data() as Map<String, dynamic>;
                  final uid = userData['uid'] ?? "";
                  final name = userData['name'] ?? "Unknown";
                  final email = userData['email'] ?? "";

                  if (uid.isNotEmpty && uid != loggedInUser!.uid) {
                    userWidgets.add(
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "?",
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }
                }

                return ListView(children: userWidgets);
              },
            ),
          )
        ],
      ),
    );
  }
}