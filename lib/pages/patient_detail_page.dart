import 'package:flutter/material.dart';
import '../services/patient_service.dart';

class PatientDetailPage extends StatefulWidget {
  final String patientId;

  const PatientDetailPage({super.key, required this.patientId});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _patientData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPatientDetails();
  }

  Future<void> _loadPatientDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await PatientService.getPatientById(widget.patientId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          // result['data'] contient déjà les données du patient
          _patientData = result['data'];
        } else {
          _errorMessage = result['error'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D132E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF49A24)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Détails Patient',
          style: TextStyle(
            fontFamily: 'Bangers',
            color: Color(0xFFF49A24),
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFF49A24)),
      )
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPatientDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF49A24),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : _patientData == null
          ? const Center(
        child: Text(
          'Aucune donnée',
          style: TextStyle(color: Colors.white),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar et nom
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF571D7D),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF49A24),
                        width: 4,
                      ),
                    ),
                    child: Icon(
                      _patientData?['sex'] == 2 ? Icons.person : Icons.person_outline,
                      color: const Color(0xFFF49A24),
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getPatientName(),
                    style: const TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 32,
                      color: Color(0xFFF49A24),
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Séparateur
            _buildDivider(),
            const SizedBox(height: 20),

            // Informations personnelles
            _buildSectionTitle('Informations personnelles'),
            const SizedBox(height: 12),
            _buildInfoCard(),

            const SizedBox(height: 30),

            // Statistiques
            _buildSectionTitle('Statistiques'),
            const SizedBox(height: 12),
            _buildStatsCard(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _getPatientName() {
    final firstName = _patientData?['firstname'] ?? '';
    final lastName = _patientData?['lastname'] ?? '';
    if (firstName.isEmpty && lastName.isEmpty) return 'Patient';
    return '$firstName $lastName'.trim();
  }

  String _getSexText() {
    final sex = _patientData?['sex'];
    if (sex == 1) return 'Homme';
    if (sex == 2) return 'Femme';
    return 'Non spécifié';
  }

  String _getAge() {
    final birthyear = _patientData?['birthyear'];
    if (birthyear == null) return 'Non spécifié';
    final age = DateTime.now().year - birthyear;
    return '$age ans';
  }

  Widget _buildDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0x00F49A24), Color(0xFFF49A24)],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFF49A24),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 80,
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFF49A24), Color(0x00F49A24)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Bangers',
        fontSize: 24,
        color: Color(0xFFF49A24),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoCard() {
    final ageText = _getAge();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1F3D),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF571D7D), width: 2),
      ),
      child: Column(
        children: [
          if (ageText != 'Non spécifié')
            _buildInfoRow('Âge', ageText),
          _buildInfoRow('Sexe', _getSexText()),
          if (_patientData?['height'] != null && _patientData!['height'] > 0)
            _buildInfoRow('Taille', '${_patientData!['height']} cm'),
          if (_patientData?['weightStart'] != null && _patientData!['weightStart'] > 0)
            _buildInfoRow('Poids actuel', '${_patientData!['weightStart']} kg'),
          if (_patientData?['weightGoal'] != null && _patientData!['weightGoal'] > 0)
            _buildInfoRow('Poids objectif', '${_patientData!['weightGoal']} kg'),
          if (_patientData?['bmiStart'] != null)
            _buildInfoRow('IMC actuel', _patientData!['bmiStart']),
          if (_patientData?['bmiGoal'] != null)
            _buildInfoRow('IMC objectif', _patientData!['bmiGoal']),
          if (_patientData?['activityProfile'] != null)
            _buildInfoRow('Profil d\'activité', _patientData!['activityProfile']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7C8ED0),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final physioCount = (_patientData?['physiologicalData'] as List?)?.length ?? 0;
    final activityCount = (_patientData?['physicalActivities'] as List?)?.length ?? 0;
    final neuronalCount = (_patientData?['neuronalActivities'] as List?)?.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1F3D),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF571D7D), width: 2),
      ),
      child: Column(
        children: [
          _buildStatRow('Données physiologiques', physioCount),
          _buildStatRow('Activités physiques', activityCount),
          _buildStatRow('Activités neuronales', neuronalCount),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7C8ED0),
              fontSize: 14,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF571D7D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Color(0xFFF49A24),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}