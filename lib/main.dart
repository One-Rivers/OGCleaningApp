import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'pages/login.dart';
import 'shift_model.dart';
import 'components/WeekScheduleLayout.dart';
import 'components/PunchButton.dart';
import 'components/ChangeScheduleButton.dart';
import 'components/EmployeeStatusList.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OG Cleaning Scheduler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D545E)),
      ),
      home: const SignInFive(), // login is the first page
    );
  }
}

// ── Main Scheduler Page — week layout + punch + (manager) modify ──
class ShiftSchedulerPage extends StatefulWidget {
  const ShiftSchedulerPage({super.key, required this.employee});

  /// The logged-in employee, passed from the login page
  final Map<String, dynamic> employee;

  @override
  State<ShiftSchedulerPage> createState() => _ShiftSchedulerPageState();
}

class _ShiftSchedulerPageState extends State<ShiftSchedulerPage> {
  List<Shift> _shifts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchShifts();
  }

  Future<void> _fetchShifts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('$baseUrl/getShifts'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _shifts = data.map((j) => Shift.fromJson(j)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Cannot reach server.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12343B),
      appBar: AppBar(
        title: const Text('OG Cleaning Scheduler'),
        backgroundColor: const Color(0xFF2D545E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchShifts,
              tooltip: 'Refresh'),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchShifts, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('This Week',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ),
        // Sun–Sat columns with each employee's shifts
        WeekScheduleLayout(shifts: _shifts),
        // Manager-only team status list (regular employees just get empty space here)
        Expanded(
          child: EmployeeStatusList(employee: widget.employee, shifts: _shifts),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PunchButton(employee: widget.employee),
              // Only renders when certification == true for the managers
              ChangeScheduleButton(employee: widget.employee),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
