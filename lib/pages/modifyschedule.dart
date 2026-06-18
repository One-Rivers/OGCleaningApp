/********************************************************************
* TITLE: Modify Schedule Page
* FILENAME: modifyschedule.dart
* AUTHOR: Juan M. Rios
* DATE: 06/11/2026
* INSTRUCTOR:  Dr. Rafiq
* COURSE: CIS 350
* SECTION: 01
* INPUTS:   Nothing passed in — the page fetches all shifts and
*           locations from the server itself.
* OUTPUTS:  A manager screen listing every shift, with delete
*           buttons and an "Add Shift" form for creating new ones.
* DESCRIPTION: The manager's editing room. Shows all shifts sorted
*           by start time, lets you delete one (with an are-you-sure
*           popup), and add new ones through a form with a location
*           dropdown and date/time pickers.
* NOTES:    Needs http and google_fonts. FIXES in this version:
*           Employee ID must be a real number (was crashable),
*           end time must come after start time, and mounted
*           guards added after fetches.
*********************************************************************/

/********************************************************************************/
/* IMPORTS — grabbing the tools this file needs                                 */
/********************************************************************************/

/* Translates the server's JSON text into Dart lists and maps. */
import 'dart:convert';

/* Flutter's standard UI toolkit. */
import 'package:flutter/material.dart';

/* Google fonts (Inter) without bundling font files. */
import 'package:google_fonts/google_fonts.dart';

/* How we talk to the server. */
import 'package:http/http.dart' as http;

/* Our Shift class and the server address (baseUrl). */
import '../shift_model.dart';

/********************************************************************************/
/* THE PAGE — what the Modify Schedule button opens                             */
/********************************************************************************/

/* Stateful because it remembers the shift list and loading state. */
class ModifySchedulePage extends StatefulWidget {
  const ModifySchedulePage({super.key});

  @override
  State<ModifySchedulePage> createState() => _ModifySchedulePageState();
}

/********************************************************************************/
/* THE BRAIN — the page's memory and all its actions                            */
/********************************************************************************/

class _ModifySchedulePageState extends State<ModifySchedulePage> {
  /* Every shift in the system, sorted by start time. */
  List<Shift> _shifts = [];

  /* True while waiting on the server — controls the spinner. */
  bool _loading = true;

  /* Runs once when the page opens: go get the shifts. */
  @override
  void initState() {
    super.initState();
    _fetchShifts();
  }

/********************************************************************************/
/* FETCH — download every shift from the server                                 */
/********************************************************************************/

  Future<void> _fetchShifts() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/getShifts'));

      /* FIX: user left the page while we waited? Bail quietly. */
      if (!mounted) return;

      if (response.statusCode == 200) {
        /* JSON text → list of Shift objects → sorted earliest-first.
           The ".." means "sort that same list, don't make a new one". */
        final List<dynamic> data = jsonDecode(response.body);
        final shifts = data.map((j) => Shift.fromJson(j)).toList()
          ..sort((a, b) => a.scheduleStart.compareTo(b.scheduleStart));

        setState(() {
          _shifts = shifts;
          _loading = false;
        });
      } else {
        /* Server errored — stop the spinner anyway. */
        setState(() => _loading = false);
      }
    } catch (e) {
      /* No internet / server down — stop the spinner, don't crash. */
      if (mounted) setState(() => _loading = false);
    }
  }

/********************************************************************************/
/* DELETE — remove a shift (with an are-you-sure popup)                         */
/********************************************************************************/

  Future<void> _deleteShift(Shift shift) async {
    /* Confirm before deleting — there is no undo. */
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

    /* Anything but a clear "Delete" tap = nevermind. */
    if (sure != true) return;

    try {
      /* Tell the server to erase this shift by its database id. */
      final response =
          await http.delete(Uri.parse('$baseUrl/deleteShift/${shift.id}'));
      if (!mounted) return;

      if (response.statusCode == 200) {
        /* Gone — re-download the list so the screen matches. */
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

/********************************************************************************/
/* CREATE — send a brand new shift to the server                                */
/********************************************************************************/

  Future<void> _createShift(Shift shift) async {
    try {
      /* Mail the new shift to the server's /createShifts door. */
      final response = await http.post(
        Uri.parse('$baseUrl/createShifts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(shift.toJson()),
      );

      /* Saved? Refresh the list so the new shift shows up. */
      if (response.statusCode == 200) _fetchShifts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create shift')),
        );
      }
    }
  }

  /* Turns a date into "M/D  HH:MM" text for the list rows. */
  String _fmt(DateTime dt) =>
      '${dt.month}/${dt.day}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

/********************************************************************************/
/* BUILD — the actual screen layout                                             */
/********************************************************************************/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12343B),

      /* Top bar with a refresh button on the right. */
      appBar: AppBar(
        title: const Text('Modify Schedule'),
        backgroundColor: const Color(0xFF2D545E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchShifts),
        ],
      ),

      /* Three possibilities, checked in order:
         still loading → spinner.
         loaded but empty → "No shifts yet" message.
         otherwise → the scrollable list of shifts. */
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

/********************************************************************************/
/* ONE ROW — the card for a single shift                                        */
/********************************************************************************/

                    return Card(
                      color: const Color(0xFF2D545E),
                      margin: const EdgeInsets.symmetric(vertical: 4),

                      /* ListTile = a ready-made row: big text, small
                         text under it, and something at the end. */
                      child: ListTile(
                        /* Who and where. */
                        title: Text('Emp #${s.employeeId} — ${s.locationId}',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),

                        /* When: start → end. */
                        subtitle: Text(
                            '${_fmt(s.scheduleStart)} → ${_fmt(s.scheduleEnd)}',
                            style: GoogleFonts.inter(color: Colors.white70)),

                        /* The trash can on the right. */
                        trailing: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Color(0xFFE1B382)),
                          onPressed: () => _deleteShift(s),
                        ),
                      ),
                    );
                  },
                ),

      /* The floating "Add Shift" button, bottom-right. Tapping it
         opens the form dialog below and hands it our create
         function to call when saved. */
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

/********************************************************************************/
/* ADD SHIFT DIALOG — the popup form for creating a new shift                   */
/* (moved here from main.dart — only managers use it)                           */
/********************************************************************************/

class AddShiftDialog extends StatefulWidget {
  const AddShiftDialog({super.key, required this.onSubmit});

  /* The function to run when Save is tapped — the page above passes
     in its _createShift. */
  final Future<void> Function(Shift) onSubmit;

  @override
  State<AddShiftDialog> createState() => _AddShiftDialogState();
}

/********************************************************************************/
/* THE DIALOG'S BRAIN — form fields, pickers, and submitting                    */
/********************************************************************************/

class _AddShiftDialogState extends State<AddShiftDialog> {
  /* A handle on the form so we can ask it "is everything valid?" */
  final _formKey = GlobalKey<FormState>();

  /* Clipboard for the Employee ID box. */
  final _empIdCtrl = TextEditingController();

  /* Which location got picked in the dropdown (null = none yet). */
  String? _selectedLocation;

  /* The list of locations downloaded for the dropdown. */
  List<dynamic> _locations = [];

  /* The picked start and end times (null = not picked yet). */
  DateTime? _start, _end;

  /* True while saving — disables the Save button. */
  bool _submitting = false;

  /* When the dialog opens, go get the locations for the dropdown. */
  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getLocations'));
      if (response.statusCode == 200 && mounted) {
        setState(() => _locations = jsonDecode(response.body));
      }
    } catch (_) {
      /* Dropdown just stays empty if this fails. */
    }
  }

/********************************************************************************/
/* DATE/TIME PICKING — calendar popup, then clock popup                         */
/********************************************************************************/

  /* Used for BOTH start and end — the true/false flag says which
     one we're picking. */
  Future<void> _pickDateTime(bool isStart) async {
    /* Step 1: the calendar. Allowed range = one year back to one
       year ahead. */
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)));

    /* Closed the calendar without picking? Stop. */
    if (date == null || !mounted) return;

    /* Step 2: the clock. */
    final time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;

    /* Glue the date and time together into one DateTime. */
    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    /* Store it in the right slot and redraw. */
    setState(() => isStart ? _start = dt : _end = dt);
  }

  /* What the picker rows display: a prompt, or the picked time. */
  String _fmtPicked(DateTime? dt) => dt == null
      ? 'Tap to select'
      : '${dt.month}/${dt.day}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

/********************************************************************************/
/* SUBMIT — final checks, then hand the shift to the page                       */
/********************************************************************************/

  Future<void> _submit() async {
    /* Run every field's validator — stops here if anything's wrong. */
    if (!_formKey.currentState!.validate()) return;

    /* Both times must be picked. */
    if (_start == null || _end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select start and end times')));
      return;
    }

    /* FIX: the end must come AFTER the start — no backwards shifts. */
    if (!_end!.isAfter(_start!)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')));
      return;
    }

    /* Lock the Save button and build the Shift to send. */
    setState(() => _submitting = true);
    await widget.onSubmit(Shift(
      employeeId: int.parse(_empIdCtrl.text.trim()),
      locationId: _selectedLocation!,
      scheduleStart: _start!,
      scheduleEnd: _end!,
    ));

    /* Close the dialog. */
    if (mounted) Navigator.of(context).pop();
  }

/********************************************************************************/
/* DIALOG BUILD — the form's layout                                             */
/********************************************************************************/

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Shift'),

      /* Scrollable in case a small phone can't fit the whole form. */
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /* Employee ID box. FIX: the validator now demands a
                 real number — letters used to crash the app at
                 int.parse when saving. */
              TextFormField(
                  controller: _empIdCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Employee ID', prefixIcon: Icon(Icons.badge)),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (int.tryParse(v.trim()) == null) return 'Numbers only';
                    return null;
                  }),
              const SizedBox(height: 12),

              /* Location dropdown, filled from the server. */
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                decoration: const InputDecoration(
                    labelText: 'Location', prefixIcon: Icon(Icons.location_on)),

                /* Turn each downloaded location into a menu choice. */
                items: _locations.map<DropdownMenuItem<String>>((loc) {
                  return DropdownMenuItem(
                      value: loc['name'], child: Text(loc['name']));
                }).toList(),
                onChanged: (v) => setState(() => _selectedLocation = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              /* The two tappable rows that open the date/time pickers. */
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

      /* The bottom buttons: Cancel, and Save (spinner while saving). */
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
