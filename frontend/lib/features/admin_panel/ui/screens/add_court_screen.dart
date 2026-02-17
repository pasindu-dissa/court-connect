import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/user_provider.dart';
import '../../../../core/data/sl_locations.dart';
import '../../data/court_service.dart';

class AddCourtScreen extends StatefulWidget {
  const AddCourtScreen({super.key});

  @override
  State<AddCourtScreen> createState() => _AddCourtScreenState();
}

class _AddCourtScreenState extends State<AddCourtScreen> {
  final _formKey = GlobalKey<FormState>();
  final CourtService _courtService = CourtService();
  
  // Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController(); 
  final _contactController = TextEditingController();
  
  // Location Controllers
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _mapsLinkController = TextEditingController();

  String _selectedSport = "Badminton";
  String? _selectedDistrict;
  String? _selectedCity;
  bool _isLoading = false;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null || user['_id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User ID not found. Please relogin.")));
      return;
    }

    setState(() => _isLoading = true);

    final courtData = {
      "ownerId": user['_id'],
      "name": _nameController.text.trim(),
      "location": _selectedCity ?? _selectedDistrict,
      "district": _selectedDistrict,
      "sport": _selectedSport,
      "pricePerHour": double.tryParse(_priceController.text) ?? 0.0,
      "description": _descriptionController.text.trim(),
      "contactNumber": _contactController.text.trim(),
      "images": [_imageController.text.trim().isEmpty ? "https://images.unsplash.com/photo-1626224583764-847890e058f5" : _imageController.text.trim()],
      // Location Data
      "latitude": double.tryParse(_latController.text) ?? 6.9271, // Default Colombo
      "longitude": double.tryParse(_lngController.text) ?? 79.8612,
      "googleMapsLink": _mapsLinkController.text.trim(),
    };

    try {
      await _courtService.addCourt(courtData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Court Added Successfully!"), backgroundColor: Colors.green));
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Court")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Court Details"),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: _inputDeco("Court Name", Icons.stadium),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedSport,
                decoration: _inputDeco("Sport", Icons.sports_tennis),
                items: ["Badminton", "Tennis", "Basketball", "Futsal", "Cricket", "Swimming"]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedSport = val!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _inputDeco("Price per Hour (LKR)", Icons.attach_money),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle("Location & Directions"),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                decoration: _inputDeco("District", Icons.map),
                items: SLLocations.districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (val) => setState(() {
                  _selectedDistrict = val;
                  _selectedCity = null;
                }),
                validator: (val) => val == null ? "Required" : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: _inputDeco("City", Icons.location_city),
                items: _selectedDistrict == null 
                  ? [] 
                  : SLLocations.districtCities[_selectedDistrict]!.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCity = val),
                validator: (val) => val == null ? "Required" : null,
              ),
              
              const SizedBox(height: 16),
              // Coordinates Inputs
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDeco("Latitude", Icons.gps_fixed),
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDeco("Longitude", Icons.gps_fixed),
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Tip: Right-click on Google Maps > Copy coordinates to help players find you easily.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mapsLinkController,
                decoration: _inputDeco("Google Maps Link (Optional)", Icons.link),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle("Extra Info"),
              const SizedBox(height: 10),

              TextFormField(
                controller: _imageController,
                decoration: _inputDeco("Image URL (Optional)", Icons.image),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: _inputDeco("Contact Number", Icons.phone),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDeco("Description", Icons.description),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Add Court", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary));
  }
}