import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Data
  String _selectedSport = "Tennis";
  String _skillLevel = "All Levels";
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  DateTime _date = DateTime.now();
  double _fee = 0;
  int _maxPlayers = 4;
  
  final TextEditingController _courtController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Host a Match"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sport & Skill Row
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      "Sport", 
                      ["Tennis", "Badminton", "Basketball", "Futsal", "Cricket"], 
                      _selectedSport, 
                      (val) => setState(() => _selectedSport = val!)
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      "Skill Level", 
                      ["Beginner", "Intermediate", "Pro", "All Levels"], 
                      _skillLevel, 
                      (val) => setState(() => _skillLevel = val!)
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Location Details
              const Text("Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildTextField("Court Name", "e.g. Royal Arena", _courtController),
              const SizedBox(height: 12),
              _buildTextField("Area / City", "e.g. Cinnamon Gardens", _locationController, icon: Icons.location_on_outlined),
              
              const SizedBox(height: 24),

              // 3. Date & Time
              const Text("When?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPickerButton(
                      icon: Icons.calendar_today, 
                      text: "${_date.day}/${_date.month}/${_date.year}", 
                      onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime(2026));
                        if (d != null) setState(() => _date = d);
                      }
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPickerButton(
                      icon: Icons.access_time, 
                      text: _time.format(context), 
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _time);
                        if (t != null) setState(() => _time = t);
                      }
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 4. Players & Fee
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Players", style: TextStyle(fontWeight: FontWeight.bold)),
                        Slider(
                          value: _maxPlayers.toDouble(),
                          min: 2, max: 22, divisions: 20,
                          activeColor: AppColors.primary,
                          label: _maxPlayers.toString(),
                          onChanged: (val) => setState(() => _maxPlayers = val.toInt()),
                        ),
                        Center(child: Text("$_maxPlayers Players")),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Fee (LKR)", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "0",
                            prefixText: "LKR ",
                            filled: true, fillColor: Colors.grey[50],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          onChanged: (val) => _fee = double.tryParse(val) ?? 0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 5. Submit
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_courtController.text.isEmpty || _locationController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields")));
                      return;
                    }

                    // Create Mock Match Object
                    final newMatch = {
                      "id": "new_${DateTime.now().millisecondsSinceEpoch}",
                      "sport": _selectedSport,
                      "courtName": _courtController.text,
                      "location": _locationController.text,
                      "time": "${_time.format(context)}",
                      "date": _date.toIso8601String(),
                      "skill": _skillLevel, // Flattened for UI
                      "skillLevel": _skillLevel, // Backend format
                      "fee": _fee,
                      "current": 1, // Host
                      "currentPlayers": 1,
                      "max": _maxPlayers,
                      "maxPlayers": _maxPlayers,
                      "lat": 6.9271, // Default to Colombo for demo
                      "lng": 79.8612,
                      "image": "https://placehold.co/100x100?text=NEW"
                    };

                    // Return data to previous screen
                    Navigator.pop(context, newMatch);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Publish Match", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {IconData? icon}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  Widget _buildPickerButton({required IconData icon, required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}