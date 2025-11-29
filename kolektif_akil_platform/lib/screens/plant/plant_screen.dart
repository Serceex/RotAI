import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plant_provider.dart';
import '../../providers/auth_provider.dart';

class PlantScreen extends StatefulWidget {
  const PlantScreen({super.key});

  @override
  State<PlantScreen> createState() => _PlantScreenState();
}

class _PlantScreenState extends State<PlantScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plantProvider = Provider.of<PlantProvider>(context, listen: false);
      plantProvider.loadPlant();
    });
  }

  Future<void> _waterPlant() async {
    final plantProvider = Provider.of<PlantProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş yapmanız gerekiyor')),
      );
      return;
    }

    try {
      await plantProvider.waterPlant(authProvider.currentUser!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitki sulandı! 🌱')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ortak Sanal Bitki'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<PlantProvider>(
        builder: (context, plantProvider, _) {
          final plant = plantProvider.plant;

          if (plant == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _PlantIcon(waterLevel: plant.waterLevel),
                        const SizedBox(height: 24),
                        Text(
                          plant.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ortak Sorumluluk',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Su Seviyesi',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: plant.waterLevel / 100,
                          minHeight: 24,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getWaterColor(plant.waterLevel),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${plant.waterLevel.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sağlık Durumu',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: plant.healthLevel / 100,
                          minHeight: 24,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getHealthColor(plant.healthLevel),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${plant.healthLevel.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: plantProvider.isWatering ? null : _waterPlant,
                  icon: plantProvider.isWatering
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.water_drop),
                  label: Text(plantProvider.isWatering ? 'Sulanıyor...' : 'Sula'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Nasıl Çalışır?',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Analiz rotası oluşturduğunuzda, oylamaya katıldığınızda veya mekan geri bildirimi verdiğinizde "Sula" hakkı kazanırsınız. Bitkiyi sulayarak topluluğa katkıda bulunun!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getWaterColor(double level) {
    if (level < 30) return Colors.red;
    if (level < 60) return Colors.orange;
    return Colors.blue;
  }

  Color _getHealthColor(double level) {
    if (level < 30) return Colors.red;
    if (level < 60) return Colors.orange;
    return Colors.green;
  }
}

class _PlantIcon extends StatelessWidget {
  final double waterLevel;

  const _PlantIcon({required this.waterLevel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green[50],
          ),
        ),
        Icon(
          Icons.eco,
          size: 80,
          color: _getPlantColor(waterLevel),
        ),
      ],
    );
  }

  Color _getPlantColor(double level) {
    if (level < 30) return Colors.brown;
    if (level < 60) return Colors.orange[700]!;
    return Colors.green[700]!;
  }
}

