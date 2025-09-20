import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DeliveryMapWidget extends StatefulWidget {
  final LatLng driverLocation;
  final LatLng deliveryLocation;
  final VoidCallback? onExpandMap;

  const DeliveryMapWidget({
    super.key,
    required this.driverLocation,
    required this.deliveryLocation,
    this.onExpandMap,
  });

  @override
  State<DeliveryMapWidget> createState() => _DeliveryMapWidgetState();
}

class _DeliveryMapWidgetState extends State<DeliveryMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('driver'),
        position: widget.driverLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Haydovchi',
          snippet: 'Joriy joylashuv',
        ),
      ),
      Marker(
        markerId: const MarkerId('delivery'),
        position: widget.deliveryLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: 'Yetkazib berish manzili',
          snippet: 'Maqsad',
        ),
      ),
    };

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [widget.driverLocation, widget.deliveryLocation],
        color: Theme.of(context).colorScheme.primary,
        width: 3,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      height: 30.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _fitMapToMarkers();
              },
              initialCameraPosition: CameraPosition(
                target: widget.driverLocation,
                zoom: 12,
              ),
              markers: _markers,
              polylines: _polylines,
              mapType: MapType.normal,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
          _buildMapOverlay(context),
        ],
      ),
    );
  }

  Widget _buildMapOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Stack(
          children: [
            // Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: colorScheme.primary,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Jonli kuzatuv',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (widget.onExpandMap != null) {
                          widget.onExpandMap!();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: CustomIconWidget(
                          iconName: 'fullscreen',
                          color: colorScheme.primary,
                          size: 4.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.9),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 3.w,
                            height: 3.w,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Haydovchi',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 3.w,
                            height: 3.w,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Manzil',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Refresh button
            Positioned(
              top: 12.h,
              right: 3.w,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _refreshDriverLocation();
                  },
                  icon: CustomIconWidget(
                    iconName: 'refresh',
                    color: colorScheme.primary,
                    size: 5.w,
                  ),
                  tooltip: 'Joylashuvni yangilash',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fitMapToMarkers() {
    if (_mapController != null && _markers.isNotEmpty) {
      final bounds = _calculateBounds();
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    }
  }

  LatLngBounds _calculateBounds() {
    final lats = _markers.map((m) => m.position.latitude).toList();
    final lngs = _markers.map((m) => m.position.longitude).toList();

    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _refreshDriverLocation() {
    // Simulate driver location update
    setState(() {
      _initializeMarkers();
    });
    _fitMapToMarkers();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
