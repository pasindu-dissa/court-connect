import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/avatar_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/user_provider.dart';
import '../../data/matchmaking_service.dart';
import '../../../booking/ui/screens/directions_map_screen.dart'; 

class MatchDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> matchData;
  const MatchDetailsScreen({super.key, required this.matchData});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  final MatchmakingService _matchmakingService = MatchmakingService();
  bool _isProcessing = false;
  late Map<String, dynamic> _localMatchData;
  
  // NEW: Flag to track if we need to refresh the parent screen when going back
  bool _wasModified = false;

  @override
  void initState() {
    super.initState();
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
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Manage Your Match", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: maxPlayersCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: "Max Players",
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group, color: Theme.of(context).iconTheme.color),
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
                  Navigator.pop(context, true); 
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
                    
                    // NEW: Recalculate Fee Logic
                    int oldMax = _localMatchData['maxPlayers'] ?? 1;
                    double oldFee = (_localMatchData['fee'] as num?)?.toDouble() ?? 0.0;
                    int newMax = int.tryParse(maxPlayersCtrl.text) ?? oldMax;
                    
                    if (newMax < 2) newMax = 2; // Prevent 0 or 1 player matches

                    // Calculate original total court cost, then divide by new players
                    double totalCourtPrice = oldFee * oldMax;
                    double newFee = totalCourtPrice / newMax;

                    setDialogState(() => _isProcessing = true);
                    bool success = await _matchmakingService.updateMatch(_localMatchData['_id'], {
                      "maxPlayers": newMax,
                      "fee": newFee // Send new fee to database
                    });
                    
                    if (mounted) setDialogState(() => _isProcessing = false);
                    
                    if (success && mounted) {
                      setState(() {
                        _localMatchData['maxPlayers'] = newMax; 
                        _localMatchData['fee'] = newFee; // Update UI instantly
                        _wasModified = true; // Tell parent screen to refresh
                      });
                      
                      // Also update the widget map directly so parent sees it even before reloading
                      widget.matchData['maxPlayers'] = newMax;
                      widget.matchData['fee'] = newFee;

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
        List pending = _localMatchData['pendingPlayers'];
        pending.removeWhere((p) => (p is Map ? p['_id'] : p.toString()) == pId);
        
        if (isApprove) {
          _localMatchData['joinedPlayers'].add(player);
          _localMatchData['currentPlayers'] = (_localMatchData['currentPlayers'] ?? 1) + 1;
        }
        _wasModified = true; // Trigger refresh
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isApprove ? "Player Approved!" : "Request Rejected"), 
        backgroundColor: isApprove ? Colors.green : Colors.red
      ));
    }
    setState(() => _isProcessing = false);
  }

  // --- PLAYER: Request to Join ---
  void _requestJoin(bool isDark) {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login first.")));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Request to Join", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("You are requesting to join this match. The host will review your request.", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50, 
                  borderRadius: BorderRadius.circular(10), 
                  border: Border.all(color: isDark ? Colors.orange.withOpacity(0.3) : Colors.orange.shade200)
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: isDark ? Colors.orange.shade300 : Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Payment: You will need to hand over LKR cash to the match Organizer at the court.", 
                        style: TextStyle(color: isDark ? Colors.orange.shade300 : Colors.orange.shade900, fontSize: 12)
                      )
                    ),
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
                    _localMatchData['pendingPlayers'].add(currentUser);
                    _wasModified = true; // Trigger refresh
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = Provider.of<UserProvider>(context).user;
    final hostData = _localMatchData['hostId'];
    bool isHostObj = hostData is Map;
    String actualHostId = isHostObj ? hostData['_id'] : hostData.toString();
    bool isHost = currentUser != null && actualHostId == currentUser['_id'];
    
    String hostName = isHostObj ? hostData['name'] : "Community Organizer";
    String hostImage = AvatarConstants.avatarUrl(isHostObj ? hostData['profileImage']?.toString() : null);
    
    List<dynamic> images = _localMatchData['images'] ?? [];
    if (images.isEmpty && _localMatchData['image'] != null) {
      images = [_localMatchData['image']];
    }
    if (images.isEmpty) {
      images = ["https://placehold.co/300x200"];
    }

    int currentP = _localMatchData['currentPlayers'] ?? 1;
    int maxP = _localMatchData['maxPlayers'] ?? 4;
    double progress = currentP / maxP;
    if (progress > 1.0) progress = 1.0;

    List<dynamic> joinedPlayers = _localMatchData['joinedPlayers'] ?? [];
    List<dynamic> pendingPlayers = _localMatchData['pendingPlayers'] ?? [];
    bool hasAlreadyJoined = false;
    bool isPending = false;
    
    if (currentUser != null) {
      hasAlreadyJoined = joinedPlayers.any((p) => (p is Map ? p['_id'] : p.toString()) == currentUser['_id']);
      isPending = pendingPlayers.any((p) => (p is Map ? p['_id'] : p.toString()) == currentUser['_id']);
    }

    double feeValue = (_localMatchData['fee'] as num?)?.toDouble() ?? 0.0;
    String formattedFee = feeValue.toStringAsFixed(2);

    // NEW: Wrap the entire Scaffold in a PopScope to catch back-button presses
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        // When popping, send the `_wasModified` flag back to the parent so it knows to refresh!
        Navigator.pop(context, _wasModified);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250, 
                  pinned: true, 
                  backgroundColor: AppColors.primary, 
                  iconTheme: const IconThemeData(color: Colors.white),
                  
                  // NEW: Add a manual leading back button just in case
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context, _wasModified),
                  ),

                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Image.network(images[index].toString(), fit: BoxFit.cover);
                          },
                        ),
                        Container(color: Colors.black.withOpacity(0.4)),
                        if (images.length > 1)
                          Positioned(
                            bottom: 16, left: 0, right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(images.length, (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 8, height: 8,
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
                              )),
                            ),
                          )
                      ],
                    ),
                    title: Text(_localMatchData['title'] ?? "Match Details", style: const TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.w600, color: Colors.white)),
                    centerTitle: true,
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
                            _buildBadge(_localMatchData['sport'], AppColors.primary, isDark),
                            const SizedBox(width: 10),
                            _buildBadge(_localMatchData['skill'], Colors.orange, isDark),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        _buildInfoRow(Icons.stadium, "Court", _localMatchData['courtName'], context: context, isDark: isDark),
                        Divider(height: 30, color: isDark ? Colors.white10 : Colors.grey.shade200),
                        
                        _buildInfoRow(
                          Icons.location_on, 
                          "Location", 
                          _localMatchData['location'], 
                          context: context, 
                          isDark: isDark,
                          trailing: IconButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DirectionsMapScreen(court: _localMatchData))),
                            icon: Container(
                              padding: const EdgeInsets.all(8), 
                              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle), 
                              child: const Icon(Icons.directions, color: Colors.blue, size: 20)
                            ),
                          )
                        ),
                        
                        Divider(height: 30, color: isDark ? Colors.white10 : Colors.grey.shade200),
                        _buildInfoRow(Icons.calendar_month, "Date & Time", "${_localMatchData['date'] ?? 'Upcoming'} • ${_localMatchData['time']}", context: context, isDark: isDark),
                        Divider(height: 30, color: isDark ? Colors.white10 : Colors.grey.shade200),
                        
                        _buildInfoRow(
                          Icons.payments, 
                          "Hourly Fee Per Person", 
                          "LKR $formattedFee/hr (Pay Organizer)", 
                          color: AppColors.primary, 
                          context: context, 
                          isDark: isDark
                        ),
                        
                        const SizedBox(height: 40),

                        // Host: Pending Requests
                        if (isHost && pendingPlayers.isNotEmpty) ...[
                          Text("Pending Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.orange.shade300 : Colors.orange)),
                          const SizedBox(height: 12),
                          ...pendingPlayers.map((playerObj) {
                            Map player = playerObj is Map ? playerObj : {'name': 'Unknown Player'};
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50, 
                                borderRadius: BorderRadius.circular(12), 
                                border: Border.all(color: isDark ? Colors.orange.withOpacity(0.3) : Colors.orange.shade200)
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(radius: 16, backgroundImage: NetworkImage(AvatarConstants.avatarUrl(player['profileImage']?.toString()))),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(player['name'] ?? 'Player', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color))),
                                  IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: _isProcessing ? null : () => _handlePlayerRequest(player, false)),
                                  IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: _isProcessing ? null : () => _handlePlayerRequest(player, true)),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 24),
                        ],

                        // Joined Players UI
                        Text("Players Joined", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("$currentP / $maxP Players", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                            Text(currentP >= maxP ? "Full" : "${maxP - currentP} spots left", style: TextStyle(color: currentP >= maxP ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress, minHeight: 12, backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200, color: currentP >= maxP ? Colors.red : AppColors.primary,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        if (joinedPlayers.isNotEmpty)
                          SizedBox(
                            height: 45,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: joinedPlayers.length,
                              itemBuilder: (context, index) {
                                final player = joinedPlayers[index];
                                final String pImage = AvatarConstants.avatarUrl((player as Map?)?['profileImage']?.toString());
                                
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
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.grey.shade50, 
                            borderRadius: BorderRadius.circular(16), 
                            border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade200)
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(backgroundImage: NetworkImage(hostImage)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Hosted by", style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey, fontSize: 12)),
                                    Text(isHost ? "You" : hostName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
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
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor, 
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 20, offset: const Offset(0, -5))]
                ),
                child: isHost
                  ? ElevatedButton.icon(
                      onPressed: _showHostActionsDialog,
                      icon: const Icon(Icons.edit),
                      label: const Text("Manage Match", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    )
                  : ElevatedButton(
                      onPressed: (currentP >= maxP || hasAlreadyJoined || isPending) ? null : () => _requestJoin(isDark),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPending ? Colors.orange : AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: isDark ? Colors.white24 : Colors.grey.shade300,
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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, {Color? color, required BuildContext context, required bool isDark, Widget? trailing}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: (color ?? Colors.grey).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color ?? (isDark ? Colors.grey.shade400 : Colors.grey.shade700), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color ?? Theme.of(context).textTheme.bodyLarge?.color)),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(isDark ? 0.4 : 0.3))),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}