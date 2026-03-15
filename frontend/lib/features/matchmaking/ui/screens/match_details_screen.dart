import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/user_provider.dart';
import '../../data/matchmaking_service.dart';

class MatchDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> matchData;
  const MatchDetailsScreen({super.key, required this.matchData});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  final MatchmakingService _matchmakingService = MatchmakingService();
  bool _isProcessing = false;
  late Map<String, dynamic> _localMatchData; // Hold a local copy for instant UI updates

  @override
  void initState() {
    super.initState();
    // Initialize local state with passed data
    _localMatchData = Map<String, dynamic>.from(widget.matchData);
    _localMatchData['joinedPlayers'] = List.from(widget.matchData['joinedPlayers'] ?? []);
    _localMatchData['pendingPlayers'] = List.from(widget.matchData['pendingPlayers'] ?? []);
  }

  // --- HOST: Manage Match Details ---
  void _showHostActionsDialog() {
    final TextEditingController maxPlayersCtrl = TextEditingController(text: _localMatchData['maxPlayers'].toString());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Manage Your Match"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: maxPlayersCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Max Players",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Note: Editing fee or location requires unpublishing and creating a new match.", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              if (_isProcessing) const CircularProgressIndicator(),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: _isProcessing ? null : () async {
                setDialogState(() => _isProcessing = true);
                bool success = await _matchmakingService.updateMatch(_localMatchData['_id'], {"status": "Completed"});
                if (mounted) setDialogState(() => _isProcessing = false);
                
                if (success && mounted) {
                  Navigator.pop(ctx); 
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Match Unpublished.")));
                  Navigator.pop(context, true); // Pop Details Screen, trigger refresh in main feed
                }
              }, 
              child: const Text("Unpublish", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(onPressed: _isProcessing ? null : () => Navigator.pop(ctx), child: const Text("Cancel")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  onPressed: _isProcessing ? null : () async {
                    int newMax = int.tryParse(maxPlayersCtrl.text) ?? _localMatchData['maxPlayers'];
                    setDialogState(() => _isProcessing = true);
                    bool success = await _matchmakingService.updateMatch(_localMatchData['_id'], {"maxPlayers": newMax});
                    if (mounted) setDialogState(() => _isProcessing = false);
                    
                    if (success && mounted) {
                      setState(() {
                        _localMatchData['maxPlayers'] = newMax; // Update locally for instant UI change
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Match Updated successfully."), backgroundColor: Colors.green));
                    }
                  }, 
                  child: const Text("Save")
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- HOST: Approve / Reject Players ---
  Future<void> _handlePlayerRequest(Map player, bool isApprove) async {
    setState(() => _isProcessing = true);
    
    String pId = player['_id'] ?? player.toString();
    bool success = isApprove 
      ? await _matchmakingService.approvePlayer(_localMatchData['_id'], pId)
      : await _matchmakingService.rejectPlayer(_localMatchData['_id'], pId);

    if (success && mounted) {
      setState(() {
        // Remove from pending
        List pending = _localMatchData['pendingPlayers'];
        pending.removeWhere((p) => (p is Map ? p['_id'] : p.toString()) == pId);
        
        // Add to joined if approved
        if (isApprove) {
          _localMatchData['joinedPlayers'].add(player);
          _localMatchData['currentPlayers'] = (_localMatchData['currentPlayers'] ?? 1) + 1;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isApprove ? "Player Approved!" : "Request Rejected"), 
        backgroundColor: isApprove ? Colors.green : Colors.red
      ));
    }
    setState(() => _isProcessing = false);
  }

  // --- PLAYER: Request to Join ---
  void _requestJoin() {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login first.")));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Request to Join"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("You are requesting to join this match. The host will review your request."),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange.shade200)),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text("Payment: You will need to hand over LKR cash to the match Organizer at the court.", style: TextStyle(color: Colors.orange, fontSize: 12))),
                  ],
                ),
              ),
              if (_isProcessing) const Padding(padding: EdgeInsets.only(top: 16), child: CircularProgressIndicator()),
            ]
          ),
          actions: [
            TextButton(onPressed: _isProcessing ? null : () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: _isProcessing ? null : () async {
                setDialogState(() => _isProcessing = true);
                
                final success = await _matchmakingService.requestJoinMatch(_localMatchData['_id'], currentUser['_id']);
                
                if (mounted) setDialogState(() => _isProcessing = false);

                if (success && mounted) {
                  setState(() {
                    // Instantly update UI locally
                    _localMatchData['pendingPlayers'].add(currentUser);
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request sent to host!"), backgroundColor: Colors.green));
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to request. Match might be full.")));
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Send Request"),
            )
          ]
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // Auth & Host verification
    final currentUser = Provider.of<UserProvider>(context).user;
    final hostData = _localMatchData['hostId'];
    bool isHostObj = hostData is Map;
    String actualHostId = isHostObj ? hostData['_id'] : hostData.toString();
    bool isHost = currentUser != null && actualHostId == currentUser['_id'];
    
    // Formatting variables
    String hostName = isHostObj ? hostData['name'] : "Community Organizer";
    String hostImage = isHostObj ? (hostData['profileImage']?.toString().isNotEmpty == true ? hostData['profileImage'] : "https://placehold.co/150x150") : "https://placehold.co/150x150";
    String image = _localMatchData['image'] ?? "https://placehold.co/300x200";
    
    int currentP = _localMatchData['currentPlayers'] ?? 1;
    int maxP = _localMatchData['maxPlayers'] ?? 4;
    double progress = currentP / maxP;
    if (progress > 1.0) progress = 1.0;

    // Player Status Check
    List<dynamic> joinedPlayers = _localMatchData['joinedPlayers'] ?? [];
    List<dynamic> pendingPlayers = _localMatchData['pendingPlayers'] ?? [];
    
    bool hasAlreadyJoined = false;
    bool isPending = false;
    
    if (currentUser != null) {
      hasAlreadyJoined = joinedPlayers.any((p) => (p is Map ? p['_id'] : p.toString()) == currentUser['_id']);
      isPending = pendingPlayers.any((p) => (p is Map ? p['_id'] : p.toString()) == currentUser['_id']);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250, pinned: true, backgroundColor: AppColors.primary, iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(image, fit: BoxFit.cover),
                      Container(color: Colors.black.withValues(alpha: 0.4)),
                    ],
                  ),
                  title: Text(_localMatchData['title'] ?? "Match Details", style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildBadge(_localMatchData['sport'], AppColors.primary),
                          const SizedBox(width: 10),
                          _buildBadge(_localMatchData['skill'], Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      _buildInfoRow(Icons.stadium, "Court", _localMatchData['courtName']),
                      const Divider(height: 30),
                      _buildInfoRow(Icons.location_on, "Location", _localMatchData['location']),
                      const Divider(height: 30),
                      _buildInfoRow(Icons.calendar_month, "Date & Time", "${_localMatchData['date'] ?? 'Upcoming'} • ${_localMatchData['time']}"),
                      const Divider(height: 30),
                      _buildInfoRow(Icons.payments, "Hourly Fee Per Person", "LKR ${_localMatchData['fee']}/hr (Pay Organizer)", color: AppColors.primary),
                      
                      const SizedBox(height: 40),

                      // Host: Pending Requests
                      if (isHost && pendingPlayers.isNotEmpty) ...[
                        const Text("Pending Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                        const SizedBox(height: 12),
                        ...pendingPlayers.map((playerObj) {
                          Map player = playerObj is Map ? playerObj : {'name': 'Unknown Player'};
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
                            child: Row(
                              children: [
                                CircleAvatar(radius: 16, backgroundImage: NetworkImage(player['profileImage'] ?? "https://placehold.co/150x150")),
                                const SizedBox(width: 12),
                                Expanded(child: Text(player['name'] ?? 'Player', style: const TextStyle(fontWeight: FontWeight.bold))),
                                IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: _isProcessing ? null : () => _handlePlayerRequest(player, false)),
                                IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: _isProcessing ? null : () => _handlePlayerRequest(player, true)),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],

                      // Joined Players UI
                      const Text("Players Joined", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("$currentP / $maxP Players", style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(currentP >= maxP ? "Full" : "${maxP - currentP} spots left", style: TextStyle(color: currentP >= maxP ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress, minHeight: 12, backgroundColor: Colors.grey.shade200, color: currentP >= maxP ? Colors.red : AppColors.primary,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      // Avatars List
                      if (joinedPlayers.isNotEmpty)
                        SizedBox(
                          height: 45,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: joinedPlayers.length,
                            itemBuilder: (context, index) {
                              final player = joinedPlayers[index];
                              String pImage = "https://placehold.co/150x150";
                              if (player is Map && player['profileImage']?.isNotEmpty == true) pImage = player['profileImage'];
                              
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
                                  child: CircleAvatar(radius: 20, backgroundImage: NetworkImage(pImage)),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Organizer Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                        child: Row(
                          children: [
                            CircleAvatar(backgroundImage: NetworkImage(hostImage)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Hosted by", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text(isHost ? "You" : hostName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 100), 
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))]),
              child: isHost
                ? ElevatedButton.icon(
                    onPressed: _showHostActionsDialog,
                    icon: const Icon(Icons.edit),
                    label: const Text("Manage Match", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  )
                : ElevatedButton(
                    onPressed: (currentP >= maxP || hasAlreadyJoined || isPending) ? null : _requestJoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPending ? Colors.orange : AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                    ),
                    child: Text(
                      hasAlreadyJoined ? "You're In!" : (isPending ? "Request Pending" : (currentP >= maxP ? "Match Full" : "Request to Join")), 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                  ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, {Color? color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: (color ?? Colors.grey).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color ?? Colors.grey.shade700, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color ?? Colors.black87)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}