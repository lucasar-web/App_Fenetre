import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chantier.dart';
import '../services/user_service.dart';
import 'chantier_detail_screen.dart';

class ChantierProvider extends ChangeNotifier {
  Chantier? _chantierActuel;

  Chantier? get chantierActuel => _chantierActuel;

  void setChantier(Chantier chantier) {
    _chantierActuel = chantier;
    notifyListeners();
  }

  void addChassis(Chassis chassis) {
    if (_chantierActuel != null) {
      _chantierActuel!.chassis.add(chassis);
      _chantierActuel!.derniereModification = DateTime.now();
      notifyListeners();
    }
  }

  void updateChassis(Chassis updatedChassis) {
    if (_chantierActuel != null) {
      final index = _chantierActuel!.chassis.indexWhere((c) => c.id == updatedChassis.id);
      if (index != -1) {
        _chantierActuel!.chassis[index] = updatedChassis;
        _chantierActuel!.derniereModification = DateTime.now();
        notifyListeners();
      }
    }
  }
}
