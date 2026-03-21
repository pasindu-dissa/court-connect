import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/user_provider.dart';
import '../../data/court_service.dart';

class OwnerRevenueScreen extends StatefulWidget {
  const OwnerRevenueScreen({super.key});

  @override
  State<OwnerRevenueScreen> createState() => _OwnerRevenueScreenState();
}

class _OwnerRevenueScreenState extends State<OwnerRevenueScreen> {
  final CourtService _courtService = CourtService();
  double _totalRevenue = 0.0;
  List<dynamic> _breakdown = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRevenue();
  }

  void _loadRevenue() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null && user['_id'] != null) {
      final data = await _courtService.getOwnerRevenue(user['_id']);
      if (mounted) {
        setState(() {
          _totalRevenue = (data['totalRevenue'] ?? 0).toDouble();
          _breakdown = data['breakdown'] ?? [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Revenue Analytics"),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Revenue Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.indigo.shade600, Colors.indigo.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      children: [
                        const Text("Total Earnings", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("Rs ${_totalRevenue.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text("Revenue by Court", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                  const SizedBox(height: 16),

                  if (_breakdown.isEmpty)
                    Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("No revenue data available", style: TextStyle(color: Colors.grey.shade500))))
                  else
                    ..._breakdown.map((court) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), shape: BoxShape.circle),
                                  child: const Icon(Icons.stadium_rounded, color: Colors.teal, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Text(court['courtName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            Text("Rs ${(court['revenue'] ?? 0).toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.indigo, fontSize: 16)),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }
}