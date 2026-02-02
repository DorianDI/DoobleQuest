import 'package:flutter/material.dart';
import '../services/patient_service.dart';
import 'patient_detail_page.dart';

class PatientsListPage extends StatefulWidget {
  const PatientsListPage({super.key});

  @override
  State<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage> {
  bool _isLoading = true;
  List<dynamic> _patients = [];
  List<dynamic> _filteredPatients = [];
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
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
          _filteredPatients = _patients;
        } else {
          _errorMessage = result['error'];
        }
      });
    }
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _patients;
      } else {
        _filteredPatients = _patients.where((patient) {
          final firstName = (patient['firstname'] ?? '').toString().toLowerCase();
          final lastName = (patient['lastname'] ?? '').toString().toLowerCase();
          final fullName = '$firstName $lastName';
          final id = (patient['id'] ?? '').toString().toLowerCase();

          return fullName.contains(query) || id.contains(query);
        }).toList();
      }
    });
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
          'Mes Patients',
          style: TextStyle(
            fontFamily: 'Bangers',
            color: Color(0xFFF49A24),
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A1F3D),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFF571D7D),
                  width: 2,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Rechercher un patient...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.search, color: Color(0xFFF49A24)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),

          // Compteur de résultats
          if (!_isLoading && _errorMessage == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredPatients.length} patient${_filteredPatients.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Color(0xFF7C8ED0),
                      fontSize: 14,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                      },
                      child: const Text(
                        'Réinitialiser',
                        style: TextStyle(color: Color(0xFFF49A24)),
                      ),
                    ),
                ],
              ),
            ),

          // Liste des patients
          Expanded(
            child: _isLoading
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
                    onPressed: _loadPatients,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF49A24),
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
                : _filteredPatients.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchController.text.isEmpty
                        ? Icons.people_outline
                        : Icons.search_off,
                    color: const Color(0xFF7C8ED0),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty
                        ? 'Aucun patient'
                        : 'Aucun résultat',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Bangers',
                    ),
                  ),
                  if (_searchController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Essayez un autre terme de recherche',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadPatients,
              color: const Color(0xFFF49A24),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredPatients.length,
                itemBuilder: (context, index) {
                  final patient = _filteredPatients[index];
                  return _buildPatientCard(patient);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(dynamic patient) {
    // Adapter aux vrais champs de l'API
    final String patientId = patient['id']?.toString() ?? '';
    final String firstName = patient['firstname'] ?? '';
    final String lastName = patient['lastname'] ?? '';
    final String fullName = (firstName.isEmpty && lastName.isEmpty)
        ? 'Patient sans nom'
        : '$firstName $lastName'.trim();

    final int? birthyear = patient['birthyear'];
    final int age = birthyear != null ? DateTime.now().year - birthyear : 0;
    final String? ageText = age > 0 ? '$age ans' : null;

    final int? height = patient['height'];
    final String? heightText = height != null && height > 0 ? '$height cm' : null;

    final dynamic weightStart = patient['weightStart'];
    final String? weightText = weightStart != null && weightStart > 0
        ? '${weightStart.toString()} kg'
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PatientDetailPage(patientId: patientId),
              ),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A1F3D),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF571D7D),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF571D7D),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF49A24),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    patient['sex'] == 2 ? Icons.person : Icons.person_outline,
                    color: const Color(0xFFF49A24),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          color: Color(0xFFF49A24),
                          fontSize: 20,
                          fontFamily: 'Bangers',
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (ageText != null)
                        Text(
                          ageText,
                          style: const TextStyle(
                            color: Color(0xFF7C8ED0),
                            fontSize: 14,
                          ),
                        ),
                      if (heightText != null || weightText != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          [heightText, weightText].where((e) => e != null).join(' • '),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Flèche
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF7C8ED0),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}