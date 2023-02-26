import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:pet_tracker/components/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

class TrackingPage extends StatefulWidget {
  const TrackingPage({Key? key}) : super(key: key);

  @override
  State<TrackingPage> createState() => TrackingPageState();
}

class TrackingPageState extends State<TrackingPage> {
  late IO.Socket socket;
  late Map<MarkerId, Marker> _markers;

  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(-9.43847, -40.5052);
  LatLng destination = LatLng(-9.39416, -40.5096);

  //LatLng destination = LatLng(-9.39416, -40.5096);

  List<LatLng> polylineCoordinates = [];

  LocationData? currentLocation;
  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
        setState(() {

        });
      },
    );
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/source.png")
        .then(
      (Icon) {
        sourceIcon = Icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/dog.png")
        .then(
      (Icon) {
        destinationIcon = Icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/source.png")
        .then(
      (Icon) {
        currentLocationIcon = Icon;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getPolyPoints();
    setCustomMarkerIcon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Pet Tracking',
              style: TextStyle(color: Colors.white))),
      body: GoogleMap(
              initialCameraPosition: CameraPosition(
                target:
                    LatLng(sourceLocation.latitude, sourceLocation.longitude),
                zoom: 13.5,
              ),
              polylines: {
                Polyline(
                    polylineId: PolylineId('rout'),
                    points: polylineCoordinates,
                    color: primaryColor,
                    width: 6)
              },
              markers: {
                Marker(
                  markerId: MarkerId("source"),
                  icon: sourceIcon,
                  position: sourceLocation,
                ),
                Marker(
                  markerId: MarkerId("destination"),
                  icon: destinationIcon,
                  position: destination,
                ),
              },
              onMapCreated: (mapController) {
                _controller.complete(mapController);
              },
            ),
    );
  }
}
