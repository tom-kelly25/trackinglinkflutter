import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:trackinglink/constants.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(53.090191, -2.431884);
  static const LatLng destination =
      LatLng(53.06648065780936, -2.5220188383332003);

  LocationData? currentLocation;
  StreamSubscription<LocationData>? locationSubscription;

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    _getPolyline();
    _subscribeToLocationChanges();
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToLocationChanges() {
    Location location = Location();
    locationSubscription = location.onLocationChanged.listen((location) {
      setState(() {
        currentLocation = location;
      });
    });
  }

  Future<void> _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      PolylineId id = PolylineId('poly');
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.purple,
        width: 6,
        points: polylineCoordinates,
      );
      setState(() {
        polylines[id] = polyline;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              polylines: Set<Polyline>.of(polylines.values),
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  position: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                ),
                Marker(
                  markerId: const MarkerId("source"),
                  position: sourceLocation,
                ),
                Marker(
                  markerId: const MarkerId("destination"),
                  position: destination,
                ),
              },
            ),
    );
  }
}
