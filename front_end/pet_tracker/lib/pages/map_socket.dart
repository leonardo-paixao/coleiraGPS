import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:pet_tracker/components/constants.dart';
import 'package:pet_tracker/components/get_socket.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapSocket extends StatefulWidget {
  const MapSocket({super.key});

  @override
  State<MapSocket> createState() => _MapSocketState();
}

class _MapSocketState extends State<MapSocket> {
  late IO.Socket socket;
  late Map<MarkerId, Marker> _markers;
  Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _cameraPosition =
      CameraPosition(target: LatLng(-9.19416, -40.1096));

  @override
  void initState() {
    super.initState();
    _markers = <MarkerId, Marker>{};
    _markers.clear();
    initSocket();
  }

  Future<void> initSocket() async {
    try {
      socket =
          IO.io("https://bdfa-170-78-23-134.sa.ngrok.io/", <String, dynamic>{
            'transports': ['webSocket'],
            'autoConnect': true,
          });


      socket.connect();
      socket.on("pet_localization", (data) async {
        var latLng = jsonDecode(data);
        print(data);
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(latLng["lat"], latLng["lng"]), zoom: 19),
          ),
        );

        var image = BitmapDescriptor.defaultMarker;

        Marker marker = Marker(
          markerId: MarkerId("_id"),
          icon: image,
          position: LatLng(
            latLng["lat"],
            latLng["lng"],
          ),
        );

        setState(() {
          _markers[MarkerId("_id")] = marker;
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Pet Tracking',
                style: TextStyle(color: Colors.white))),
        body: GoogleMap(
          initialCameraPosition: _cameraPosition,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: Set<Marker>.of(_markers.values),
        ));
  }
}
