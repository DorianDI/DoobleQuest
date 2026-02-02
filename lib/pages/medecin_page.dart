import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'patients_list_page.dart';
import 'statistiques_page.dart';

class MedecinPage extends StatefulWidget {
  const MedecinPage({super.key});

  @override
  State<MedecinPage> createState() => _MedecinPageState();
}

class _MedecinPageState extends State<MedecinPage> {
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final email = await AuthService.getUserEmail();
    setState(() {
      _userEmail = email;
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A1F3D),
        title: const Text(
          'Déconnexion',
          style: TextStyle(
            fontFamily: 'Bangers',
            color: Color(0xFFF49A24),
          ),
        ),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter ?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Color(0xFF7C8ED0)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Déconnexion',
              style: TextStyle(color: Color(0xFFF49A24)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Déconnexion réussie'),
            backgroundColor: Colors.green,
          ),
        );
        // Retourner à l'accueil en supprimant toute la pile de navigation
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
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
          onPressed: () {
            // Retour à l'accueil en supprimant toute la pile
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Titre
              Stack(
                children: [
                  Transform.translate(
                    offset: const Offset(-6, 3),
                    child: const Text(
                      'Espace Médecin',
                      style: TextStyle(
                        fontFamily: 'Bangers',
                        fontSize: 52,
                        color: Color(0xFFF49A24),
                      ),
                    ),
                  ),
                  Text(
                    'Espace Médecin',
                    style: TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 52,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2.5
                        ..color = Colors.black,
                    ),
                  ),
                  const Text(
                    'Espace Médecin',
                    style: TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 52,
                      color: Color(0xFF571D7D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Email du médecin
              if (_userEmail != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1F3D),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF571D7D),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.medical_services,
                        color: Color(0xFFF49A24),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          _userEmail!,
                          style: const TextStyle(
                            color: Color(0xFF7C8ED0),
                            fontSize: 18,
                            fontFamily: 'Caveat',
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 30),

              // Séparateur
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0x00F49A24),
                          Color(0xFFF49A24),
                        ],
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
                        colors: [
                          Color(0xFFF49A24),
                          Color(0x00F49A24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Cartes de fonctionnalités
              _buildFeatureCard(
                icon: Icons.bar_chart,
                title: 'Statistiques',
                description: 'Vue d\'ensemble de tous vos patients',
                onTap: () {
                  // Navigation vers les statistiques
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StatistiquesPage()),
                  );
                },
              ),
              const SizedBox(height: 15),
              _buildFeatureCard(
                icon: Icons.people,
                title: 'Mes Patients',
                description: 'Gérer les patients et leurs progrès',
                onTap: () {
                  // Navigation vers la liste des patients
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PatientsListPage()),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Bouton de déconnexion
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF571D7D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Déconnexion',
                        style: TextStyle(
                          fontFamily: 'Bangers',
                          fontSize: 24,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A1F3D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF571D7D),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF49A24).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF571D7D),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFF49A24),
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Bangers',
                        fontSize: 24,
                        color: Color(0xFFF49A24),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Caveat',
                        fontSize: 16,
                        color: Color(0xFF7C8ED0),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF7C8ED0),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}