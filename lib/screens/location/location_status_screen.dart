import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/location_service.dart';

class LocationStatusScreen extends StatefulWidget {
  const LocationStatusScreen({super.key});

  @override
  State<LocationStatusScreen> createState() => _LocationStatusScreenState();
}

class _LocationStatusScreenState extends State<LocationStatusScreen> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  bool _isLoading = false;
  String? _mapError;

  @override
  void initState() {
    super.initState();
    // Google Maps hatasını yakalamak için bir süre bekle
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _mapController == null) {
        // Harita yüklenemediyse hata mesajı göster
        setState(() {
          _mapError = 'Google Maps API anahtarı yapılandırılmamış olabilir.\n'
              'Lütfen SHA-1 fingerprint\'i Google Cloud Console\'a ekleyin.';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canlı Mekan Durumu'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _mapError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Harita Yüklenemedi',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _mapError!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _mapError = null;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  )
                : GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(41.0082, 28.9784), // Istanbul default
                      zoom: 12,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    onTap: (LatLng location) {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                    markers: _selectedLocation != null
                        ? {
                            Marker(
                              markerId: const MarkerId('selected'),
                              position: _selectedLocation!,
                            ),
                          }
                        : {},
                    onCameraMoveStarted: () {
                      // Harita yüklenmeye başladığında hata mesajını temizle
                      if (_mapError != null) {
                        setState(() {
                          _mapError = null;
                        });
                      }
                    },
                  ),
          ),
          if (_selectedLocation != null)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Seçilen Konum',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enlem: ${_selectedLocation!.latitude.toStringAsFixed(6)}\n'
                      'Boylam: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _requestLocationStatus,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.location_on),
                      label: const Text('Mekan Durumu Sorgula'),
                    ),
                  ],
                ),
              ),
            ),
          if (_selectedLocation == null)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Haritada bir konum seçin',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
        tooltip: 'Mevcut Konumum',
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      final location = LatLng(position.latitude, position.longitude);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(location, 15),
      );

      setState(() {
        _selectedLocation = location;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konum hatası: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _requestLocationStatus() async {
    if (_selectedLocation == null) return;

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement location status request
    // This would send FCM notifications to users at that location
    // and collect their feedback

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bu özellik yakında eklenecek. FCM bildirimleri ile o konumdaki kullanıcılara soru gönderilecek.',
          ),
        ),
      );
    }
  }
}

