import 'package:flutter/material.dart'; 
import 'package:firebase_core/firebase_core.dart'; 
import 'package:provider/provider.dart'; 
import 'core/theme/app_theme.dart'; 
import 'features/auth/ui/screens/login_screen.dart'; 
import 'core/services/user_provider.dart'; 
import 'features/home/ui/main_wrapper.dart'; 
import 'features/admin_panel/ui/screens/court_owner_dashboard.dart'; 
import 'core/services/auth_service.dart'; 
import 'features/health/data/health_notifier.dart';  
import 'core/services/push_notification_service.dart'; // <-- ADD THIS IMPORT

void main() async {   
  WidgetsFlutterBinding.ensureInitialized();   
  await Firebase.initializeApp();    

  // Initialize Notifications! <-- ADD THIS LINE
  await PushNotificationService.initialize();

  // ADD THIS LINE to fetch and print the token:
  await PushNotificationService.getDeviceToken();

  runApp(     
    MultiProvider(       
      providers: [         
        ChangeNotifierProvider(create: (_) => UserProvider()),         
        ChangeNotifierProvider(create: (_) => HealthNotifier()),       
      ],       
      child: const CourtConnectApp(),     
    ),   
  ); 
}  

class CourtConnectApp extends StatelessWidget {   
  const CourtConnectApp({super.key});    
  
  @override   
  Widget build(BuildContext context) {     
    return ValueListenableBuilder<ThemeMode>(       
      valueListenable: themeNotifier,       
      builder: (context, currentMode, _) {         
        return MaterialApp(           
          title: 'Court Connect',           
          debugShowCheckedModeBanner: false,           
          theme: AppTheme.lightTheme,           
          darkTheme: AppTheme.darkTheme,           
          themeMode: currentMode,           
          home: const AuthWrapper(),         
        );       
      },     
    );   
  } 
}  

class AuthWrapper extends StatefulWidget {   
  const AuthWrapper({super.key});    
  
  @override   
  State<AuthWrapper> createState() => _AuthWrapperState(); 
}  

class _AuthWrapperState extends State<AuthWrapper> {   
  bool _isLoading = true;   
  Widget? _startScreen;    
  
  @override   
  void initState() {     
    super.initState();     
    _determineStartScreen();   
  }    
  
  Future<void> _determineStartScreen() async {     
    final user = AuthService().currentUser;      
    
    if (user == null) {       
      setState(() {         
        _startScreen = const LoginScreen();         
        _isLoading = false;       
      });       
      return;     
    }      
    
    // User is logged in, fetch profile to check Role     
    final userProvider = Provider.of<UserProvider>(context, listen: false);     
    await userProvider.loadUser(); // Fetch from MongoDB      
    
    final userData = userProvider.user;      
    
    setState(() {       
      if (userData != null && userData['role'] == 'court_owner') {         
        _startScreen = const CourtOwnerDashboard();       
      } else {         
        _startScreen = const MainWrapper(); // Default to Player       
      }       
      _isLoading = false;     
    });   
  }    
  
  @override   
  Widget build(BuildContext context) {     
    if (_isLoading) {       
      return const Scaffold(body: Center(child: CircularProgressIndicator()));     
    }     
    return _startScreen!;   
  } 
}
