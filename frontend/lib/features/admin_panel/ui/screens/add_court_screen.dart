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
  final _plusCodeController = TextEditingController();
  final _mapsLinkController = TextEditingController();

  // State Variables
  final List<String> _availableSports = [
    "Cricket",
    "Tennis",
    "Basketball",
    "Football",
    "Badminton",
    "Swimming",
  ];
  final List<String> _selectedSports = []; // Multi-select list

  String? _selectedDistrict;
  String? _selectedCity;
  String _locationInputType = "Coordinates"; // "Coordinates" or "Plus Code"
  bool _isLoading = false;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one sport")),
      );
      return;
    }

    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null || user['_id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID not found. Please relogin.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Prepare Location Data based on selection
    double? lat = _locationInputType == "Coordinates"
        ? double.tryParse(_latController.text)
        : null;
    double? lng = _locationInputType == "Coordinates"
        ? double.tryParse(_lngController.text)
        : null;
    String? plusCode = _locationInputType == "Plus Code"
        ? _plusCodeController.text.trim()
        : null;

    final courtData = {
      "ownerId": user['_id'],
      "name": _nameController.text.trim(),
      "location": _selectedCity ?? _selectedDistrict,
      "district": _selectedDistrict,
      "sports": _selectedSports, // Send Array
      "pricePerHour": double.tryParse(_priceController.text) ?? 0.0,
      "description": _descriptionController.text.trim(),
      "contactNumber": _contactController.text.trim(),
      "images": [
        _imageController.text.trim().isEmpty
            ? "https://images.unsplash.com/photo-1593491205049-7f032d28cf01"
            : _imageController.text.trim(),
      ],
      "latitude": lat,
      "longitude": lng,
      "plusCode": plusCode,
      "googleMapsLink": _mapsLinkController.text.trim(),
    };

    try {
      await _courtService.addCourt(courtData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Court Added Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
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

              // Multiple Sports Selector
              const Text(
                "Select Sports",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _availableSports.map((sport) {
                  final isSelected = _selectedSports.contains(sport);
                  return FilterChip(
                    label: Text(sport),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedSports.add(sport);
                        } else {
                          _selectedSports.remove(sport);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              if (_selectedSports.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    " * Required",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _inputDeco(
                  "Price per Hour (LKR)",
                  Icons.attach_money,
                ),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle("Location & Directions"),
              const SizedBox(height: 10),

              // District & City
              DropdownButtonFormField<String>(
                initialValue: _selectedDistrict,
                decoration: _inputDeco("District", Icons.map),
                items: SLLocations.districts
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) => setState(() {
                  _selectedDistrict = val;
                  _selectedCity = null;
                }),
                validator: (val) => val == null ? "Required" : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedCity,
                decoration: _inputDeco("City", Icons.location_city),
                items: _selectedDistrict == null
                    ? []
                    : SLLocations.districtCities[_selectedDistrict]!
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                onChanged: (val) => setState(() => _selectedCity = val),
                validator: (val) => val == null ? "Required" : null,
              ),

              const SizedBox(height: 20),

              // Location Input Type Toggle
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildToggleOption("Coordinates"),
                    _buildToggleOption("Plus Code"),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Conditional Input Fields
              if (_locationInputType == "Coordinates")
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _inputDeco("Latitude", Icons.gps_fixed),
                        validator: (val) =>
                            _locationInputType == "Coordinates" && val!.isEmpty
                            ? "Required"
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lngController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _inputDeco("Longitude", Icons.gps_fixed),
                        validator: (val) =>
                            _locationInputType == "Coordinates" && val!.isEmpty
                            ? "Required"
                            : null,
                      ),
                    ),
                  ],
                )
              else
                TextFormField(
                  controller: _plusCodeController,
                  decoration: _inputDeco(
                    "Google Plus Code (e.g. 7FVX+24)",
                    Icons.pin_drop,
                  ),
                  validator: (val) =>
                      _locationInputType == "Plus Code" && val!.isEmpty
                      ? "Required"
                      : null,
                ),

              const SizedBox(height: 8),
              if (_locationInputType == "Coordinates")
                const Text(
                  "Tip: Right-click on Google Maps > Copy coordinates.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                )
              else
                const Text(
                  "Tip: Find this code on the Google Maps location info card.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _mapsLinkController,
                decoration: _inputDeco(
                  "Google Maps Link (Optional)",
                  Icons.link,
                ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Add Court",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  Widget _buildToggleOption(String title) {
    bool isSelected = _locationInputType == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _locationInputType = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
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
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}
