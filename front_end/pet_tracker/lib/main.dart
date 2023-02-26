// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:pet_tracker/my_app.dart';
import 'package:pet_tracker/pages/map_socket.dart';
import 'package:pet_tracker/pages/tracking_page.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket socket = IO.io('http://d89f-200-133-3-253.sa.ngrot.io/');
void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: MapSocket()));
}
