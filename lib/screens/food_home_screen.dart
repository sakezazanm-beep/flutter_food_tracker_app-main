import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../core/app_theme.dart';
import '../models/food_entry.dart';
import '../services/food_repository.dart';
import '../widgets/meal_helpers.dart';
import '../widgets/burger_glyph.dart';
import 'food_editor_screen.dart';
import 'summary_screen.dart';

class FoodHome extends StatefulWidget {
  const FoodHome({super.key});
  @override
  State<FoodHome> createState() => _FoodHomeState();
}

class _FoodHomeState extends State<FoodHome> {
  static const _homeRed = Color(0xFFD22B00);
  final _search = TextEditingController();
  final _repository = FoodRepository();
  late List<FoodEntry> _entries;
  late DateTime _selectedDate;
  String _mealFilter = 'ทั้งหมด';
  bool _loading = false;
  String? _loadError;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _entries = [];
    _loadEntries();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final entries = supabaseClient == null
          ? await _repository.initializeLocalEntries()
          : await _repository.fetchEntries();
      if (mounted) setState(() => _entries = entries);
    } catch (_) {
      if (mounted) {
        setState(() => _loadError = 'โหลดรายการอาหารไม่ได้ กรุณาลองใหม่');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<FoodEntry> get _visibleEntries => _entries.where((entry) {
    final matchesMeal = _mealFilter == 'ทั้งหมด' || entry.meal == _mealFilter;
    final matchesSearch = entry.name.toLowerCase().contains(
      _search.text.trim().toLowerCase(),
    );
    final matchesDate = dateKey(entry.date) == dateKey(_selectedDate);
    return matchesMeal && matchesSearch && matchesDate;
  }).toList();

  Future<void> _openEditor([FoodEntry? entry]) async {
    final result = await Navigator.of(context).push<Object>(
      MaterialPageRoute(
        builder: (_) => FoodEditor(entry: entry, initialDate: _selectedDate),
      ),
    );
    if (!mounted || result == null) return;
    if (result is FoodDeleted) {
      if (supabaseClient != null) return _loadEntries();
      setState(
        () => _entries.removeWhere((item) => item.id == result.entry.id),
      );
      return;
    }
    if (result is! FoodEntry) return;
    if (supabaseClient != null) {
      await _loadEntries();
    } else {
      setState(() {
        final index = _entries.indexWhere((item) => item.id == result.id);
        if (index < 0) {
          _entries.insert(0, result);
        } else {
          _entries[index] = result;
        }
      });
    }
    if (entry == null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('เพิ่มรายการอาหารแล้ว')));
    }
  }

  Future<void> _deleteEntry(FoodEntry entry) async {
    final confirm = await showDialog<bool>(
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
    if (confirm != true) return;
    try {
      await _repository.delete(entry);
      if (supabaseClient != null) {
        await _loadEntries();
      } else if (mounted) {
        setState(() => _entries.removeWhere((item) => item.id == entry.id));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ลบรายการไม่สำเร็จ')));
      }
    }
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('th'),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final entries = _visibleEntries;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _homeRed,
        title: const Text(
          'Food Tracker',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        toolbarHeight: 46,
        actions: [
          if (supabaseClient != null)
            IconButton(
              tooltip: 'ออกจากระบบ',
              onPressed: () => supabaseClient!.auth.signOut(),
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: _tab == 1
          ? SummaryScreen(entries: entries, date: _selectedDate)
          : Column(
              children: [
                _header(entries.length),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'ค้นหาเมนูอาหาร',
                      prefixIcon: Icon(Icons.search),
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    children: ['ทั้งหมด', ...FoodEntry.meals]
                        .map(
                          (meal) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: _MealFilterButton(
                              label: meal,
                              selected: _mealFilter == meal,
                              onTap: () => setState(() => _mealFilter = meal),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (_loadError != null)
                  MaterialBanner(
                    content: Text(_loadError!),
                    actions: [
                      TextButton(
                        onPressed: _loadEntries,
                        child: const Text('ลองใหม่'),
                      ),
                    ],
                  ),
                if (_loading)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.red,
                  ),
                Expanded(
                  child: entries.isEmpty
                      ? _empty()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                          itemCount: entries.length,
                          itemBuilder: (context, index) => FoodCard(
                            entry: entries[index],
                            onTap: () => _openEditor(entries[index]),
                            onDelete: () => _deleteEntry(entries[index]),
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openEditor(),
              backgroundColor: _homeRed,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('เพิ่มอาหาร'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              extendedPadding: const EdgeInsets.symmetric(horizontal: 18),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        backgroundColor: const Color(0xFFFCEAE6),
        indicatorColor: const Color(0xFFFFD6CE),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant),
            label: 'บันทึกอาหาร',
          ),
          NavigationDestination(icon: Icon(Icons.insights), label: 'สรุป'),
        ],
      ),
    );
  }

  Widget _header(int count) => Container(
    color: _homeRed,
    padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'วันนี้กินอะไรบ้าง?',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 3),
              Text(
                dateKey(_selectedDate).split('-').reversed.join('/'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.white.withValues(alpha: .16),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _chooseDate,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.calendar_month, color: Colors.white, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Text(
                'รายการ',
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _empty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.no_food_outlined,
            size: 58,
            color: Color(0xFFCEB9AF),
          ),
          const SizedBox(height: 12),
          const Text(
            'ยังไม่มีรายการอาหาร',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const Text(
            'แตะ “เพิ่มอาหาร” เพื่อเริ่มบันทึกมื้อของคุณ',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _MealFilterButton extends StatelessWidget {
  const _MealFilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: label,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 31,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF348A5B) : Colors.transparent,
            border: Border.all(
              color: selected
                  ? const Color(0xFF348A5B)
                  : const Color(0xFFE0B9B1),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check, size: 15, color: Colors.white),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });
  final FoodEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 10),
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: SizedBox(width: 62, height: 62, child: _image()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(
                        mealIcon(entry.meal),
                        size: 14,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        entry.meal,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: Colors.black38,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateKey(entry.date).split('-').reversed.join('/'),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 21),
              onSelected: (value) {
                if (value == 'delete') {
                  onDelete();
                } else {
                  onTap();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('แก้ไข')),
                PopupMenuItem(value: 'delete', child: Text('ลบ')),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _image() {
    if (entry.imageBytes != null) {
      return Image.memory(entry.imageBytes!, fit: BoxFit.cover);
    }
    if (entry.imageUrl != null) {
      return Image.network(
        entry.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _burger(),
      );
    }
    return _burger();
  }

  Widget _burger() => Container(
    color: const Color(0xFFFFE5DB),
    alignment: Alignment.center,
    child: const BurgerGlyph(),
  );
}
