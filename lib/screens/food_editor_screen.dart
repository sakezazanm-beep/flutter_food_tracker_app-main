import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_config.dart';
import '../core/app_theme.dart';
import '../models/food_entry.dart';
import '../services/food_repository.dart';

class FoodEditor extends StatefulWidget {
  const FoodEditor({super.key, this.entry, required this.initialDate});
  final FoodEntry? entry;
  final DateTime initialDate;
  @override
  State<FoodEditor> createState() => _FoodEditorState();
}

class _FoodEditorState extends State<FoodEditor> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _people = TextEditingController();
  final _picker = ImagePicker();
  final _repository = FoodRepository();
  late String _meal;
  late DateTime _date;
  String? _imageUrl;
  XFile? _imageFile;
  Uint8List? _imageBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _name.text = entry?.name ?? '';
    _amount.text = entry == null ? '0.00' : entry.amount.toStringAsFixed(2);
    _people.text = (entry?.people ?? 1).toString();
    _meal = entry?.meal ?? 'เช้า';
    _date = entry?.date ?? widget.initialDate;
    _imageUrl = entry?.imageUrl;
    _imageBytes = entry?.imageBytes;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _people.dispose();
    super.dispose();
  }

  Future<void> _chooseImage() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('เลือกรูปจากคลังภาพ'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('ถ่ายรูปอาหาร'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_imageUrl != null || _imageBytes != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('นำรูปออก'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imageUrl = null;
                    _imageBytes = null;
                    _imageFile = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (file != null) {
        setState(() {
          _imageFile = file;
          _imageBytes = null;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เปิดรูปภาพไม่สำเร็จบนอุปกรณ์นี้')),
        );
      }
    }
  }

  Future<void> _chooseDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('th'),
    );
    if (value != null) setState(() => _date = value);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final old = widget.entry;
    try {
      final bytes = _imageFile == null ? null : await _imageFile!.readAsBytes();
      final entry = FoodEntry(
        id:
            old?.id ??
            (AppConfig.hasSupabase
                ? newUuid()
                : DateTime.now().microsecondsSinceEpoch.toString()),
        name: _name.text.trim(),
        meal: _meal,
        date: _date,
        amount: double.parse(_amount.text.trim()),
        people: int.parse(_people.text.trim()),
        imageUrl: _imageFile == null ? _imageUrl : null,
        imageBytes: AppConfig.hasSupabase ? null : (bytes ?? _imageBytes),
      );
      final saved = await _repository.save(
        entry,
        isNew: old == null,
        previousImageUrl: old?.imageUrl,
        newImageBytes: AppConfig.hasSupabase ? bytes : null,
        imageName: _imageFile?.name,
      );
      if (mounted) Navigator.pop(context, saved);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final entry = widget.entry;
    if (entry == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบรายการนี้?'),
        content: Text('ต้องการลบ “${entry.name}” หรือไม่'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _saving = true);
    try {
      await _repository.delete(entry);
      if (mounted) Navigator.pop(context, FoodDeleted(entry));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ลบไม่สำเร็จ: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.entry == null
            ? 'Food Tracker (เพิ่ม)'
            : 'Food Tracker (แก้ไข/ลบ)',
      ),
      titleSpacing: 0,
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
        children: [
          GestureDetector(
            onTap: _chooseImage,
            child: Container(
              height: 102,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _imageFile != null
                  ? FutureBuilder<Uint8List>(
                      future: _imageFile!.readAsBytes(),
                      builder: (_, snap) => snap.hasData
                          ? Image.memory(
                              snap.data!,
                              height: 102,
                              fit: BoxFit.contain,
                            )
                          : const CircularProgressIndicator(),
                    )
                  : _imageBytes != null
                  ? Image.memory(_imageBytes!, height: 102, fit: BoxFit.contain)
                  : _imageUrl != null
                  ? Image.network(
                      _imageUrl!,
                      height: 102,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => _camera(),
                    )
                  : _camera(),
            ),
          ),
          const SizedBox(height: 10),
          _label('กินอะไร'),
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(hintText: 'เช่น KFC, Pizza'),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'กรุณากรอกชื่ออาหาร' : null,
          ),
          const SizedBox(height: 16),
          _label('กินมื้อไหน'),
          Row(
            children: FoodEntry.meals
                .map(
                  (meal) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: ChoiceChip(
                        label: Center(child: Text(meal)),
                        selected: _meal == meal,
                        showCheckmark: false,
                        selectedColor: AppColors.green,
                        backgroundColor: const Color(0xFFAAAAAA),
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: _meal == meal
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        shape: const StadiumBorder(),
                        onSelected: (_) => setState(() => _meal = meal),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          _label('กินไปเท่าไหร่'),
          TextFormField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'เช่น 299.50'),
            validator: (v) => double.tryParse(v?.trim() ?? '') == null
                ? 'กรุณากรอกจำนวนเงิน'
                : null,
          ),
          const SizedBox(height: 12),
          _label('กินกันกี่คน'),
          TextFormField(
            controller: _people,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'เช่น 3'),
            validator: (v) =>
                int.tryParse(v?.trim() ?? '') == null ||
                    int.parse(v!.trim()) < 1
                ? 'กรุณากรอกจำนวนคน'
                : null,
          ),
          const SizedBox(height: 12),
          _label('กินไปวันไหน'),
          InkWell(
            onTap: _chooseDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(dateKey(_date)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                _saving
                    ? 'กำลังบันทึก...'
                    : widget.entry == null
                    ? 'บันทึก'
                    : 'บันทึกแก้ไข',
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _saving
                  ? null
                  : widget.entry == null
                  ? () => Navigator.pop(context)
                  : _delete,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(widget.entry == null ? 'ยกเลิก' : 'ลบข้อมูล'),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _label(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(value, style: const TextStyle(fontSize: 14)),
  );
  Widget _camera() => const Icon(
    Icons.add_a_photo_outlined,
    color: Color(0xFF9E9E9E),
    size: 66,
  );
}

class FoodDeleted {
  const FoodDeleted(this.entry);
  final FoodEntry entry;
}
