import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:models/models.dart';
import 'package:shared_widgets/shared_widgets.dart';

/// Map pin + "Use current location" for customer delivery address.
class CustomerLocationPicker extends StatefulWidget {
  const CustomerLocationPicker({
    super.key,
    this.initial,
    required this.onChanged,
    this.onAddressResolved,
  });

  final GeoLocation? initial;
  final ValueChanged<GeoLocation> onChanged;
  final ValueChanged<String>? onAddressResolved;

  static const GeoLocation defaultCenter = GeoLocation(
    latitude: 24.8607,
    longitude: 67.0011,
  );

  @override
  State<CustomerLocationPicker> createState() => _CustomerLocationPickerState();
}

class _CustomerLocationPickerState extends State<CustomerLocationPicker> {
  late LatLng _position;
  final MapController _mapController = MapController();
  bool _locating = false;
  bool _resolvingAddress = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial ?? CustomerLocationPicker.defaultCenter;
    _position = LatLng(initial.latitude, initial.longitude);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _useCurrentLocation();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _updatePosition(LatLng value) async {
    setState(() => _position = value);
    widget.onChanged(
      GeoLocation(latitude: value.latitude, longitude: value.longitude),
    );
    await _resolveAddress(
      GeoLocation(latitude: value.latitude, longitude: value.longitude),
    );
  }

  Future<void> _resolveAddress(GeoLocation location) async {
    setState(() => _resolvingAddress = true);
    final address = await reverseGeocode(
      location,
      userAgent: 'PakolaWatersCustomer/1.0 (signup-location)',
    );
    if (!mounted) return;
    setState(() => _resolvingAddress = false);
    widget.onAddressResolved?.call(
      address ??
          'Lat ${location.latitude.toStringAsFixed(5)}, '
              'Lng ${location.longitude.toStringAsFixed(5)}',
    );
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locating = false;
          _locationError = 'Location services are disabled';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locating = false;
          _locationError = 'Location permission denied';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;

      final point = LatLng(position.latitude, position.longitude);
      await _updatePosition(point);
      _mapController.move(point, 16);
      setState(() => _locating = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locating = false;
        _locationError = 'Could not get current location';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Delivery location',
          style: context.texts.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Use your current location, then fine-tune the pin on the map.',
          style: context.texts.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: _locating ? null : _useCurrentLocation,
          icon: _locating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: Text(_locating ? 'Locating…' : 'Use current location'),
        ),
        if (_locationError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _locationError!,
            style: context.texts.bodySmall?.copyWith(
              color: context.colors.error,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: SizedBox(
            height: 220,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _position,
                initialZoom: 14,
                onTap: (tapPosition, point) => _updatePosition(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.pakolawaters.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _position,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on,
                        color: context.colors.error,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _resolvingAddress
              ? 'Resolving address…'
              : 'Lat: ${_position.latitude.toStringAsFixed(5)}, '
                  'Lng: ${_position.longitude.toStringAsFixed(5)}',
          style: context.texts.bodySmall,
        ),
      ],
    );
  }
}
