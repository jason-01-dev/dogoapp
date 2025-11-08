import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dogo_ai_assistant/view_models/language_view_model.dart';
import 'package:dogo_ai_assistant/view_models/settings_view_model.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng _center = const LatLng(48.8566, 2.3522);
  LatLng? _selected;
  final TextEditingController _addressController = TextEditingController();
  bool _isResolving = false;
  final MapController _mapController = MapController();
  bool _hasRequestedLocation = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    if (_hasRequestedLocation) return;
    _hasRequestedLocation = true;
    try {
      if (kIsWeb) {
        // For web, we rely on the browser's geolocation API via geolocator_web
        try {
          final pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          final newCenter = LatLng(pos.latitude, pos.longitude);
          setState(() => _center = newCenter);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              _mapController.move(newCenter, 13);
            } catch (_) {}
          });
        } catch (e) {
          debugPrint('Web geolocation error: $e');
        }
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return; // user has location services off

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return; // no permission
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      final newCenter = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _center = newCenter;
      });

      // move the map after the frame so the controller is attached
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(newCenter, 13);
        } catch (_) {
          // ignore if controller not ready
        }
      });
    } catch (e) {
      // ignore errors and keep default center
    }
  }

  Future<void> _onTapMap(TapPosition tapPosition, LatLng latlng) async {
    setState(() {
      _selected = latlng;
      _isResolving = true;
      _addressController.text = '...';
    });

    try {
      final placemarks =
          await placemarkFromCoordinates(latlng.latitude, latlng.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [p.street, p.postalCode, p.locality, p.country];
        final addr = parts.where((s) => s != null && s.isNotEmpty).join(', ');
        _addressController.text = addr;
      } else {
        _addressController.text =
            '${latlng.latitude.toStringAsFixed(5)}, ${latlng.longitude.toStringAsFixed(5)}';
      }
    } catch (e) {
      _addressController.text =
          '${latlng.latitude.toStringAsFixed(5)}, ${latlng.longitude.toStringAsFixed(5)}';
    } finally {
      setState(() {
        _isResolving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageViewModel>(context);
    final settingsVm = Provider.of<SettingsViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(language.t('choose_from_map')),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 13,
                onTap: _onTapMap,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'org.dogo.ai',
                ),
                if (_selected != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selected!,
                        width: 80,
                        height: 80,
                        child: const Icon(Icons.location_on,
                            size: 48, color: Colors.red),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(language.t('selected_address')),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: language.t('tap_on_map_to_select'),
                    suffixIcon: _isResolving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator())
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selected == null
                              ? null
                              : () async {
                                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                                  final navigator = Navigator.of(context);
                                  final addr = _addressController.text.trim();
                                  if (addr.isNotEmpty) {
                                    await settingsVm.setAddressFromMap(addr);
                                    scaffoldMessenger.showSnackBar(
                                      SnackBar(content: Text(language.t('address_saved'))),
                                    );
                                  }
                                  if (mounted) navigator.pop();
                                },
                        child: Text(language.t('confirm')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(language.t('cancel')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
