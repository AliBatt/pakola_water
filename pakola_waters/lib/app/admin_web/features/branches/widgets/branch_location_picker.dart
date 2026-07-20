import 'dart:async';
import 'dart:convert';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:models/models.dart';

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.displayName,
    required this.location,
  });

  final String displayName;
  final GeoLocation location;
}

/// Interactive map picker with address search (OpenStreetMap / Nominatim).
class BranchLocationPicker extends StatefulWidget {
  const BranchLocationPicker({
    super.key,
    this.initial,
    this.initialQuery,
    required this.onChanged,
    this.onAddressSelected,
  });

  final GeoLocation? initial;
  final String? initialQuery;
  final ValueChanged<GeoLocation> onChanged;
  final ValueChanged<String>? onAddressSelected;

  static const GeoLocation defaultCenter = GeoLocation(
    latitude: 24.8607,
    longitude: 67.0011,
  ); // Karachi

  @override
  State<BranchLocationPicker> createState() => _BranchLocationPickerState();
}

class _BranchLocationPickerState extends State<BranchLocationPicker> {
  late LatLng _position;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  Timer? _debounce;
  bool _isSearching = false;
  String? _searchError;
  List<PlaceSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    final initial = widget.initial ?? BranchLocationPicker.defaultCenter;
    _position = LatLng(initial.latitude, initial.longitude);
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _updatePosition(LatLng value, {String? address}) {
    setState(() {
      _position = value;
      if (address != null) {
        _searchController.text = address;
      }
    });
    widget.onChanged(
      GeoLocation(latitude: value.latitude, longitude: value.longitude),
    );
    if (address != null) {
      widget.onAddressSelected?.call(address);
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < 3) {
      setState(() {
        _suggestions = [];
        _searchError = null;
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _searchPlaces(trimmed);
    });
  }

  Future<void> _searchPlaces(String query) async {
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': query,
          'format': 'json',
          'addressdetails': '1',
          'limit': '6',
        },
      );

      final response = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
          'User-Agent': 'PakolaWatersAdmin/1.0 (branch-location-picker)',
        },
      );

      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() {
          _isSearching = false;
          _searchError = 'Could not search locations right now';
          _suggestions = [];
        });
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        setState(() {
          _isSearching = false;
          _suggestions = [];
        });
        return;
      }

      final results = decoded
          .whereType<Map<String, dynamic>>()
          .map((item) {
            final lat = double.tryParse('${item['lat']}');
            final lon = double.tryParse('${item['lon']}');
            final name = item['display_name'] as String?;
            if (lat == null || lon == null || name == null) return null;
            return PlaceSuggestion(
              displayName: name,
              location: GeoLocation(latitude: lat, longitude: lon),
            );
          })
          .whereType<PlaceSuggestion>()
          .toList();

      setState(() {
        _isSearching = false;
        _searchError = results.isEmpty ? 'No matching places found' : null;
        _suggestions = results;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _searchError = 'Could not search locations right now';
        _suggestions = [];
      });
    }
  }

  void _selectSuggestion(PlaceSuggestion suggestion) {
    final point = LatLng(
      suggestion.location.latitude,
      suggestion.location.longitude,
    );
    _updatePosition(point, address: suggestion.displayName);
    setState(() => _suggestions = []);
    _searchFocus.unfocus();
    _mapController.move(point, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Branch location',
          style: context.texts.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Search an address, then fine-tune the pin on the map',
          style: context.texts.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: 'Search address',
            hintText: 'e.g. Gulshan-e-Iqbal, Karachi',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (_searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          _debounce?.cancel();
                          _searchController.clear();
                          setState(() {
                            _suggestions = [];
                            _searchError = null;
                            _isSearching = false;
                          });
                        },
                        icon: const Icon(Icons.close),
                      )),
          ),
        ),
        if (_searchError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _searchError!,
            style: context.texts.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Material(
            color: context.colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              side: BorderSide(color: context.colors.outlineVariant),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.place_outlined,
                      color: context.colors.primary,
                    ),
                    title: Text(
                      item.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectSuggestion(item),
                  );
                },
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: SizedBox(
            height: 240,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _position,
                initialZoom: 13,
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
          'Lat: ${_position.latitude.toStringAsFixed(5)}, '
          'Lng: ${_position.longitude.toStringAsFixed(5)}',
          style: context.texts.bodySmall,
        ),
      ],
    );
  }
}
