import "package:provider/provider.dart";
import "providers/chantier_provider.dart";
import "chantier_detail_screen.dart";
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../models/chantier.dart';
import 'chantier_form_screen.dart';
import '../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await _userService.getUserName();
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _creerNouveauChantier() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ChantierFormScreen(),
      ),
    );
  }

  Future<void> _chargerChantier() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String contents = await file.readAsString();
        Map<String, dynamic> json = jsonDecode(contents);
        Chantier chantier = Chantier.fromJson(json);

        if (mounted) {
          context.read<ChantierProvider>().setChantier(chantier);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chantier ${chantier.nom} chargé avec succès!')),
          );
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ChantierDetailScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menuiserie Pro', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade50,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                _userName != null ? 'Bonjour, $_userName' : '',
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.green),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.home_work_outlined,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _creerNouveauChantier,
                  icon: const Icon(Icons.add),
                  label: const Text('Nouveau Chantier', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 300,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: _chargerChantier,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Charger un Chantier', style: TextStyle(fontSize: 18)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
