import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

// Note: In a real environment, you would use a package like 'url_launcher' 
// to open the PDF or 'universal_html' for web downloads.

void main() {
  runApp(const KoalaWorkspaceApp());
}

class KoalaWorkspaceApp extends StatelessWidget {
  const KoalaWorkspaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Koala Workspace',
        theme: ThemeData(
            primaryColor: const Color(0xFF1E2A38),
            scaffoldBackgroundColor: Colors.white,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF0F4F8), // Lighter grey for inputs
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              hintStyle: TextStyle(color: Colors.grey[600]),
            ),
            textButtonTheme: TextButtonThemeData(
              style:
                  TextButton.styleFrom(foregroundColor: const Color(0xFF1E2A38)),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
                // Added default button style
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2A38),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    textStyle:
                        const TextStyle(fontWeight: FontWeight.bold)))),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen());
  }
}

// --------------------------------------------------
// SPLASH SCREEN
// --------------------------------------------------

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('loggedIn') ?? false;

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return; // Check if the widget is still in the tree
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) =>
              loggedIn ? const DashboardPage() : const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1E2A38),
      body: Center(
        child: Text(
          "Koala Workspace",
          style: TextStyle(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// REGISTER PAGE
// --------------------------------------------------

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', _email.text.trim());
      await prefs.setString('password', _password.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Registered Successfully 🎉"),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Register",
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(hintText: "Email"),
                validator: (value) => value!.isEmpty
                    ? "Enter an email"
                    : (!value.contains('@') ? "Enter a valid email" : null),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(hintText: "Password"),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? "Minimum 6 characters" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------
// LOGIN PAGE
// --------------------------------------------------

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');

    if (_formKey.currentState!.validate()) {
      if (_email.text == savedEmail && _password.text == savedPassword) {
        await prefs.setBool('loggedIn', true);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Login Successful 🎉"),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const DashboardPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid credentials ❌")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Login",
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(hintText: "Email"),
                validator: (v) => v!.isEmpty ? "Enter your email" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(hintText: "Password"),
                obscureText: true,
                validator: (v) => v!.isEmpty ? "Enter your password" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text("Login"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage()));
                },
                child: const Text("Forgot Password?"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------
// FORGOT PASSWORD PAGE
// --------------------------------------------------

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const ResetPasswordPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Forgot Password",
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(hintText: "Enter your email"),
                validator: (v) => v!.isEmpty ? "Please enter your email" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------
// RESET PASSWORD PAGE
// --------------------------------------------------

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  Future<void> _reset() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('password', _newPassword.text);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Password Reset Successful 🔑"),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Reset Password",
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _newPassword,
                decoration: const InputDecoration(hintText: "New Password"),
                obscureText: true,
                validator: (v) => v!.length < 6 ? "Minimum 6 characters" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _confirmPassword,
                decoration: const InputDecoration(hintText: "Confirm Password"),
                obscureText: true,
                validator: (v) =>
                    v != _newPassword.text ? "Passwords don’t match" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _reset,
                child: const Text("Reset Password"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------
// DASHBOARD + SIDEBAR WITH APPBAR + LOGOUT
// --------------------------------------------------

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  
  int _selectedIndex = 0; // Start on Dashboard

  final List<String> _menuItems = [
    "Dashboard",
    "Staff & Role Management",
    "Clients & Workspace",
    "Tasks & Workflows",
    "Finance",
    "Inventory",
    "Announcements", // Index 6
    "Settings", // Index 7
  ];

  // **FIX 1: List Mismatch** - Added one icon (Icons.campaign_rounded)
  final List<IconData> _menuIcons = [
    Icons.dashboard_rounded,
    Icons.people_alt_rounded,
    Icons.business_center_rounded,
    Icons.task_alt_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.inventory_2_rounded, // Changed from analytics to a suitable inventory icon
    Icons.campaign_rounded, // <-- ADDED for Announcements
    Icons.settings_rounded,
  ];

  // The list length is correct (8 items)
  final List<Widget> _pages = [
    const DashboardHomePage(),
    const StaffPage(),
    const ClientsPage(), 
    const TaskManagementPage(),
    const FinancePage(),
    const InventoryPage(),
    const AnnouncementsPage(),
    const SettingsPage(),
  ];

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', false);
    if (!mounted) return;
    // Assuming LoginPage is defined elsewhere, included a placeholder below
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Future<void> _registerAgain() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', false);
    if (!mounted) return;
    // Assuming RegisterPage is defined elsewhere, included a placeholder below
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const RegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ------------------ SIDEBAR ------------------
          Container(
            width: 240,
            color: const Color(0xFF1E2A38),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  "Manager CRM", 
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Navigation items (now 8 items and 8 icons)
                for (int i = 0; i < _menuItems.length; i++)
                  SidebarItem(
                    title: _menuItems[i],
                    icon: _menuIcons[i], 
                    selected: _selectedIndex == i,
                    onTap: () => setState(() => _selectedIndex = i),
                  ),

                const Divider(color: Colors.white54, height: 30),

                // Sign Out and Register Again options
                SidebarItem(
                  title: "Sign Out",
                  icon: Icons.logout_rounded, 
                  selected: false,
                  onTap: _logout,
                ),
                SidebarItem(
                  title: "Register Again",
                  icon: Icons.app_registration_rounded,
                  selected: false,
                  onTap: _registerAgain,
                ),
              ],
            ),
          ),

          // ------------------ MAIN CONTENT ------------------
          Expanded(
            child: Column(
              children: [
                // APP BAR
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      color: Colors.white, 
                      border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!))),
                  child: Text(
                    _menuItems[_selectedIndex],
                    style: const TextStyle(
                      color: Color(0xFF1E2A38), 
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // PAGE CONTENT
                Expanded(
                  child: Container(
                    color: Colors.grey[100], 
                    child: _pages[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// SIDEBAR ITEM WIDGET
// --------------------------------------------------
class SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon; 
  final bool selected;
  final VoidCallback onTap;

  const SidebarItem(
      {super.key,
      required this.title,
      required this.icon, 
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4), 
      decoration: BoxDecoration(
        color: selected ? Colors.white24 : Colors.transparent,
        borderRadius: BorderRadius.circular(8), 
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(title,
            style: TextStyle(
                color: Colors.white,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        hoverColor: Colors.white12, 
      ),
    );
  }
}

// --------------------------------------------------
// SEPARATE PAGE PLACEHOLDER CLASSES (REQUIRED FOR CODE TO RUN)
// --------------------------------------------------
class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  "Dashboard",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2A38)),
                ),
                const SizedBox(height: 20),

                // Profile Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3))
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: Color(0xFF1E2A38),
                        child: Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("John Doe",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          Text("Role: Manager",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Metrics Cards (Responsive Row)
                Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricCard(
                        "Total Active Clients", "2", Colors.blueAccent),
                    if (isWide) const SizedBox(width: 20) else const SizedBox(height: 15),
                    _buildMetricCard("New Clients Today", "2", Colors.teal),
                    if (isWide) const SizedBox(width: 20) else const SizedBox(height: 15),
                    _buildMetricCard("Total Revenue (Month)", "2000000", Colors.redAccent),
                  ],
                ),
                const SizedBox(height: 20),

                // Graph + Calendar Section
                Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Graph
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 250,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Workspace Overview",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E2A38))),
                            const SizedBox(height: 15),
                            Expanded(
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(show: true),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: true)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, _) {
                                          const months = [
                                            "Jan",
                                            "Feb",
                                            "Mar",
                                            "Apr",
                                            "May",
                                            "Jun",
                                            "Jul",
                                            "Aug"
                                          ];
                                          if (value.toInt() >= 0 &&
                                              value.toInt() < months.length) {
                                            return Text(
                                              months[value.toInt()],
                                              style:
                                                  const TextStyle(fontSize: 10),
                                            );
                                          }
                                          return const Text("");
                                        },
                                      ),
                                    ),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(
                                        8,
                                        (index) => FlSpot(
                                            index.toDouble(),
                                            (Random().nextDouble() * 30)
                                                .roundToDouble()),
                                      ),
                                      isCurved: true,
                                      color: Colors.blueAccent,
                                      barWidth: 3,
                                      belowBarData: BarAreaData(
                                          show: true,
                                          color: Colors.blueAccent
                                              .withOpacity(0.2)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isWide) const SizedBox(width: 20) else const SizedBox(height: 20),
                    // Calendar
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Calendar",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E2A38))),
                            const SizedBox(height: 10),
                            TableCalendar(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: DateTime.now(),
                              headerVisible: false,
                              daysOfWeekVisible: true,
                              calendarStyle: const CalendarStyle(
                                todayDecoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    shape: BoxShape.circle),
                                selectedDecoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.circle,
                                    size: 10, color: Colors.redAccent),
                                SizedBox(width: 5),
                                Text("Deadline"),
                                SizedBox(width: 15),
                                Icon(Icons.circle,
                                    size: 10, color: Colors.blueAccent),
                                SizedBox(width: 5),
                                Text("Meeting"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Task Alerts
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3))
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Task Alerts",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E2A38))),
                      SizedBox(height: 10),
                      ListTile(
                        leading: Icon(Icons.circle_outlined),
                        title: Text("Deadline Missed: Project A"),
                      ),
                      ListTile(
                        leading: Icon(Icons.circle_outlined),
                        title: Text("Unusual Client Activity Detected"),
                      ),
                      ListTile(
                        leading: Icon(Icons.circle_outlined),
                        title: Text("New User Registered"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for metric cards
  Widget _buildMetricCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}



// --------------------------------------------------
// STAFF & ROLE MANAGEMENT PAGE (Updated)
// --------------------------------------------------

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  List<Map<String, dynamic>> staffList = [
    {
      'name': 'Prachi',
      'email': 'prachi@gmail.com',
      'role': 'Staff',
      'permissions': {
        'staff': true,
        'clients': true,
        'tasks': true,
        'reports': false,
        'finance': false
      },
      'status': 'Present'
    },
    {
      'name': 'Rahul',
      'email': 'rahul@gmail.com',
      'role': 'Manager',
      'permissions': {
        'staff': true,
        'clients': true,
        'tasks': true,
        'reports': true,
        'finance': true
      },
      'status': 'Absent'
    },
  ];

  String searchQuery = '';
  String filter = 'All';
  DateTime selectedDate = DateTime.now();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  Map<String, bool> tempPermissions = {
    'staff': false,
    'clients': false,
    'tasks': false,
    'reports': false,
    'finance': false,
  };

  // ✅ OPEN ADD/EDIT DIALOG
  void _openUserDialog({Map<String, dynamic>? user, int? index}) {
    setState(() {
      if (user != null) {
        nameController.text = user['name'];
        emailController.text = user['email'];
        roleController.text = user['role'];
        tempPermissions = Map<String, bool>.from(user['permissions']);
      } else {
        nameController.clear();
        emailController.clear();
        roleController.clear();
        tempPermissions = {
          'staff': false,
          'clients': false,
          'tasks': false,
          'reports': false,
          'finance': false
        };
      }
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: const Text(
                "Add New User",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: "Name",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              labelText: "Phone",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: roleController,
                            decoration: const InputDecoration(
                              labelText: "Role",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 15),
                      const Text(
                        "Permissions",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          CheckboxListTile(
                            title: const Text("Manages Staff"),
                            value: tempPermissions['staff'],
                            onChanged: (v) {
                              setStateDialog(() =>
                                  tempPermissions['staff'] = v ?? false);
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Manages Clients"),
                            value: tempPermissions['clients'],
                            onChanged: (v) {
                              setStateDialog(() =>
                                  tempPermissions['clients'] = v ?? false);
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Manages Tasks"),
                            value: tempPermissions['tasks'],
                            onChanged: (v) {
                              setStateDialog(() =>
                                  tempPermissions['tasks'] = v ?? false);
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Access Reports"),
                            value: tempPermissions['reports'],
                            onChanged: (v) {
                              setStateDialog(() =>
                                  tempPermissions['reports'] = v ?? false);
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Manages Finance"),
                            value: tempPermissions['finance'],
                            onChanged: (v) {
                              setStateDialog(() =>
                                  tempPermissions['finance'] = v ?? false);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newUser = {
                      'name': nameController.text,
                      'email': emailController.text,
                      'role': roleController.text,
                      'permissions': Map.from(tempPermissions),
                      'status': 'Present',
                    };
                    setState(() {
                      if (index != null) {
                        staffList[index] = newUser;
                      } else {
                        staffList.add(newUser);
                      }
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ FILTERED STAFF
  List<Map<String, dynamic>> get filteredStaff {
    return staffList.where((staff) {
      final matchesSearch = staff['name']
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          staff['email'].toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter =
          filter == 'All' || staff['status'].toString() == filter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalUsers = staffList.length;
    final roles = staffList.map((s) => s['role']).toSet().join(', ');
    final dateString = DateFormat('MM/dd/yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT SIDE
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardStyle(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Staff & Role Management",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22)),
                        ElevatedButton.icon(
                          onPressed: () => _openUserDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text("New User"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Search bar
                    TextField(
                      onChanged: (v) => setState(() => searchQuery = v),
                      decoration: const InputDecoration(
                        hintText: "Search",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("NAME")),
                            DataColumn(label: Text("EMAIL")),
                            DataColumn(label: Text("ROLE")),
                            DataColumn(label: Text("EDIT")),
                            DataColumn(label: Text("DELETE")),
                          ],
                          rows: filteredStaff.map((staff) {
                            final index = staffList.indexOf(staff);
                            return DataRow(cells: [
                              DataCell(Text(staff['name'])),
                              DataCell(Text(staff['email'])),
                              DataCell(Text(staff['role'])),
                              DataCell(
                                TextButton(
                                  onPressed: () =>
                                      _openUserDialog(user: staff, index: index),
                                  child: const Text("Edit"),
                                ),
                              ),
                              DataCell(
                                TextButton(
                                  onPressed: () => setState(
                                      () => staffList.removeAt(index)),
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            // RIGHT SIDE
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // TEAM SUMMARY
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardStyle(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Team Summary",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        Text("Total Users: $totalUsers"),
                        Text("Roles: $roles"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ATTENDANCE
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardStyle(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Attendance",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Select Date:"),
                            TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setState(() => selectedDate = picked);
                                }
                              },
                              child: Text(dateString),
                            ),
                          ],
                        ),
                        DropdownButton<String>(
                          value: filter,
                          items: ['All', 'Present', 'Absent']
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => filter = val!),
                        ),
                        const Divider(),
                        const Text("NAME - STATUS",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        ...filteredStaff.map((s) => Text(
                            "${s['name']} - ${s['status']}",
                            style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardStyle() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 2)
        ],
      );
}


// ==================================================
// DATA MODELS (Unchanged)
// ==================================================

class Client {
  String name;
  String email;
  String phone;
  String status;
  String location;
  String designer;
  String membership;

  Client({
    required this.name,
    required this.email,
    required this.phone,
    this.status = "Active",
    this.location = "N/A",
    this.designer = "N/A",
    this.membership = "N/A",
  });
}

class Reservation {
  String type;
  String clientName;
  DateTime when;
  String? deskId;
  bool isCleaned;

  Reservation({
    required this.type,
    required this.clientName,
    required this.when,
    this.deskId,
    this.isCleaned = false,
  });
}

// ==================================================
// MAIN WIDGET STRUCTURE: CLIENTS PAGE
// ==================================================

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  
  // --- STATE (Mock Data) ---
  final List<Client> _clients = [
    Client(
        name: "Prachi Sharma",
        email: "prachi@gmail.com",
        phone: "+91 98765 43210",
        location: "Pune, India",
        designer: "XYZ Ltd",
        membership: "6 months"),
  ];

  final Map<String, int> _availableResources = {
    "Hot Desk": 15,
    "Individual Pod": 14,
    "Board Room": 3,
    "Meeting Room": 3,
    "Private Room": 10,
  };

  final List<Reservation> _reservations = [
    Reservation(
        type: "Individual Pod",
        deskId: "IP-1",
        clientName: "Prachi Sharma",
        when: DateTime(2025, 10, 29, 0, 0),
        isCleaned: true),
  ];

  Client? _selectedClient;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedResourceType;
  String? _selectedClientName;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    if (_clients.isNotEmpty) {
      _selectedClient = _clients.first;
      _selectedClientName = _clients.first.name;
    }
    _selectedResourceType = _availableResources.keys.first;
  }
  
  // --- HANDLERS (Omitted for brevity) ---
  // ... (Dialog, Delete, PickDateTime, AddReservation, CancelReservation methods remain unchanged)
  
  void _showAddClientDialog({Client? client, int? index}) {
    final nameController = TextEditingController(text: client?.name ?? '');
    final emailController = TextEditingController(text: client?.email ?? '');
    final phoneController = TextEditingController(text: client?.phone ?? '');
    final locationController = TextEditingController(text: client?.location ?? 'N/A');
    final designerController = TextEditingController(text: client?.designer ?? 'N/A');
    final membershipController = TextEditingController(text: client?.membership ?? 'N/A');

    void saveClient() {
      final newClient = Client(
          name: nameController.text,
          email: emailController.text,
          phone: phoneController.text,
          status: client?.status ?? "Active",
          location: locationController.text,
          designer: designerController.text,
          membership: membershipController.text);
      setState(() {
        if (client == null) {
          _clients.add(newClient);
          _selectedClient = newClient;
          _selectedClientName = newClient.name;
        } else {
          _clients[index!] = newClient;
          _selectedClient = newClient;
          _selectedClientName = newClient.name;
        }
      });
      Navigator.pop(context);
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(client == null ? "Add New Client" : "Edit Client"),
        content: SizedBox(
          width: 350,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 12),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(height: 12),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
                const SizedBox(height: 12),
                TextField(controller: designerController, decoration: const InputDecoration(labelText: 'Designer Role')),
                const SizedBox(height: 12),
                TextField(controller: membershipController, decoration: const InputDecoration(labelText: 'Membership')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: saveClient, child: const Text('Save')),
        ],
      ),
    );
  }

  void _deleteClient(Client client) {
    setState(() {
      _clients.remove(client);
      if (_selectedClient == client) {
        _selectedClient = _clients.isNotEmpty ? _clients.first : null;
        _selectedClientName = _selectedClient?.name;
      }
    });
  }

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _addReservation() {
    if (_selectedResourceType == null ||
        _selectedClientName == null ||
        _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select a resource, client, and date/time.")),
      );
      return;
    }

    String? deskId;
    if (_selectedResourceType == 'Individual Pod') {
      final existingPods =
          _reservations.where((r) => r.type == 'Individual Pod').length;
      final podNumber = existingPods + 1;
      deskId = 'IP-$podNumber';
      if (_availableResources['Individual Pod']! <= existingPods) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Individual Pods are fully booked.")),
        );
        return;
      }
    }

    if (_availableResources.containsKey(_selectedResourceType)) {
      _availableResources[_selectedResourceType!] =
          _availableResources[_selectedResourceType]! - 1;
    }

    final newReservation = Reservation(
      type: _selectedResourceType!,
      deskId: deskId,
      clientName: _selectedClientName!,
      when: _selectedDateTime!,
    );

    setState(() {
      _reservations.add(newReservation);
      _selectedDateTime = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Reserved ${newReservation.type} for ${_selectedClientName!}")),
      );
    });
  }

  void _cancelReservation(Reservation res) {
    setState(() {
      _reservations.remove(res);
      if (_availableResources.containsKey(res.type)) {
        _availableResources[res.type] = _availableResources[res.type]! + 1;
      }
    });
  }

  // --- BUILD METHODS ---

  // ... (ClientsPage class definition and state)

// --- BUILD METHODS ---

@override
Widget build(BuildContext context) {
  List<Client> filteredClients = _clients
      .where((client) => client.name
          .toLowerCase()
          .contains(_searchController.text.toLowerCase()))
      .toList();

  return Scaffold(
    backgroundColor: Colors.grey[100],
    body: LayoutBuilder(
      builder: (context, constraints) {
        // Constraints here are the width provided by the parent SizedBox in MyApp.
        bool isTwoColumn = constraints.maxWidth > 800;

        Widget content;
        if (isTwoColumn) {
          // The Two-Column Row layout (where the overflow bug occurs)
          content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildClientsCard(filteredClients),
                      const SizedBox(height: 20),
                      _buildReservationCard(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 20),
                      _buildHistoryCard(),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          // The Single-Column layout
          content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClientsCard(filteredClients),
                const SizedBox(height: 20),
                _buildReservationCard(),
                const SizedBox(height: 20),
                _buildProfileCard(),
                const SizedBox(height: 20),
                _buildHistoryCard(),
              ],
          );
        }

      
        return SingleChildScrollView( // <-- Vertical Scroll
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: isTwoColumn
                ? SingleChildScrollView( // <-- Horizontal Scroll Protection
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      // We use constraints.maxWidth, which is the exact width 
                      // calculated by the LayoutBuilder in MyApp (Screen Width - 250).
                      // This ensures the content Row is exactly the size it should be.
                      width: constraints.maxWidth - 30, // Subtract 2 * 15.0 padding
                      child: content,
                    ),
                  )
                : content, // Single-column layout content
          ),
        );
      },
    ),
  );
}
  // --------------------------------------------------
  // WIDGET BUILDERS (Remain largely unchanged from final successful version)
  // --------------------------------------------------

  Widget _buildClientsCard(List<Client> filteredClients) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Clients",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              SizedBox(
                width: 150,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: "Search by name",
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: () => _showAddClientDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 8,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 40,
                columns: const [
                  DataColumn(label: Text("NAME")),
                  DataColumn(label: Text("EMAIL")),
                  DataColumn(label: Text("PHONE")),
                  DataColumn(label: Text("ACTION")),
                ],
                rows: filteredClients.asMap().entries.map((entry) {
                  Client client = entry.value;
                  return DataRow(cells: [
                    DataCell(Text(client.name)),
                    DataCell(Text(client.email)),
                    DataCell(Text(client.phone)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedClient = client;
                              });
                            },
                            child: const Text("View",
                                style: TextStyle(color: Colors.blue)),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              int actualIndex = _clients.indexOf(client);
                              _showAddClientDialog(
                                  client: client, index: actualIndex);
                            },
                            child: const Text("Edit",
                                style: TextStyle(color: Colors.orange)),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _deleteClient(client),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 0),
                                minimumSize: const Size(0, 25)),
                            child: const Text("Delete",
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard() {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Room & Desk Reservation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Reserve resources",
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          
          LayoutBuilder(
            builder: (context, constraints) {
              bool useCompactLayout = constraints.maxWidth < 600;

              final resourceDropdown = DropdownButtonFormField<String>(
                initialValue: _selectedResourceType,
                isDense: true,
                decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    border: OutlineInputBorder()),
                items: _availableResources.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text("${entry.key} (${entry.value} available)"),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedResourceType = newValue;
                  });
                },
              );

              final clientDropdown = DropdownButtonFormField<String>(
                initialValue: _selectedClientName,
                isDense: true,
                decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    border: OutlineInputBorder()),
                items: _clients.map((client) {
                  return DropdownMenuItem(
                    value: client.name,
                    child: Text(client.name),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedClientName = newValue;
                  });
                },
              );

              final datePickerButton = OutlinedButton(
                onPressed: _pickDateTime,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  alignment: Alignment.centerLeft,
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: Text(
                  _selectedDateTime == null
                      ? "Pick date & time"
                      : "${_selectedDateTime!.month}/${_selectedDateTime!.day}/${_selectedDateTime!.year}",
                  style: TextStyle(
                      color: _selectedDateTime == null
                          ? Colors.grey[600]
                          : Theme.of(context).primaryColor,
                      fontSize: 13),
                ),
              );

              final reserveButton = ElevatedButton(
                onPressed: _addReservation,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text("Reserve", style: TextStyle(fontSize: 12)),
              );


              if (useCompactLayout) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    resourceDropdown,
                    const SizedBox(height: 10),
                    clientDropdown,
                    const SizedBox(height: 10),
                    datePickerButton,
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: reserveButton,
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(flex: 2, child: resourceDropdown),
                    const SizedBox(width: 10),
                    Expanded(flex: 2, child: clientDropdown),
                    const SizedBox(width: 10),
                    Expanded(flex: 1, child: datePickerButton),
                    const SizedBox(width: 10),
                    reserveButton,
                  ],
                );
              }
            },
          ),
          
          const SizedBox(height: 10),
          // Reservation Table
          SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 10,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 40,
                columns: const [
                  DataColumn(label: Text("Type")),
                  DataColumn(label: Text("Desk ID")),
                  DataColumn(label: Text("Client")),
                  DataColumn(label: Text("When")),
                  DataColumn(label: Text("Action")),
                ],
                rows: _reservations.map((res) {
                  return DataRow(cells: [
                    DataCell(Text(res.type)),
                    DataCell(Text(res.deskId ?? 'N/A')),
                    DataCell(Text(res.clientName)),
                    DataCell(Text(
                        "${res.when.month}/${res.when.day}/${res.when.year}, ${res.when.hour.toString().padLeft(2, '0')}:${res.when.minute.toString().padLeft(2, '0')} ${res.when.hour >= 12 ? 'PM' : 'AM'}")),
                    DataCell(TextButton(
                      onPressed: () => _cancelReservation(res),
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: const Size(50, 20)),
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.red, fontSize: 13)),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- Profile Card, History Card, Info Card and Root Widgets (Omitted for brevity) ---

  Widget _buildProfileCard() {
    if (_selectedClient == null) {
      return _InfoCard(child: const Text("No client selected."));
    }

    final client = _selectedClient!;

    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Client Profile & Contract",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(client.name,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(client.email,
              style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(client.phone,
              style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          const SizedBox(height: 10),
          Text("Location: ${client.location}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text("Designer Role: ${client.designer}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text("Membership: ${client.membership}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),
          Text("Contract: Contract_XYZ_Ltd.pdf",
              style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    return _InfoCard(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("History",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._reservations.map((res) => _historyItem(
              "${res.when.month}/${res.when.day}/${res.when.year}, ${res.when.hour.toString().padLeft(2, '0')}:${res.when.minute.toString().padLeft(2, '0')} ${res.when.hour >= 12 ? 'PM' : 'AM'}",
              "Reserved ${res.type}${res.deskId != null ? ' (${res.deskId})' : ''}",
            )),
        _historyItem("10/25/2025, 1:33:21 PM", "— Account created"),
        _historyItem("9/25/2025, 1:33:21 PM", "— Membership updated"),
      ],
    ));
  }

  Widget _historyItem(String date, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(action, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// REUSABLE CARD WIDGET
// --------------------------------------------------

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2))
          ]),
      child: child,
    );
  }
}

// --------------------------------------------------
// ROOT WIDGET
// --------------------------------------------------
// ... imports and previous code ...

// --------------------------------------------------
// ROOT WIDGET
// --------------------------------------------------


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // Define the fixed sidebar width once
  static const double sidebarWidth = 250.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clients & Workspaces UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      // Use LayoutBuilder on the root Scaffold body
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate the exact width available for the main content
            final double mainContentWidth = constraints.maxWidth - sidebarWidth;

            return Row(
              children: [
                // Mock Sidebar (Fixed Width)
                const SizedBox(
                  width: sidebarWidth, // 250.0
                  height: double.infinity,
                  child: ColoredBox(
                    color: Color(0xFF1E2A38),
                    child: Center(
                      child: Text("Navigation", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                // Main content area (Manually Calculated Width)
                SizedBox(
                  width: mainContentWidth, 
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0),
                        child: Text("Clients & Workspaces",
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                      // ClientsPage now receives a constrained width via the SizedBox
                      Expanded(child: ClientsPage()),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


 

// --------------------------------------------------
// OTHER PLACEHOLDER PAGES
// --------------------------------------------------

// --- DATA MODELS ---
// Neutral dark gray for the accent color (used for buttons, active states, drag borders)


// --- CONSTANTS & DATA MODELS ---

const Color accentColor = Color(0xFF1F2937); // Deep Slate Gray
const Color primaryTextColor = Color(0xFF374151); // Dark Gray
const Color secondaryTextColor = Color(0xFF6B7280); // Medium Gray
const Color backgroundWhite = Colors.white; 
const Color columnBackground = Color(0xFFF3F4F6); // Very light gray for columns

enum TaskStatus { toAssign, assigned, completed }
enum TaskPriority { high, medium, low }

final List<String> availableStaff = ['Staff A', 'Staff B', 'Staff C', 'Staff D'];

class Task {
  final String id;
  String name;
  String description;
  String? staff;
  TaskPriority priority;
  DateTime deadline;
  TaskStatus status;

  Task({
    required this.id,
    required this.name,
    this.description = 'No description provided.',
    this.staff,
    required this.priority,
    required this.deadline,
    this.status = TaskStatus.toAssign,
  });

  String get statusText {
    switch (status) {
      case TaskStatus.toAssign: return 'Pending';
      case TaskStatus.assigned: return 'In Progress';
      case TaskStatus.completed: return 'Completed';
    }
  }
}

// --- HELPER WIDGETS ---

// 1. Task Card (Draggable Item)
class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high: return Colors.red.shade600;
      case TaskPriority.medium: return Colors.orange.shade600;
      case TaskPriority.low: return Colors.green.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: task.id,
      feedback: Card(
        color: backgroundWhite,
        elevation: 12,
        child: SizedBox(
          width: 280, 
          child: _buildCardContent(context, isDragging: true)
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: _buildCardContent(context)),
      child: _buildCardContent(context),
    );
  }
  
  Widget _buildCardContent(BuildContext context, {bool isDragging = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: isDragging ? 0 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task.priority.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      color: _getPriorityColor(task.priority),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                Text(
                  'ID: ${task.id}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task.name,
              style: TextStyle(
                fontSize: 17, 
                fontWeight: FontWeight.w700,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            // Deadline
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: secondaryTextColor),
                const SizedBox(width: 8),
                Text(
                  'Due: ${DateFormat('MMM dd, yyyy').format(task.deadline)}',
                  style: TextStyle(fontSize: 13, color: secondaryTextColor),
                ),
              ],
            ),
            if (task.staff != null) ...[
              const SizedBox(height: 8),
              // Assigned Staff
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: secondaryTextColor),
                  const SizedBox(width: 8),
                  Text(
                    'Assigned to: ${task.staff}',
                    style: TextStyle(fontSize: 13, color: secondaryTextColor),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 2. Task Column (Drag Target)
class TaskColumn extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final TaskStatus targetStatus;
  final Function(String taskId, TaskStatus newStatus) onTaskDrop;

  const TaskColumn({
    super.key,
    required this.title,
    required this.tasks,
    required this.targetStatus,
    required this.onTaskDrop,
  });

  Color _getHeaderAccentColor() {
    switch (targetStatus) {
      case TaskStatus.toAssign: return Colors.blue.shade700;
      case TaskStatus.assigned: return Colors.amber.shade700;
      case TaskStatus.completed: return Colors.green.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (DragTargetDetails<String> details) {
        onTaskDrop(details.data, targetStatus);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: columnBackground,
            borderRadius: BorderRadius.circular(15),
            border: candidateData.isNotEmpty
                ? Border.all(color: accentColor, width: 3)
                : Border.all(color: Colors.transparent, width: 0),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 10.0, left: 16.0, right: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$title (${tasks.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      height: 3,
                      width: 50,
                      decoration: BoxDecoration(
                        color: _getHeaderAccentColor(),
                        borderRadius: BorderRadius.circular(5),
                      )
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(task: tasks[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 3. Create Task Modal (Dialog)
class CreateTaskModal extends StatefulWidget {
  final List<String> availableStaff;
  final Function(Task task) onCreate;

  const CreateTaskModal({
    super.key,
    required this.availableStaff,
    required this.onCreate,
  });

  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  final _formKey = GlobalKey<FormState>();
  String _taskName = '';
  String _taskDescription = '';
  String? _selectedStaff;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Create New Task', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Task Name', border: OutlineInputBorder()),
                onSaved: (value) => _taskName = value ?? '',
                validator: (value) => value!.isEmpty ? 'Please enter a task name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()),
                maxLines: 3,
                onSaved: (value) => _taskDescription = value ?? '',
              ),
              const SizedBox(height: 16),
              
              // Priority Dropdown
              DropdownButtonFormField<TaskPriority>(
                decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                initialValue: _selectedPriority,
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (TaskPriority? newValue) {
                  setState(() => _selectedPriority = newValue!);
                },
              ),
              const SizedBox(height: 16),


              // Staff Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Assign Staff (Optional)', border: OutlineInputBorder()),
                initialValue: _selectedStaff,
                hint: const Text('Select Staff'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Unassigned')),
                  ...widget.availableStaff.map((staff) {
                    return DropdownMenuItem(value: staff, child: Text(staff));
                  }),
                ],
                onChanged: (String? newValue) {
                  setState(() => _selectedStaff = newValue);
                },
              ),
              const SizedBox(height: 16),


              // Deadline Picker
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  title: Text("Deadline: ${DateFormat('MMM dd, yyyy').format(_selectedDeadline)}"),
                  trailing: const Icon(Icons.calendar_today, color: accentColor),
                  onTap: _pickDeadline,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel', style: TextStyle(color: secondaryTextColor)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          onPressed: _submitForm,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _pickDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final initialStatus = _selectedStaff == null ? TaskStatus.toAssign : TaskStatus.assigned;
      
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _taskName,
        description: _taskDescription,
        staff: _selectedStaff,
        priority: _selectedPriority,
        deadline: _selectedDeadline,
        status: initialStatus,
      );
      widget.onCreate(newTask);
    }
  }
}

// --- TASK MANAGEMENT PAGE WIDGET (STATEFUL ROOT) ---

class TaskManagementPage extends StatefulWidget {
  const TaskManagementPage({super.key});

  @override
  State<TaskManagementPage> createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  // --- STATE ---
  final List<Task> _tasks = [
    Task(id: '1', name: 'Prepare Q3 Financial Report', staff: null, priority: TaskPriority.high, deadline: DateTime.now().add(const Duration(days: 18))),
    Task(id: '2', name: 'Setup Client Onboarding Meeting', staff: 'Staff A', priority: TaskPriority.medium, deadline: DateTime.now().add(const Duration(days: 19)), status: TaskStatus.assigned),
    Task(id: '3', name: 'Organize workspace B files', staff: 'Staff B', priority: TaskPriority.low, deadline: DateTime.now().add(const Duration(days: 21)), status: TaskStatus.assigned),
    Task(id: '4', name: 'Finalize July Billing Report', staff: 'Staff C', priority: TaskPriority.high, deadline: DateTime.now().subtract(const Duration(days: 5)), status: TaskStatus.completed),
    Task(id: '5', name: 'Review new vendor contracts', staff: null, priority: TaskPriority.high, deadline: DateTime.now().add(const Duration(days: 1))),
    Task(id: '6', name: 'Draft marketing copy for feature X', staff: 'Staff D', priority: TaskPriority.medium, deadline: DateTime.now().add(const Duration(days: 5)), status: TaskStatus.assigned),
  ];

  String _selectedTab = 'Total Tasks';
  
  // All filters, including the working search query
  String _searchQuery = ''; 
  String? _filterStaff;
  TaskPriority? _filterPriority;
  DateTime? _filterDeadline;
  
  // --- LOGIC / DATA ACCESS ---

  // Filters the task list based on all active criteria
  List<Task> _getFilteredTasks(TaskStatus status) {
    final query = _searchQuery.toLowerCase();

    return _tasks.where((task) {
      bool statusMatch = task.status == status;
      bool staffMatch = _filterStaff == null || task.staff == _filterStaff;
      bool priorityMatch = _filterPriority == null || task.priority == _filterPriority;
      bool deadlineMatch = _filterDeadline == null || task.deadline.isBefore(_filterDeadline!.add(const Duration(days: 1)));
      
      // Search Query Match (checks task name or staff name)
      bool searchMatch = query.isEmpty ||
          task.name.toLowerCase().contains(query) ||
          (task.staff?.toLowerCase().contains(query) ?? false);

      return statusMatch && staffMatch && priorityMatch && deadlineMatch && searchMatch;
    }).toList();
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
  }

  void _handleTaskDrop(String taskId, TaskStatus newStatus) {
    setState(() {
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1 && _tasks[index].status != newStatus) {
        _tasks[index].status = newStatus;
        
        // Auto-assign staff if moved to Assigned and previously unassigned
        if (newStatus == TaskStatus.assigned && _tasks[index].staff == null) {
          _tasks[index].staff = availableStaff.isNotEmpty ? availableStaff[0] : null;
        }
      }
    });
  }

  // --- UI BUILDERS ---

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Task Management Dashboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: primaryTextColor,
                ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showCreateTaskModal(context),
            icon: const Icon(Icons.add_task, color: Colors.white, size: 20),
            label: const Text(
              'Create New Task',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              elevation: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Row(
        children: [
          // 1. Search Bar (Functional)
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tasks by name or staff...',
                prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                fillColor: backgroundWhite,
                filled: true,
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: accentColor, width: 2)),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value; // Updates state on input change
                });
              },
            ),
          ),
          const SizedBox(width: 20),
          
          // 2. Filter Dropdowns Container
          Expanded(
            flex: 4,
            child: Row(
              children: [
                _buildFilterDropdown<String>(
                  'Staff',
                  availableStaff,
                  (newValue) => setState(() => _filterStaff = newValue),
                ),
                _buildFilterDropdown<TaskPriority>(
                  'Priority',
                  TaskPriority.values,
                  (newValue) => setState(() => _filterPriority = newValue),
                ),
                _buildDatePickerFilter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>(
      String hint, List<T> items, ValueChanged<T?> onChanged) {
    
    T? currentValue;
    if (T == String) currentValue = _filterStaff as T?;
    if (T == TaskPriority) currentValue = _filterPriority as T?;

    String valueToText(T? value) {
      if (value == null) return 'All $hint';
      if (value is TaskPriority) {
        return value.toString().split('.').last.toUpperCase();
      }
      return value.toString();
    }
    
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: backgroundWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: currentValue,
          hint: Text('Filter by $hint', style: TextStyle(color: secondaryTextColor, fontSize: 14)),
          items: [
            DropdownMenuItem<T>(value: null, child: Text("All $hint", style: TextStyle(color: secondaryTextColor))),
            ...items.map<DropdownMenuItem<T>>((T value) {
              return DropdownMenuItem<T>(
                value: value,
                child: Text(valueToText(value), style: TextStyle(color: primaryTextColor)),
              );
            }),
          ],
          onChanged: onChanged,
          style: TextStyle(color: primaryTextColor, fontSize: 14),
          icon: const Icon(Icons.keyboard_arrow_down, color: secondaryTextColor),
        ),
      ),
    );
  }

  Widget _buildDatePickerFilter() {
    final String label = _filterDeadline == null 
        ? 'Deadline Filter' 
        : DateFormat('MM/dd/yyyy').format(_filterDeadline!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _filterDeadline ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2030),
          );
          setState(() => _filterDeadline = picked);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: _filterDeadline == null ? secondaryTextColor : primaryTextColor, 
                  fontSize: 14
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                _filterDeadline == null ? Icons.calendar_today_outlined : Icons.close, 
                size: 16, 
                color: accentColor
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTabBar() {
    const List<String> tabs = [
      'Total Tasks',
      'Pending',
      'In Progress',
      'Completed'
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Row(
        children: tabs.map((title) {
          final bool isActive = _selectedTab == title;
          return TextButton(
            onPressed: () {
              setState(() {
                _selectedTab = title;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: isActive ? accentColor : secondaryTextColor,
              padding: const EdgeInsets.only(right: 30, top: 12, bottom: 12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title (${_getTaskCountForTab(title)})',
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    height: 3,
                    width: title.length * 8.0, 
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(5),
                    )
                  )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  int _getTaskCountForTab(String title) {
    // Helper to check if a task matches search/filter criteria regardless of status
    bool isTaskVisibleWithCurrentFilters(Task task) {
      final query = _searchQuery.toLowerCase();
      bool staffMatch = _filterStaff == null || task.staff == _filterStaff;
      bool priorityMatch = _filterPriority == null || task.priority == _filterPriority;
      bool deadlineMatch = _filterDeadline == null || task.deadline.isBefore(_filterDeadline!.add(const Duration(days: 1)));
      bool searchMatch = query.isEmpty ||
          task.name.toLowerCase().contains(query) ||
          (task.staff?.toLowerCase().contains(query) ?? false);
      return staffMatch && priorityMatch && deadlineMatch && searchMatch;
    }
    
    if (title == 'Total Tasks') return _tasks.where((t) => isTaskVisibleWithCurrentFilters(t)).length;
    if (title == 'Pending') return _getFilteredTasks(TaskStatus.toAssign).length;
    if (title == 'In Progress') return _getFilteredTasks(TaskStatus.assigned).length;
    if (title == 'Completed') return _getFilteredTasks(TaskStatus.completed).length;
    return 0;
  }

  // --- KANBAN VIEW ---

  Widget _buildKanbanView() {
    // Show all three columns in 'Total Tasks' view, or a single column if a tab is selected
    if (_selectedTab == 'Total Tasks') {
      return Row( 
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        children: [
          Expanded( 
            child: TaskColumn(
              title: 'To Assign',
              tasks: _getFilteredTasks(TaskStatus.toAssign),
              targetStatus: TaskStatus.toAssign,
              onTaskDrop: _handleTaskDrop,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: TaskColumn(
              title: 'In Progress',
              tasks: _getFilteredTasks(TaskStatus.assigned),
              targetStatus: TaskStatus.assigned,
              onTaskDrop: _handleTaskDrop,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: TaskColumn(
              title: 'Completed',
              tasks: _getFilteredTasks(TaskStatus.completed),
              targetStatus: TaskStatus.completed,
              onTaskDrop: _handleTaskDrop,
            ),
          ),
        ],
      );
    }
    
    // Single Column view if a specific tab is selected
    TaskStatus? singleStatus;
    if (_selectedTab == 'Pending') {
      singleStatus = TaskStatus.toAssign;
    } else if (_selectedTab == 'In Progress') singleStatus = TaskStatus.assigned;
    else if (_selectedTab == 'Completed') singleStatus = TaskStatus.completed;

    if (singleStatus != null) {
      return TaskColumn(
        title: _selectedTab,
        tasks: _getFilteredTasks(singleStatus),
        targetStatus: singleStatus,
        onTaskDrop: _handleTaskDrop,
      );
    }

    return const Center(child: Text("No tasks found matching current filters."));
  }

  // --- MODAL DIALOG ---

  void _showCreateTaskModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateTaskModal(
        availableStaff: availableStaff, 
        onCreate: (task) {
          _addTask(task);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1600),
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeader(),
                _buildFilterBar(),
                _buildTabBar(),
                // Kanban area: Takes remaining space and provides max height constraint
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 200, 
                      maxHeight: MediaQuery.of(context).size.height * 0.75, 
                    ),
                    child: _buildKanbanView(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  final List<Map<String, dynamic>> _invoices = [
    {
      'invoiceNo': 'INV-0012',
      'client': 'Client ABC',
      'amount': 1500,
      'date': DateTime(2025, 9, 15),
      'dueDate': DateTime(2025, 10, 15),
      'status': 'COMPLETED',
      'paymentMode': 'Online'
    },
    {
      'invoiceNo': 'INV-0011',
      'client': 'Client XYZ',
      'amount': 800,
      'date': DateTime(2025, 8, 20),
      'dueDate': DateTime(2025, 9, 20),
      'status': 'OVERDUE',
      'paymentMode': 'Cash'
    },
    {
      'invoiceNo': 'INV-0010',
      'client': 'Client DEF',
      'amount': 2200,
      'date': DateTime(2025, 9, 1),
      'dueDate': DateTime(2025, 10, 1),
      'status': 'COMPLETED',
      'paymentMode': 'Online'
    },
  ];

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final overdueCount = _invoices.where((i) => i['status'] == 'OVERDUE').length;
    final completedCount = _invoices.where((i) => i['status'] == 'COMPLETED').length;

    final filteredInvoices = _invoices.where((invoice) {
      return invoice['client'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          invoice['invoiceNo'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Finance",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2A38))),
          const SizedBox(height: 20),

          // Summary boxes
          Row(children: [
            _buildSummaryCard("Overdue", overdueCount.toString(), Colors.red),
            const SizedBox(width: 16),
            _buildSummaryCard("Completed", completedCount.toString(), Colors.green),
          ]),

          const SizedBox(height: 25),

          // Search + Add button
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                      hintText: "Search name or invoice number",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _openNewInvoiceDialog,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, padding: const EdgeInsets.all(14)),
                child: const Text("+ Generate New Invoice",
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),

          const SizedBox(height: 25),

          // Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300)),
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("INVOICE NO.")),
                    DataColumn(label: Text("CLIENT")),
                    DataColumn(label: Text("AMOUNT")),
                    DataColumn(label: Text("DATE")),
                    DataColumn(label: Text("DUE DATE")),
                    DataColumn(label: Text("STATUS")),
                    DataColumn(label: Text("PAYMENT MODE")),
                    DataColumn(label: Text("ACTION")),
                  ],
                  rows: filteredInvoices.map((invoice) {
                    final dateFormat = DateFormat('yyyy-MM-dd');
                    final color = invoice['status'] == 'COMPLETED'
                        ? Colors.green
                        : Colors.red;
                    return DataRow(cells: [
                      DataCell(Text(invoice['invoiceNo'])),
                      DataCell(Text(invoice['client'])),
                      DataCell(Text("\$${invoice['amount']}")),
                      DataCell(Text(dateFormat.format(invoice['date']))),
                      DataCell(Text(dateFormat.format(invoice['dueDate']))),
                      DataCell(Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(invoice['status'],
                              style: TextStyle(
                                  color: color, fontWeight: FontWeight.bold)))),
                      DataCell(Text(invoice['paymentMode'])),
                      DataCell(ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Invoice ${invoice['invoiceNo']} downloaded successfully!')));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16)),
                        child: const Text("Download Invoice",
                            style: TextStyle(color: Colors.white)),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w500, fontSize: 16)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 22, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  void _openNewInvoiceDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final dateController = TextEditingController(
        text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
    final dueDateController = TextEditingController(
        text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
    String paymentMode = "Select Payment Mode";
    bool membership = false;
    String membershipType = "Select Type";

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setModalState) {
            return AlertDialog(
              scrollable: true,
              title: const Text("Generate New Invoice",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField("Name", "Enter client name", nameController),
                  const SizedBox(height: 10),
                  _buildTextField("Amount", "Enter amount", amountController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: membership,
                        onChanged: (val) =>
                            setModalState(() => membership = val ?? false),
                      ),
                      const Text("Membership *")
                    ],
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: membershipType,
                    decoration: const InputDecoration(
                        labelText: "Membership Type", border: OutlineInputBorder()),
                    items: ["Select Type", "Gold", "Silver", "Bronze"]
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: membership
                        ? (val) =>
                            setModalState(() => membershipType = val ?? "Select Type")
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                        labelText: "Invoice Number",
                        border: OutlineInputBorder()),
                    controller: TextEditingController(
                        text:
                            "INV-${(int.parse(_invoices.first['invoiceNo'].split('-')[1]) + 1).toString().padLeft(4, '0')}"),
                  ),
                  const SizedBox(height: 10),
                  _buildDateField("Date (valid)", dateController, setModalState),
                  const SizedBox(height: 10),
                  _buildDateField("Due Date", dueDateController, setModalState),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: paymentMode,
                    decoration: const InputDecoration(
                        labelText: "Payment Mode", border: OutlineInputBorder()),
                    items: [
                      "Select Payment Mode",
                      "Online",
                      "Cash",
                      "Cheque"
                    ]
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) =>
                        setModalState(() => paymentMode = val ?? "Select Payment Mode"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          amountController.text.isEmpty ||
                          paymentMode == "Select Payment Mode") {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Please fill all required fields!")));
                        return;
                      }
                      setState(() {
                        _invoices.insert(0, {
                          'invoiceNo':
                              "INV-${(int.parse(_invoices.first['invoiceNo'].split('-')[1]) + 1).toString().padLeft(4, '0')}",
                          'client': nameController.text,
                          'amount': double.parse(amountController.text),
                          'date': DateFormat('dd-MM-yyyy').parse(dateController.text),
                          'dueDate':
                              DateFormat('dd-MM-yyyy').parse(dueDateController.text),
                          'status': 'COMPLETED',
                          'paymentMode': paymentMode
                        });
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue),
                    child: const Text("Save Invoice",
                        style: TextStyle(color: Colors.white))),
              ],
            );
          });
        });
  }

  Widget _buildTextField(String label, String hint,
      TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          labelText: "$label: * *",
          hintText: hint,
          border: const OutlineInputBorder()),
      keyboardType: keyboardType,
    );
  }

  Widget _buildDateField(String label, TextEditingController controller,
      void Function(void Function()) setModalState) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
          labelText: "$label: * *",
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today)),
      onTap: () async {
        final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030));
        if (picked != null) {
          setModalState(() {
            controller.text = DateFormat('dd-MM-yyyy').format(picked);
          });
        }
      },
    );
  }
}

//Inventory page 

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Map<String, dynamic>> allItems = [
    {
      'name': 'Printer Paper',
      'quantity': '117 sheets',
      'lastUpdate': '2025-09-10',
      'inStock': 'Restock'
    },
    {
      'name': 'Ink Cartridge',
      'quantity': '30 units',
      'lastUpdate': '2025-09-12',
      'inStock': 'Adequate'
    },
    {
      'name': 'Staplers',
      'quantity': '15 units',
      'lastUpdate': '2025-09-08',
      'inStock': 'Adequate'
    },
    {
      'name': 'Laptop Charger',
      'quantity': '8 units',
      'lastUpdate': '2025-09-15',
      'inStock': 'Adequate'
    },
    {
      'name': 'Ethernet Cable',
      'quantity': 'NaN meters',
      'lastUpdate': '2025-10-30',
      'inStock': 'Adequate'
    },
    {
      'name': 'Coffee Beans',
      'quantity': '8 kg',
      'lastUpdate': '2025-10-30',
      'inStock': 'Restock'
    },
  ];

  List<Map<String, dynamic>> displayedItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedItems = List.from(allItems);
  }

  void _showSnack(String message, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedItems = List.from(allItems);
      } else {
        displayedItems = allItems
            .where((item) =>
                item['name'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _addItemDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Inventory",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: "Item Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                    labelText: "Quantity", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                    labelText: "Unit (e.g. sheets, kg, units)",
                    border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  quantityController.text.isEmpty ||
                  unitController.text.isEmpty) {
                _showSnack("All fields are required", color: Colors.red);
                return;
              }
              final newItem = {
                'name': nameController.text,
                'quantity':
                    "${quantityController.text} ${unitController.text}",
                'lastUpdate':
                    DateFormat('yyyy-MM-dd').format(DateTime.now()),
                'inStock': 'Adequate',
              };
              setState(() {
                allItems.add(newItem);
                displayedItems = List.from(allItems);
              });
              Navigator.pop(context);
              _showSnack("Item added successfully!");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Add Item"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _editItemDialog(Map<String, dynamic> item) {
    final quantityController =
        TextEditingController(text: item['quantity'].split(' ')[0]);
    final unitController =
        TextEditingController(text: item['quantity'].split(' ').length > 1
            ? item['quantity'].split(' ')[1]
            : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${item['name']}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                  labelText: "Quantity", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(
                  labelText: "Unit", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                item['quantity'] =
                    "${quantityController.text} ${unitController.text}";
                item['lastUpdate'] =
                    DateFormat('yyyy-MM-dd').format(DateTime.now());
              });
              Navigator.pop(context);
              _showSnack("Item updated successfully!");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Save"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _restockItem(Map<String, dynamic> item) {
    final addController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Restock Item",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _readonlyField("Item Name", item['name']),
            _readonlyField("Current Quantity", item['quantity']),
            _readonlyField("Last Restock Date",
                DateFormat('yyyy-MM-dd').format(DateTime.now())),
            const SizedBox(height: 10),
            TextField(
              controller: addController,
              decoration: const InputDecoration(
                  labelText: "Quantity to Add", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (addController.text.isEmpty) {
                _showSnack("Enter quantity to add", color: Colors.red);
                return;
              }
              final parts = item['quantity'].split(' ');
              int current = int.tryParse(parts[0]) ?? 0;
              final added = int.tryParse(addController.text) ?? 0;
              item['quantity'] =
                  "${current + added} ${parts.length > 1 ? parts[1] : ''}";
              item['lastUpdate'] =
                  DateFormat('yyyy-MM-dd').format(DateTime.now());
              item['inStock'] = "Adequate";
              setState(() {});
              Navigator.pop(context);
              _showSnack("Item restocked successfully!");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Confirm Restock"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Widget _readonlyField(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          readOnly: true,
          decoration: InputDecoration(
              labelText: label,
              hintText: value,
              border: const OutlineInputBorder()),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "Inventory",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2A38)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _search,
                    decoration: InputDecoration(
                      hintText: "Search inventory...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: "All Items",
                    items: const [
                      DropdownMenuItem(value: "All Items", child: Text("All Items")),
                      DropdownMenuItem(value: "Adequate", child: Text("Adequate")),
                      DropdownMenuItem(value: "Restock", child: Text("Restock")),
                    ],
                    onChanged: (val) {
                      setState(() {
                        if (val == "All Items") {
                          displayedItems = List.from(allItems);
                        } else {
                          displayedItems = allItems
                              .where((e) => e['inStock'] == val)
                              .toList();
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4CC),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                  "⚠️ ${allItems.where((e) => e['inStock'] == 'Restock').length} item(s) need restocking"),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                columns: const [
                  DataColumn(label: Text("NAME")),
                  DataColumn(label: Text("QUANTITY")),
                  DataColumn(label: Text("LAST UPDATE")),
                  DataColumn(label: Text("IN STOCK")),
                  DataColumn(label: Text("ACTIONS")),
                ],
                rows: displayedItems.map((item) {
                  final isRestock = item['inStock'] == 'Restock';
                  return DataRow(
                    color: WidgetStateProperty.resolveWith(
                        (states) => isRestock ? Colors.red[50] : Colors.white),
                    cells: [
                      DataCell(Text(item['name'])),
                      DataCell(Row(children: [
                        Text(item['quantity']),
                        const SizedBox(width: 5),
                        TextButton(
                            onPressed: () => _editItemDialog(item),
                            child: const Text("Edit",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.blue)))
                      ])),
                      DataCell(Text(item['lastUpdate'])),
                      DataCell(Text(
                          isRestock ? "↓ Restock" : "↑ Adequate",
                          style: TextStyle(
                              color: isRestock ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w600))),
                      DataCell(Row(children: [
                        ElevatedButton(
                          onPressed: () => _restockItem(item),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: const Size(70, 30)),
                          child: const Text("Restock",
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              allItems.remove(item);
                              displayedItems.remove(item);
                            });
                            _showSnack("${item['name']} deleted!",
                                color: Colors.red);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(70, 30)),
                          child: const Text("Delete",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ])),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _addItemDialog,
                icon: const Icon(Icons.add),
                label: const Text("Add Inventory"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Announcement Page

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String selectedRecipient = 'All Users';

  final List<Map<String, dynamic>> recipients = [
    {'name': 'All Users', 'count': 52},
    {'name': 'Staff Only', 'count': 15},
    {'name': 'Clients Only', 'count': 37},
    {'name': 'Premium Clients', 'count': 12},
  ];

  final List<Map<String, String>> pastAnnouncements = [
    {
      'title': 'System Maintenance Notice',
      'date': '2024-01-15',
      'to': 'All (45)',
      'type': 'Announcement',
      'message':
          'There will be system maintenance this Saturday from 2–4 A.M. The platform will be temporarily unavailable.'
    },
    {
      'title': 'New Feature Update',
      'date': '2024-01-10',
      'to': 'Clients (23)',
      'type': 'Announcement',
      'message':
          'We’ve added new reporting features to your dashboard. Check out the new analytics tab.'
    },
    {
      'title': 'Holiday Schedule',
      'date': '2024-01-05',
      'to': 'All (52)',
      'type': 'Announcement',
      'message':
          'Our offices will be closed for the holiday from Dec 24th to Jan 2nd. Support will resume Jan 3rd.'
    },
    {
      'title': 'Staff Meeting Reminder',
      'date': '2024-01-03',
      'to': 'Staff (15)',
      'type': 'General',
      'message':
          'Monthly staff meeting this Friday at 10 AM in the main conference room.'
    },
  ];

  void sendAnnouncement() {
    if (subjectController.text.isEmpty || messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both subject and message fields.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      pastAnnouncements.insert(0, {
        'title': subjectController.text,
        'date': DateTime.now().toString().substring(0, 10),
        'to': selectedRecipient,
        'type': 'Announcement',
        'message': messageController.text,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Announcement sent to $selectedRecipient successfully!'),
        backgroundColor: const Color(0xFF1E2A38),
      ),
    );

    subjectController.clear();
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildRecipientsPanel()),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildComposePanel()),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildPastAnnouncementsPanel()),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildRecipientsPanel(),
                    const SizedBox(height: 16),
                    _buildComposePanel(),
                    const SizedBox(height: 16),
                    _buildPastAnnouncementsPanel(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRecipientsPanel() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Select Recipients',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1E2A38))),
          const SizedBox(height: 12),
          for (var r in recipients)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                tileColor: selectedRecipient == r['name']
                    ? const Color(0xFFE9F0FA)
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFCAD6E2))),
                title: Text(r['name']),
                subtitle: Text('${r['count']} recipients'),
                leading: Radio<String>(
                  value: r['name'],
                  groupValue: selectedRecipient,
                  onChanged: (val) => setState(() => selectedRecipient = val!),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            "Selected: $selectedRecipient\nWill send to: ${recipients.firstWhere((r) => r['name'] == selectedRecipient)['count']} people",
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          const Text("Quick Templates",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF1E2A38))),
          const SizedBox(height: 10),
          _quickTemplateBox(
              "Maintenance Alert",
              "System maintenance this Saturday from 2–4 AM.",
              Icons.build),
          const SizedBox(height: 8),
          _quickTemplateBox("Feature Update",
              "New features have been added to the dashboard.", Icons.update),
          const SizedBox(height: 8),
          _quickTemplateBox("Holiday Notice",
              "Our office will be closed for the upcoming holiday.", Icons.beach_access),
        ]),
      ),
    );
  }

  Widget _quickTemplateBox(String title, String message, IconData icon) {
    return InkWell(
      onTap: () {
        subjectController.text = title;
        messageController.text = message;
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCAD6E2)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1E2A38), size: 20),
            const SizedBox(width: 10),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E2A38)))),
          ],
        ),
      ),
    );
  }

  Widget _buildComposePanel() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Compose Announcement',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1E2A38))),
          const SizedBox(height: 12),
          const Text("Email Subject *"),
          TextField(
            controller: subjectController,
            decoration: const InputDecoration(
              hintText: "Enter announcement subject...",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Message *"),
          TextField(
            controller: messageController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: "Type your announcement message here...",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: sendAnnouncement,
            icon: const Icon(Icons.send),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E2A38),
                minimumSize: const Size.fromHeight(45),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            label: Text(
              "Send to ${recipients.firstWhere((r) => r['name'] == selectedRecipient)['count']} Recipients",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildPastAnnouncementsPanel() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Past Announcements',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1E2A38))),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: pastAnnouncements.length,
              itemBuilder: (context, index) {
                final ann = pastAnnouncements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: const BorderSide(color: Color(0xFFE3E8EE))),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Text(ann['title']!,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF1E2A38)))),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: ann['type'] == 'Announcement'
                                        ? const Color(0xFFDFF6E0)
                                        : const Color(0xFFE0E8F6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(ann['type']!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF1E2A38))),
                                ),
                              ]),
                          const SizedBox(height: 4),
                          Text(ann['date']!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                          Text("To: ${ann['to']}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                          const SizedBox(height: 6),
                          Text(ann['message']!,
                              style: const TextStyle(fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ]),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

//Settings Page

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool twoFactorEnabled = true;
  bool offlineMode = false;
  bool databaseBackup = true;
  String passwordPolicy = "Strong";

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(fontSize: 16, color: Colors.white)),
        backgroundColor: const Color(0xFF1E2A38),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleTwoFactor(bool value) {
    setState(() => twoFactorEnabled = value);
    _showSnackBar(value
        ? "Two-Factor Authentication Enabled"
        : "Two-Factor Authentication Disabled");
  }

  void _toggleOfflineMode(bool value) {
    setState(() {
      offlineMode = value;
      if (!value) {
        databaseBackup = true; // keep backups on when offline mode off
      }
    });
    _showSnackBar(
        value ? "Offline Mode Enabled" : "Offline Mode Disabled");
  }

  void _toggleDatabaseBackup(bool value) {
    if (offlineMode && value) {
      _showSnackBar(
          "Cannot enable backups in Offline Mode. Connect to the internet.");
      return;
    }
    setState(() => databaseBackup = value);
    _showSnackBar(value
        ? "Database Backup Enabled"
        : "Database Backup Disabled");
  }

  void _changePasswordPolicy() {
    setState(() {
      passwordPolicy =
          passwordPolicy == "Strong" ? "Moderate" : "Strong";
    });
    _showSnackBar("Password Policy set to $passwordPolicy");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2A38),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Security",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2A38),
                  ),
                ),
                const SizedBox(height: 16),

                // Two-Factor
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Two-Factor Authentication",
                        style: TextStyle(
                            fontSize: 16, color: Color(0xFF1E2A38))),
                    Switch(
                      value: twoFactorEnabled,
                      onChanged: _toggleTwoFactor,
                      activeColor: const Color(0xFF1E90FF),
                    ),
                  ],
                ),
                _settingValueText(
                    twoFactorEnabled ? "Enabled" : "Disabled"),

                const SizedBox(height: 12),

                // Password Policy
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Password Policy",
                        style: TextStyle(
                            fontSize: 16, color: Color(0xFF1E2A38))),
                    TextButton(
                      onPressed: _changePasswordPolicy,
                      child: Text(
                        passwordPolicy,
                        style: const TextStyle(
                            color: Color(0xFF1E2A38), fontSize: 16),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 12),

                // Offline Mode
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Offline Mode\nAccess Without Internet",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1E2A38),
                        height: 1.3,
                      ),
                    ),
                    Switch(
                      value: offlineMode,
                      onChanged: _toggleOfflineMode,
                      activeColor: const Color(0xFF1E90FF),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Database Backup
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Database Backup",
                        style: TextStyle(
                            fontSize: 16, color: Color(0xFF1E2A38))),
                    Switch(
                      value: databaseBackup,
                      onChanged: _toggleDatabaseBackup,
                      activeColor: const Color(0xFF1E90FF),
                    ),
                  ],
                ),
                _settingValueText(databaseBackup
                    ? "Daily at 5 PM"
                    : "Backup Disabled"),

                const SizedBox(height: 32),

                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2A38),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Action Buttons
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: isWide
                          ? WrapAlignment.start
                          : WrapAlignment.center,
                      children: [
                        _buildActionButton("Run Backups", Icons.backup),
                        _buildActionButton(
                            "Restore Settings", Icons.settings_backup_restore),
                        _buildActionButton("Update System", Icons.system_update),
                        _buildActionButton("Generate Report", Icons.analytics),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingValueText(String text) => Padding(
        padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
              height: 1.2),
        ),
      );

  Widget _buildActionButton(String label, IconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFCCCCCC)),
        foregroundColor: const Color(0xFF1E2A38),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      onPressed: () => _showSnackBar("$label executed successfully"),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 15)),
    );
  }
}

// --------------------------------------------------
// REUSABLE AUTH SCAFFOLD
// --------------------------------------------------

class AuthScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const AuthScaffold({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2A38)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 30),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}


