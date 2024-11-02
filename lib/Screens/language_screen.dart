import 'package:flutter/material.dart';
import '../AppColors/appcolors.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English'; // Default language

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: const Text(
          'Language Settings',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Your Preferred Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Choose from the list of available languages to customize your app experience.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildLanguageOption('English', 'en'),
            _buildLanguageOption('Spanish', 'es'),
            _buildLanguageOption('French', 'fr'),
            _buildLanguageOption('German', 'de'),
            _buildLanguageOption('Chinese', 'zh'),
            _buildLanguageOption('Arabic', 'ar'),
            _buildLanguageOption('Hindi', 'hi'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, String code) {
    return ListTile(
      title: Text(
        language,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: _selectedLanguage == language
          ? Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        // Implement language change functionality here
      },
    );
  }
}
