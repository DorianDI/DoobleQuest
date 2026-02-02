import 'dart:convert';
import 'package:http/http.dart' as http;

class PatientService {
  static const String _baseUrl = 'https://health.shrp.dev';

  // Récupérer la liste de tous les patients
  static Future<Map<String, dynamic>> getAllPatients() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/items/people'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'], // L'API renvoie { "data": [...] }
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  // Récupérer les détails d'un patient spécifique
  static Future<Map<String, dynamic>> getPatientById(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/items/people/$patientId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'], // L'API renvoie { "data": {...} }
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }
}