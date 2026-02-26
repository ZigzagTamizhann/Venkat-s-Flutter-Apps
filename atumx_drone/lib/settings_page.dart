import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _ipController;
  late TextEditingController _aileronTrimController;
  late TextEditingController _elevatorTrimController;
  late TextEditingController _throttleTrimController;

  bool _invertAileron = false;
  bool _invertElevator = false;

  List<Map<String, dynamic>> _trimHistory = [];

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController();
    _aileronTrimController = TextEditingController();
    _elevatorTrimController = TextEditingController();
    _throttleTrimController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('targetIP') ?? '192.168.4.1';
      _aileronTrimController.text = (prefs.getDouble('aileronTrim') ?? 0.0).toString();
      _elevatorTrimController.text = (prefs.getDouble('elevatorTrim') ?? 0.0).toString();
      _throttleTrimController.text = (prefs.getDouble('throttleTrim') ?? 0.0).toString();
      _invertAileron = prefs.getBool('invertAileron') ?? false;
      _invertElevator = prefs.getBool('invertElevator') ?? false;

      List<String> historyJson = prefs.getStringList('trimHistory') ?? [];
      _trimHistory = historyJson
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList()
          .reversed.toList();
    });
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('targetIP', _ipController.text);
      await prefs.setDouble('aileronTrim', double.tryParse(_aileronTrimController.text) ?? 0.0);
      await prefs.setDouble('elevatorTrim', double.tryParse(_elevatorTrimController.text) ?? 0.0);
      await prefs.setDouble('throttleTrim', double.tryParse(_throttleTrimController.text) ?? 0.0);
      await prefs.setBool('invertAileron', _invertAileron);
      await prefs.setBool('invertElevator', _invertElevator);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Color(0xFFFF6B35),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _resetToDefaults() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Settings'),
        content: Text('Are you sure you want to reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCEL', style: TextStyle(color: Color(0xFF666666))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF6B35)),
            child: Text('RESET', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('targetIP');
      await prefs.remove('aileronTrim');
      await prefs.remove('elevatorTrim');
      await prefs.remove('throttleTrim');
      await prefs.remove('invertAileron');
      await prefs.remove('invertElevator');
      
      _loadSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings reset to defaults'), backgroundColor: Color(0xFFFF6B35)),
      );
    }
  }

  Future<void> _loadProfile(Map<String, dynamic> profile) async {
    setState(() {
      _aileronTrimController.text = (profile['aileronTrim'] ?? 0.0).toString();
      _elevatorTrimController.text = (profile['elevatorTrim'] ?? 0.0).toString();
      _throttleTrimController.text = (profile['throttleTrim'] ?? 0.0).toString();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile loaded. Click Save to apply.'), backgroundColor: Color(0xFFFF6B35)),
    );
  }

  Future<void> _deleteProfile(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyJson = prefs.getStringList('trimHistory') ?? [];
    List<Map<String, dynamic>> history = historyJson.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
    
    history.removeWhere((item) => item['timestamp'] == _trimHistory[index]['timestamp']);

    await prefs.setStringList('trimHistory', history.map((item) => jsonEncode(item)).toList());
    _loadSettings();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _aileronTrimController.dispose();
    _elevatorTrimController.dispose();
    _throttleTrimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Color(0xFFFF6B35)),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Settings
              _buildSectionHeader('CONNECTION SETTINGS'),
              SizedBox(height: 16),
              _buildTextField(_ipController, 'Drone IP Address', Icons.wifi, isNumeric: false),
              SizedBox(height: 30),
              
              // Trim Settings
              _buildSectionHeader('TRIM SETTINGS'),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTrimField(_aileronTrimController, 'Aileron Trim', Icons.swap_horiz)),
                  SizedBox(width: 16),
                  Expanded(child: _buildTrimField(_elevatorTrimController, 'Elevator Trim', Icons.swap_vert)),
                  SizedBox(width: 16),
                  Expanded(child: _buildTrimField(_throttleTrimController, 'Throttle Trim', Icons.speed)),
                ],
              ),
              SizedBox(height: 30),
              
              // Channel Inversion
              _buildSectionHeader('CHANNEL CONFIGURATION'),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildInversionSwitch('Invert Aileron Channel', _invertAileron, (val) => setState(() => _invertAileron = val)),
                    SizedBox(height: 12),
                    _buildInversionSwitch('Invert Elevator Channel', _invertElevator, (val) => setState(() => _invertElevator = val)),
                  ],
                ),
              ),
              SizedBox(height: 30),
              
              // Action Buttons
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 2,
                      ),
                      child: Text('SAVE SETTINGS', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 12),
                    TextButton(
                      onPressed: _resetToDefaults,
                      style: TextButton.styleFrom(
                        foregroundColor: Color(0xFF666666),
                      ),
                      child: Text('Reset to Defaults', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              
              // Trim History
              if (_trimHistory.isNotEmpty) ...[
                _buildSectionHeader('TRIM PROFILES'),
                SizedBox(height: 16),
                ..._trimHistory.asMap().entries.map((entry) {
                  final index = entry.key;
                  final profile = entry.value;
                  final profileName = profile['name'] as String?;
                  final timestamp = DateTime.tryParse(profile['timestamp'] ?? '') ?? DateTime.now();
                  
                  return _buildProfileCard(
                    index,
                    profileName ?? 'Unnamed Profile',
                    timestamp,
                    profile['aileronTrim'] ?? 0.0,
                    profile['elevatorTrim'] ?? 0.0,
                    profile['throttleTrim'] ?? 0.0,
                  );
                }),
                SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFFF6B35), width: 2),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumeric = true}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFFFF6B35), size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Color(0xFF666666)),
        ),
        style: TextStyle(color: Color(0xFF333333), fontSize: 14),
        keyboardType: isNumeric ? TextInputType.numberWithOptions(signed: true, decimal: true) : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          if (isNumeric && double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTrimField(TextEditingController controller, String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFFF6B35).withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Icon(icon, color: Color(0xFFFF6B35), size: 18),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    hintText: '0.0',
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'RobotoMono',
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '';
                    }
                    if (double.tryParse(value) == null) {
                      return '';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInversionSwitch(String title, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xFFFF6B35),
          activeTrackColor: Color(0xFFFF6B35).withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildProfileCard(int index, String name, DateTime timestamp, double aileron, double elevator, double throttle) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.download, size: 18, color: Color(0xFFFF6B35)),
                      onPressed: () => _loadProfile(_trimHistory[index]),
                      tooltip: 'Load Profile',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      onPressed: () => _deleteProfile(index),
                      tooltip: 'Delete Profile',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Saved: ${timestamp.toLocal().toString().substring(0, 16)}',
              style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTrimValue('AILERON', aileron),
                  _buildTrimValue('ELEVATOR', elevator),
                  _buildTrimValue('THROTTLE', throttle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrimValue(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF666666),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono',
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }
}