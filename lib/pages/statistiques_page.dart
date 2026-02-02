import 'package:flutter/material.dart';
import '../services/patient_service.dart';

class StatistiquesPage extends StatefulWidget {
  const StatistiquesPage({super.key});

  @override
  State<StatistiquesPage> createState() => _StatistiquesPageState();
}

class _StatistiquesPageState extends State<StatistiquesPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _patients = [];

  // Statistiques globales
  int _totalPatients = 0;
  int _totalHommes = 0;
  int _totalFemmes = 0;
  double _moyenneAge = 0;
  double _moyennePoids = 0;
  double _moyenneTaille = 0;

  // Répartition BMI
  Map<String, int> _bmiDistribution = {};

  // Répartition par profil d'activité
  Map<String, int> _activityDistribution = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await PatientService.getAllPatients();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _patients = result['data'] ?? [];
          _calculateStatistics();
        } else {
          _errorMessage = result['error'];
        }
      });
    }
  }

  void _calculateStatistics() {
    _totalPatients = _patients.length;

    double totalAge = 0;
    int patientsAvecAge = 0;
    double totalPoids = 0;
    int patientsAvecPoids = 0;
    double totalTaille = 0;
    int patientsAvecTaille = 0;

    _bmiDistribution.clear();
    _activityDistribution.clear();
    _totalHommes = 0;
    _totalFemmes = 0;

    for (var patient in _patients) {
      // Sexe
      if (patient['sex'] == 1) _totalHommes++;
      if (patient['sex'] == 2) _totalFemmes++;

      // Age
      if (patient['birthyear'] != null) {
        final age = DateTime.now().year - (patient['birthyear'] as int);
        if (age > 0 && age < 150) {
          totalAge += age.toDouble();
          patientsAvecAge++;
        }
      }

      // Poids
      if (patient['weightStart'] != null && patient['weightStart'] > 0) {
        totalPoids += (patient['weightStart'] as num).toDouble();
        patientsAvecPoids++;
      }

      // Taille
      if (patient['height'] != null && patient['height'] > 0) {
        totalTaille += (patient['height'] as num).toDouble();
        patientsAvecTaille++;
      }

      // BMI
      if (patient['bmiStart'] != null && patient['bmiStart'].toString().isNotEmpty) {
        final bmi = patient['bmiStart'].toString();
        _bmiDistribution[bmi] = (_bmiDistribution[bmi] ?? 0) + 1;
      }

      // Activité
      if (patient['activityProfile'] != null && patient['activityProfile'].toString().isNotEmpty) {
        final activity = patient['activityProfile'].toString();
        _activityDistribution[activity] = (_activityDistribution[activity] ?? 0) + 1;
      }
    }

    _moyenneAge = patientsAvecAge > 0 ? totalAge / patientsAvecAge : 0;
    _moyennePoids = patientsAvecPoids > 0 ? totalPoids / patientsAvecPoids : 0;
    _moyenneTaille = patientsAvecTaille > 0 ? totalTaille / patientsAvecTaille : 0;
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
          'Statistiques',
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
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStatistics,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF49A24),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadStatistics,
        color: const Color(0xFFF49A24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vue d'ensemble
              _buildSectionTitle('Vue d\'ensemble'),
              const SizedBox(height: 16),
              _buildOverviewCards(),

              const SizedBox(height: 32),

              // Répartition par sexe
              _buildSectionTitle('Répartition par sexe'),
              const SizedBox(height: 16),
              _buildSexDistribution(),

              const SizedBox(height: 32),

              // Moyennes
              _buildSectionTitle('Moyennes'),
              const SizedBox(height: 16),
              _buildAveragesCard(),

              const SizedBox(height: 32),

              // Répartition BMI
              if (_bmiDistribution.isNotEmpty) ...[
                _buildSectionTitle('Répartition IMC'),
                const SizedBox(height: 16),
                _buildBMIDistribution(),
                const SizedBox(height: 32),
              ],

              // Profils d'activité
              if (_activityDistribution.isNotEmpty) ...[
                _buildSectionTitle('Profils d\'activité'),
                const SizedBox(height: 16),
                _buildActivityDistribution(),
              ],
            ],
          ),
        ),
      ),
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

  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Patients',
            _totalPatients.toString(),
            Icons.people,
            const Color(0xFF571D7D),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Données',
            _patients.fold<int>(0, (sum, p) =>
            sum + ((p['physiologicalData'] as List?)?.length ?? 0)
            ).toString(),
            Icons.analytics,
            const Color(0xFF7C8ED0),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1F3D),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Bangers',
              fontSize: 32,
              color: Color(0xFFF49A24),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSexDistribution() {
    final total = _totalHommes + _totalFemmes;
    final pourcentageHommes = total > 0 ? (_totalHommes / total * 100) : 0;
    final pourcentageFemmes = total > 0 ? (_totalFemmes / total * 100) : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1F3D),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF571D7D), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: _totalHommes,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C8ED0),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(8),
                      bottomLeft: const Radius.circular(8),
                      topRight: _totalFemmes == 0 ? const Radius.circular(8) : Radius.zero,
                      bottomRight: _totalFemmes == 0 ? const Radius.circular(8) : Radius.zero,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _totalHommes > 0 ? '${pourcentageHommes.toInt()}%' : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              if (_totalFemmes > 0)
                Expanded(
                  flex: _totalFemmes,
                  child: Container(
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF49A24),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${pourcentageFemmes.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Hommes', _totalHommes, const Color(0xFF7C8ED0)),
              _buildLegendItem('Femmes', _totalFemmes, const Color(0xFFF49A24)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $count',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildAveragesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1F3D),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF571D7D), width: 2),
      ),
      child: Column(
        children: [
          _buildAverageRow('Âge moyen', '${_moyenneAge.toStringAsFixed(1)} ans'),
          const Divider(color: Colors.white24, height: 24),
          _buildAverageRow('Poids moyen', '${_moyennePoids.toStringAsFixed(1)} kg'),
          const Divider(color: Colors.white24, height: 24),
          _buildAverageRow('Taille moyenne', '${_moyenneTaille.toStringAsFixed(0)} cm'),
        ],
      ),
    );
  }

  Widget _buildAverageRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7C8ED0),
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFF49A24),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBMIDistribution() {
    final sortedEntries = _bmiDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1F3D),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF571D7D), width: 2),
      ),
      child: Column(
        children: sortedEntries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDistributionBar(
              entry.key,
              entry.value,
              _totalPatients,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityDistribution() {
    final sortedEntries = _activityDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1F3D),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF571D7D), width: 2),
      ),
      child: Column(
        children: sortedEntries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDistributionBar(
              entry.key,
              entry.value,
              _totalPatients,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDistributionBar(String label, int count, int total) {
    final percentage = total > 0 ? (count / total * 100) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$count (${percentage.toStringAsFixed(0)}%)',
              style: const TextStyle(
                color: Color(0xFFF49A24),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF571D7D)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}