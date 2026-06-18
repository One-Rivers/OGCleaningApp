import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../shift_model.dart';

class ModifySchedulePage extends StatefulWidget {
  const ModifySchedulePage({super.key});

  @override
  State<ModifySchedulePage> createState() => _ModifySchedulePageState();
}

class _ModifySchedulePageState extends State<ModifySchedulePage> {
  List<Shift> _shifts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchShifts();
  }

  Future<void> _fetchShifts() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/getShifts'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final shifts = data.map((j) => Shift.fromJson(j)).toList()
          ..sort((a, b) => a.scheduleStart.compareTo(b.scheduleStart));
        setState(() {
          _shifts = shifts;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteShift(Shift shift) async {
    // Confirm before deleting — there is no undo
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete shift?'),
        content:
            Text('Remove Emp #${shift.employeeId} at ${shift.locationId}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (sure != true) return;

    try {
      final response =
          await http.delete(Uri.parse('$baseUrl/deleteShift/${shift.id}'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        _fetchShifts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delete failed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not reach server')),
        );
      }
    }
  }

  Future<void> _createShift(Shift shift) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/createShifts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(shift.toJson()),
      );
      if (response.statusCode == 200) _fetchShifts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create shift')),
        );
      }
    }
  }

  String _fmt(DateTime dt) =>
      '${dt.month}/${dt.day}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12343B),
      appBar: AppBar(
        title: const Text('Modify Schedule'),
        backgroundColor: const Color(0xFF2D545E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchShifts),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _shifts.isEmpty
              ? Center(
                  child: Text('No shifts yet. Tap + to add one!',
                      style: GoogleFonts.inter(color: Colors.white70)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _shifts.length,
                  itemBuilder: (_, i) {
                    final s = _shifts[i];
                    return Card(
                      color: const Color(0xFF2D545E),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text('Emp #${s.employeeId} — ${s.locationId}',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            '${_fmt(s.scheduleStart)} → ${_fmt(s.scheduleEnd)}',
                            style: GoogleFonts.inter(color: Colors.white70)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Color(0xFFE1B382)),
                          onPressed: () => _deleteShift(s),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFC89666),
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddShiftDialog(onSubmit: _createShift),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Shift'),
      ),
    );
  }
}

// ── Add Shift Dialog (moved here from main.dart — only managers use it) ──
class AddShiftDialog extends StatefulWidget {
  const AddShiftDialog({super.key, required this.onSubmit});

  final Future<void> Function(Shift) onSubmit;

  @override
  State<AddShiftDialog> createState() => _AddShiftDialogState();
}

class _AddShiftDialogState extends State<AddShiftDialog> {
  final _formKey = GlobalKey<FormState>();
  final _empIdCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime? _start, _end;
  bool _submitting = false;

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date == null || !mounted) return;
    final time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() => isStart ? _start = dt : _end = dt);
  }

  String _fmtPicked(DateTime? dt) => dt == null
      ? 'Tap to select'
      : '${dt.month}/${dt.day}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_start == null || _end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select start and end times')));
      return;
    }
    setState(() => _submitting = true);
    await widget.onSubmit(Shift(
      employeeId: int.parse(_empIdCtrl.text.trim()),
      locationId: _locationCtrl.text.trim(),
      scheduleStart: _start!,
      scheduleEnd: _end!,
    ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Shift'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  controller: _empIdCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Employee ID', prefixIcon: Icon(Icons.badge)),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Location ID',
                      prefixIcon: Icon(Icons.location_on)),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null),
              const SizedBox(height: 16),
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.login, color: Colors.blue),
                  title: const Text('Schedule Start'),
                  subtitle: Text(_fmtPicked(_start)),
                  onTap: () => _pickDateTime(true)),
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout, color: Colors.blue),
                  title: const Text('Schedule End'),
                  subtitle: Text(_fmtPicked(_end)),
                  onTap: () => _pickDateTime(false)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save Shift'),
        ),
      ],
    );
  }
}
