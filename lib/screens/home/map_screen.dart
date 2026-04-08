import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../../providers/post_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/common/wr_logo.dart';
import '../../config/app_router.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng _center = const LatLng(10.776889, 106.700806);
  double _radiusKm = 3.0;
  bool _nearbyOnly = false;

  Future<void> _openGoogleMapsDirection(double lat, double lng) async {
    final url = Uri.parse('comgooglemaps://?saddr=&daddr=$lat,$lng&directionsmode=driving');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      final webUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở Google Maps')),
        );
      }
    }
  }

  void _showMarkerMenu(BuildContext context, dynamic p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(p.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Chi tiết'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRouter.postDetail, arguments: p.id);
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.directions),
                    label: const Text('Chỉ đường'),
                    onPressed: () {
                      Navigator.pop(context);
                      _openGoogleMapsDirection(p.lat!, p.lng!);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _locateMe() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos == null) return;
    setState(() {
      _center = LatLng(pos.latitude, pos.longitude);
    });
    _controller?.animateCamera(CameraUpdate.newLatLngZoom(_center, 14));
  }

  double _distanceKm(LatLng p1, LatLng p2) {
    const r = 6371.0; // km
    final dLat = (p2.latitude - p1.latitude) * math.pi / 180.0;
    final dLon = (p2.longitude - p1.longitude) * math.pi / 180.0;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(p1.latitude * math.pi / 180.0) * math.cos(p2.latitude * math.pi / 180.0) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostProvider>().posts;
    final markers = <Marker>{};
    for (final p in posts) {
      if (p.lat != null && p.lng != null) {
        final ll = LatLng(p.lat!, p.lng!);
        if (_nearbyOnly) {
          final d = _distanceKm(_center, ll);
          if (d > _radiusKm) continue;
        }
        markers.add(Marker(
          markerId: MarkerId(p.id),
          position: ll,
          onTap: () {
            _showMarkerMenu(context, p);
          },
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Row(children: [WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)), const SizedBox(width: 8), const Text('Bản đồ căn hộ')])),
      body: Stack(children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _center, zoom: 12),
          onMapCreated: (controller) => _controller = controller,
          markers: markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Text('Chỉ quanh tôi'), Switch(value: _nearbyOnly, onChanged: (v) => setState(() => _nearbyOnly = v))]),
                const SizedBox(height: 8),
                const Text('Bán kính (km)'),
                Slider(value: _radiusKm, min: 1, max: 10, divisions: 9, label: '${_radiusKm.toStringAsFixed(0)} km', onChanged: (v) => setState(() => _radiusKm = v)),
                ElevatedButton(onPressed: _locateMe, child: const Text('Định vị tôi')),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
