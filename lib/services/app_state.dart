import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String _currentPrompt = '';
  bool _isGenerating = false;
  final List<String> _promptHistory = [];

  // Getters
  String get currentPrompt => _currentPrompt;
  bool get isGenerating => _isGenerating;
  List<String> get promptHistory => _promptHistory;

  // Setters/Actions
  void updatePrompt(String prompt) {
    _currentPrompt = prompt;
    notifyListeners();
  }

  void startGeneration() {
    if (_currentPrompt.isEmpty) return;
    _isGenerating = true;
    notifyListeners();
  }

  void completeGeneration(String outputVideoUrl) {
    _isGenerating = false;
    if (_currentPrompt.isNotEmpty && !_promptHistory.contains(_currentPrompt)) {
      _promptHistory.insert(0, _currentPrompt);
    }
    notifyListeners();
  }

  void clearPrompt() {
    _currentPrompt = '';
    notifyListeners();
  }
}
