import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionStatus extends StatefulWidget {
  const ConnectionStatus({super.key});

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  // Default to a connected status to avoid showing the offline banner incorrectly on startup.
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.wifi];

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await Connectivity().checkConnectivity();
    } catch (e) {
      // Handle error, e.g., log it
      return;
    }

    if (!mounted) {
      return;
    }

    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_connectionStatus.contains(ConnectivityResult.none) && _connectionStatus.length == 1) {
      return Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.error.withAlpha(204), // 0.8 * 255 = 204
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: const Text(
          'You are currently offline',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
