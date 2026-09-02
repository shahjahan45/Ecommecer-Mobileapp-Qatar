import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_theme_context.dart';
import '../../../models/saved_address.dart';

class MapLocationPickerPage extends StatefulWidget {
  final MapLocationData? initialLocation;

  const MapLocationPickerPage({
    super.key,
    this.initialLocation,
  });

  @override
  State<MapLocationPickerPage> createState() => _MapLocationPickerPageState();
}

class _MapLocationPickerPageState extends State<MapLocationPickerPage> {
  static const LatLng _doha = LatLng(25.2854473, 51.5310398);

  // geocoding 5.x moved the old top-level helpers behind a Geocoding instance.
  // Keep this instance local to the map picker so normal address/profile tests
  // do not touch the native geocoding platform unless the map flow is opened.
  final Geocoding _geocoding = Geocoding();

  late final TextEditingController _searchController;
  GoogleMapController? _mapController;
  late LatLng _selected;
  String _resolvedLabel = 'Move the pin or tap the map to choose a location';
  bool _searching = false;
  bool _resolving = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selected = widget.initialLocation == null
        ? _doha
        : LatLng(
            widget.initialLocation!.latitude,
            widget.initialLocation!.longitude,
          );
    final existing = widget.initialLocation?.displayLabel.trim();
    if (existing != null && existing.isNotEmpty) {
      _resolvedLabel = existing;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final rawQuery = _searchController.text.trim();
    if (rawQuery.isEmpty || _searching) return;
    final query = rawQuery.toLowerCase().contains('qatar')
        ? rawQuery
        : '$rawQuery, Qatar';
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _searching = true);

    try {
      final results = await _geocoding.locationFromAddress(query);
      if (results.isEmpty) throw StateError('No location found');
      final target = LatLng(results.first.latitude, results.first.longitude);
      await _select(target, animate: true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('We could not find that place. Try an area, street or landmark.'),
          ),
        );
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _select(LatLng point, {bool animate = false}) async {
    setState(() {
      _selected = point;
      _resolving = true;
      _resolvedLabel = 'Finding the selected address…';
    });

    if (animate) {
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: point, zoom: 17),
        ),
      );
    }

    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[
          place.name ?? '',
          place.street ?? '',
          place.subLocality ?? '',
          place.locality ?? '',
          place.administrativeArea ?? '',
          place.country ?? '',
        ].map((item) => item.trim()).where((item) => item.isNotEmpty).toSet().toList();
        if (mounted) {
          setState(() => _resolvedLabel = parts.join(', '));
        }
      } else if (mounted) {
        setState(() => _resolvedLabel = _coordinateLabel(point));
      }
    } catch (_) {
      if (mounted) setState(() => _resolvedLabel = _coordinateLabel(point));
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  String _coordinateLabel(LatLng point) =>
      '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';

  void _confirm() {
    Navigator.of(context).pop(
      MapLocationData(
        latitude: _selected.latitude,
        longitude: _selected.longitude,
        resolvedAddress: _resolvedLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.dcxScheme;
    return Scaffold(
      key: const Key('map-location-picker-page'),
      appBar: AppBar(
        title: const Text('Select map location'),
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
                key: const Key('google-map-location-picker'),
                initialCameraPosition: CameraPosition(
                  target: _selected,
                  zoom: widget.initialLocation == null ? 12.5 : 17,
                ),
                markers: <Marker>{
                  Marker(
                    markerId: const MarkerId('delivery-pin'),
                    position: _selected,
                    draggable: true,
                    onDragEnd: _select,
                  ),
                },
                onMapCreated: (controller) => _mapController = controller,
                onTap: _select,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 12,
              child: SafeArea(
                bottom: false,
                child: Material(
                  elevation: 4,
                  shadowColor: Colors.black.withValues(alpha: .10),
                  color: context.dcxSurface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('map-location-search-field'),
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _search(),
                          decoration: const InputDecoration(
                            hintText: 'Search area, street or landmark',
                            prefixIcon: Icon(Icons.search_rounded),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton.filledTonal(
                          key: const Key('map-location-search-button'),
                          onPressed: _searching ? null : _search,
                          icon: _searching
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.arrow_forward_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: Material(
                  color: context.dcxSurface,
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: .12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    side: BorderSide(color: context.dcxBorder),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.location_on_rounded,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected location',
                                    style: TextStyle(
                                      color: context.dcxTextTertiary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 180),
                                    child: Text(
                                      _resolvedLabel,
                                      key: ValueKey<String>(_resolvedLabel),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: context.dcxTextPrimary,
                                        fontSize: 12,
                                        height: 1.35,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _coordinateLabel(_selected),
                                    style: TextStyle(
                                      color: context.dcxTextTertiary,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 13),
                        SizedBox(
                          height: 50,
                          child: FilledButton.icon(
                            key: const Key('use-map-location-button'),
                            onPressed: _resolving ? null : _confirm,
                            icon: const Icon(Icons.check_circle_outline_rounded),
                            label: const Text('Use this location'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
