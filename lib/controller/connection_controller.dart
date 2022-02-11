import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionController extends GetxController {
  static ConnectionController instance = Get.find();

  final Connectivity _connectivity = Connectivity();

  Rx<bool> _isOnline = false.obs;
  Rx<bool> get isOnline => _isOnline;

  /// Will start monitoring the user network connection making
  /// sure to notify any connection changes.
  Future<void> startMonitoring() async {
    await initConnectivity();
    _connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.none) {
        _isOnline.value = false;
      } else {
        await _updateConnectionStatus().then((bool isConnected) {
          _isOnline.value = isConnected;
        });
      }
    });
  }

  Future<void> initConnectivity() async {
    try {
      ConnectivityResult status = await _connectivity.checkConnectivity();
      if (status == ConnectivityResult.none) {
        _isOnline.value = false;
      } else {
        _isOnline.value = true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> _updateConnectionStatus() async {
    try {
      List<InternetAddress> result =
      await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }


}