import 'package:flutter/material.dart';

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
        primaryColor: const Color(0xFF1E2A38), // dark navy
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFD9D9D9), // light grey
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF1E2A38)),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

// Splash

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegisterPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2A38),
      body: const Center(
        child: Text(
          "Koala Workspace",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Register

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Register",
      children: [
        const TextField(decoration: InputDecoration(hintText: "Email")),
        const SizedBox(height: 10),
        const TextField(decoration: InputDecoration(hintText: "Password"), obscureText: true),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2A38)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
          child: const Text("Register", style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
          child: const Text("Already have an account? Login"),
        )
      ],
    );
  }
}

//Login

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Login",
      children: [
        const TextField(decoration: InputDecoration(hintText: "Email")),
        const SizedBox(height: 10),
        const TextField(decoration: InputDecoration(hintText: "Password"), obscureText: true),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2A38)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardPage()),
            );
          },
          child: const Text("Login", style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
            );
          },
          child: const Text("Forgot Password?"),
        )
      ],
    );
  }
}

// Forgot Password (email input)

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Forgot Password",
      children: [
        const TextField(decoration: InputDecoration(hintText: "Enter your email")),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2A38)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
            );
          },
          child: const Text("Submit", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// Reset Password 

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Reset Password",
      children: [
        const TextField(decoration: InputDecoration(hintText: "New Password"), obscureText: true),
        const SizedBox(height: 10),
        const TextField(decoration: InputDecoration(hintText: "Confirm Password"), obscureText: true),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2A38)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
          child: const Text("Reset Password", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

//Dashboard with Sidebar 

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<String> _menuItems = [
    "Dashboard",
    "Leads",
    "Clients",
    "Projects",
    "Tasks",
    "Reports"
  ];

  final List<Widget> _pages = const [
    Center(child: Text("Welcome to Koala Workspace Dashboard", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38)))),
    Center(child: Text("Leads Page", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38)))),
    Center(child: Text("Clients Page", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38)))),
    Center(child: Text("Projects Page", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38)))),
    Center(child: Text("Tasks Page", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38)))),
    Center(child: Text("Reports Page", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E2A38)))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 220,
            color: const Color(0xFF1E2A38),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text("CRM Options", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                for (int i = 0; i < _menuItems.length; i++)
                  SidebarItem(
                    title: _menuItems[i],
                    selected: _selectedIndex == i,
                    onTap: () {
                      setState(() {
                        _selectedIndex = i;
                      });
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? Colors.white24 : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}


//  Reusable Auth Scaffold 

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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2A38),
                  ),
                  textAlign: TextAlign.center,
                ),
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
