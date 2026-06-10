import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/timecode/timecode.dart';
import '../../models/cue.dart';
import '../../models/session_model.dart';
import '../../theme/app_theme.dart';

class CueEditorScreen extends StatefulWidget {
  const CueEditorScreen({
    super.key,
    required this.session,
    required this.onSave,
    this.existingCue,
  });

  final SessionModel session;
  final Cue? existingCue;
  final void Function(Cue cue) onSave;

  @override
  State<CueEditorScreen> createState() => _CueEditorScreenState();
}

class _CueEditorScreenState extends State<CueEditorScreen> {
  late final TextEditingController _labelCtrl;
  late final TextEditingController _hhCtrl;
  late final TextEditingController _mmCtrl;
  late final TextEditingController _ssCtrl;
  late final TextEditingController _ffCtrl;

  final _hhFocus = FocusNode();
  final _mmFocus = FocusNode();
  final _ssFocus = FocusNode();
  final _ffFocus = FocusNode();

  bool get _isEditing => widget.existingCue != null;

  @override
  void initState() {
    super.initState();
    final cue = widget.existingCue;
    _labelCtrl = TextEditingController(text: cue?.label ?? '');
    if (cue != null) {
      final parts = cue.timecode.split(':');
      _hhCtrl = TextEditingController(text: parts[0]);
      _mmCtrl = TextEditingController(text: parts[1]);
      _ssCtrl = TextEditingController(text: parts[2]);
      _ffCtrl = TextEditingController(text: parts[3]);
    } else {
      _hhCtrl = TextEditingController(text: '00');
      _mmCtrl = TextEditingController(text: '00');
      _ssCtrl = TextEditingController(text: '00');
      _ffCtrl = TextEditingController(text: '00');
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _hhCtrl.dispose();
    _mmCtrl.dispose();
    _ssCtrl.dispose();
    _ffCtrl.dispose();
    _hhFocus.dispose();
    _mmFocus.dispose();
    _ssFocus.dispose();
    _ffFocus.dispose();
    super.dispose();
  }

  void _save() {
    if (_labelCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a cue label')),
      );
      return;
    }
    final tc =
        '${_hhCtrl.text.padLeft(2, '0')}:${_mmCtrl.text.padLeft(2, '0')}:${_ssCtrl.text.padLeft(2, '0')}:${_ffCtrl.text.padLeft(2, '0')}';
    if (!Timecode.isValid(tc)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid timecode')),
      );
      return;
    }
    final nextId = widget.existingCue?.id ??
        (widget.session.cues.isEmpty
            ? 1
            : widget.session.cues
                    .map((c) => c.id)
                    .reduce((a, b) => a > b ? a : b) +
                1);
    widget.onSave(Cue(
      id: nextId,
      label: _labelCtrl.text.trim(),
      timecode: tc,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    _isEditing ? 'Edit Cue' : 'Add Cue',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label field
                  const _FieldLabel('CUE LABEL'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _labelCtrl,
                    autofocus: !_isEditing,
                    style: const TextStyle(color: AppColors.textPrimary),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Chandelier Drop',
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Timecode field
                  const _FieldLabel('TIMECODE  (HH : MM : SS : FF)'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _TcField(
                        controller: _hhCtrl,
                        focusNode: _hhFocus,
                        nextFocus: _mmFocus,
                        hint: 'HH',
                        max: 23,
                      ),
                      const _TcSep(),
                      _TcField(
                        controller: _mmCtrl,
                        focusNode: _mmFocus,
                        nextFocus: _ssFocus,
                        hint: 'MM',
                        max: 59,
                      ),
                      const _TcSep(),
                      _TcField(
                        controller: _ssCtrl,
                        focusNode: _ssFocus,
                        nextFocus: _ffFocus,
                        hint: 'SS',
                        max: 59,
                      ),
                      const _TcSep(),
                      _TcField(
                        controller: _ffCtrl,
                        focusNode: _ffFocus,
                        hint: 'FF',
                        max: widget.session.framerate - 1,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Save button
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _isEditing ? 'Save Changes' : 'Add Cue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _TcField extends StatelessWidget {
  const _TcField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.max,
    this.nextFocus,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final String hint;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 2,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _RangeInputFormatter(max),
        ],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          fontFamily: 'monospace',
        ),
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (v) {
          if (v.length == 2 && nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        },
        onTap: () => controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        ),
      ),
    );
  }
}

class _TcSep extends StatelessWidget {
  const _TcSep();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _RangeInputFormatter extends TextInputFormatter {
  const _RangeInputFormatter(this.max);
  final int max;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final n = int.tryParse(newValue.text);
    if (n == null || n > max) return oldValue;
    return newValue;
  }
}
