import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Exception spécifique aux erreurs de géolocalisation pour un retour utilisateur clair.
class LocationServiceException implements Exception {
  LocationServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Résultat d'une capture de géolocalisation authentique par GPS.
class UserLocation {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.accuracy,
    this.altitude,
    this.timestamp,
  });

  final double latitude;
  final double longitude;
  final String address;
  final double? accuracy;
  final double? altitude;
  final DateTime? timestamp;
}

/// Service de géolocalisation authentique (GPS matériel + géocodage inversé).
/// Prêt pour la production (permissions Android / iOS / Web, gestion d'erreurs,
/// repli gracieux et reverse-geocoding).
class LocationService {
  const LocationService._();

  /// Récupère la position GPS réelle du smartphone du client avec géocodage inversé.
  static Future<UserLocation> getCurrentLocation({
    String? fallbackCity,
    String? fallbackDistrict,
  }) async {
    // 1. Vérification de l'activation des services de localisation
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'Les services de localisation (GPS) sont désactivés sur votre appareil. '
        'Veuillez activer le GPS pour envoyer votre localisation exacte.',
      );
    }

    // 2. Gestion des permissions
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException(
          'L\'autorisation d\'accès à la localisation a été refusée. '
          'Autorisez l\'accès pour localiser votre lieu de livraison.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'L\'accès au GPS est bloqué définitivement dans les paramètres de votre téléphone. '
        'Veuillez l\'autoriser dans les réglages de l\'application.',
      );
    }

    // 3. Acquisition de la position GPS précise
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (e) {
      debugPrint('[LocationService] getCurrentPosition timeout ou erreur: $e');
      // Tentative de récupération de la dernière position connue
      position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        throw LocationServiceException(
          'Impossible d\'obtenir le signal GPS actuellement. '
          'Vérifiez que vous êtes dans une zone dégagée et réessayez.',
        );
      }
    }

    final lat = position.latitude;
    final lng = position.longitude;

    // 4. Géocodage inversé pour obtenir l'adresse réelle (rue / quartier / ville)
    String resolvedAddress = '';
    try {
      resolvedAddress = await _reverseGeocode(lat, lng);
    } catch (e) {
      debugPrint('[LocationService] Reverse geocode error: $e');
    }

    if (resolvedAddress.trim().isEmpty) {
      final parts = [
        if (fallbackDistrict != null && fallbackDistrict.trim().isNotEmpty)
          fallbackDistrict.trim(),
        if (fallbackCity != null && fallbackCity.trim().isNotEmpty)
          fallbackCity.trim(),
      ];
      resolvedAddress = parts.isNotEmpty
          ? parts.join(', ')
          : 'Coordonnées GPS (${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)})';
    }

    return UserLocation(
      latitude: lat,
      longitude: lng,
      address: resolvedAddress,
      accuracy: position.accuracy,
      altitude: position.altitude,
      timestamp: position.timestamp,
    );
  }

  /// Reverse geocoding via l'API OpenStreetMap Nominatim
  static Future<String> _reverseGeocode(double lat, double lng) async {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
    );
    final response = await http
        .get(
          uri,
          headers: {
            'User-Agent': 'EduPay-App/1.0 (contact@edupay.africa)',
            'Accept-Language': 'fr,en',
          },
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final displayName = data['display_name'] as String?;
      final address = data['address'] as Map<String, dynamic>?;

      if (address != null) {
        final road = address['road'] ?? address['pedestrian'] ?? address['suburb'];
        final neighbourhood = address['neighbourhood'] ?? address['residential'];
        final city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'];

        final components = [
          if (road != null) road.toString(),
          if (neighbourhood != null && neighbourhood != road) neighbourhood.toString(),
          if (city != null) city.toString(),
        ];

        if (components.isNotEmpty) {
          return components.join(', ');
        }
      }

      if (displayName != null && displayName.isNotEmpty) {
        final parts = displayName.split(', ');
        return parts.take(3).join(', ');
      }
    }
    return '';
  }
}
