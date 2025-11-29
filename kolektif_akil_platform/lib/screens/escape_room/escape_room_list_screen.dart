import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/escape_room.dart';
import '../../services/escape_room_service.dart';
import '../../services/room_question_service.dart';
import '../../services/gemini_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/categories.dart';
import '../../config/api_config.dart';
import 'escape_room_play_screen.dart';

class EscapeRoomListScreen extends StatefulWidget {
  const EscapeRoomListScreen({super.key});

  @override
  State<EscapeRoomListScreen> createState() => _EscapeRoomListScreenState();
}

class _EscapeRoomListScreenState extends State<EscapeRoomListScreen> {
  final EscapeRoomService _roomService = EscapeRoomService();
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karar Escape Room'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateRoomDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Kategori filtresi
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(
                  label: 'Tümü',
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                ...Categories.all.map((category) => _CategoryChip(
                      label: category.name,
                      icon: category.icon,
                      isSelected: _selectedCategory == category.id,
                      onTap: () => setState(() => _selectedCategory = category.id),
                    )),
              ],
            ),
          ),
          // Room listesi
          Expanded(
            child: StreamBuilder<List<EscapeRoom>>(
              stream: _roomService.getRooms(category: _selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }

                final rooms = snapshot.data ?? [];
                if (rooms.isEmpty) {
                  return const Center(
                    child: Text('Henüz oda yok. Yeni oda oluşturun!'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return _RoomCard(
                      room: room,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EscapeRoomPlayScreen(room: room),
                          ),
                        );
                      },
                      onDelete: () => _deleteRoom(room),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateRoomDialog() async {
    String? selectedCategory;
    DifficultyLevel? selectedDifficulty = DifficultyLevel.medium;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CreateRoomDialog(
        selectedCategory: selectedCategory,
        selectedDifficulty: selectedDifficulty,
      ),
    );

    if (result != null && mounted) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUser?.id;
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Giriş yapmanız gerekiyor')),
          );
          return;
        }

        final category = result['category'] as String;
        final difficulty = result['difficulty'] as DifficultyLevel;

        // AI ile soru oluştur
        final questionService = RoomQuestionService(
          geminiService: GeminiService(apiKey: ApiConfig.geminiApiKey),
        );
        final decision = await questionService.generateQuestionForCategory(
          category,
          difficulty,
        );

        // Escape room oluştur
        final room = EscapeRoom(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '${Categories.getById(category)?.name ?? "Oda"} - ${difficulty.label}',
          question: decision.question,
          optionA: decision.optionA ?? 'Seçenek A',
          optionB: decision.optionB ?? 'Seçenek B',
          difficulty: difficulty,
          category: category,
          createdAt: DateTime.now(),
        );

        await _roomService.createRoom(room);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Oda oluşturuldu!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteRoom(EscapeRoom room) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odayı Sil'),
        content: const Text('Bu odayı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _roomService.deleteRoom(room.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Oda silindi')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e')),
          );
        }
      }
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Text(icon!),
              const SizedBox(width: 4),
            ],
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final EscapeRoom room;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RoomCard({
    required this.room,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(room.title),
        subtitle: Text(
          '${room.difficulty.label} • ${room.difficulty.timeLimit ~/ 60} dk • ${room.difficulty.hintCount} ipucu',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _CreateRoomDialog extends StatefulWidget {
  final String? selectedCategory;
  final DifficultyLevel? selectedDifficulty;

  const _CreateRoomDialog({
    required this.selectedCategory,
    required this.selectedDifficulty,
  });

  @override
  State<_CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<_CreateRoomDialog> {
  late String? _selectedCategory;
  late DifficultyLevel? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedDifficulty = widget.selectedDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Oda Oluştur'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kategori Seçin:'),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: Categories.all.length,
                  itemBuilder: (context, index) {
                    final category = Categories.all[index];
                    final isSelected = _selectedCategory == category.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = category.id),
                      child: Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(category.icon, style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 8),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text('Zorluk Seviyesi:'),
              const SizedBox(height: 12),
              ...DifficultyLevel.values.map((level) {
                return RadioListTile<DifficultyLevel>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(level.label),
                  subtitle: Text(
                    '${level.timeLimit ~/ 60} dakika, ${level.hintCount} ipucu',
                  ),
                  value: level,
                  groupValue: _selectedDifficulty,
                  onChanged: (value) => setState(() => _selectedDifficulty = value),
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: (_selectedCategory != null && _selectedDifficulty != null)
              ? () {
                  Navigator.of(context).pop({
                    'category': _selectedCategory,
                    'difficulty': _selectedDifficulty,
                  });
                }
              : null,
          child: const Text('Oluştur'),
        ),
      ],
    );
  }
}

