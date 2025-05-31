import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:moodyarin/routes/routes.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String _namaPengguna = "Memuat...";
  String _email = "Memuat...";
  String _jenisKelamin = "Belum diatur"; // Default jika data belum ada
  String _tanggalLahir = "Belum diatur"; // Default
  String _telepon = "Belum diatur"; // Default
  String? _fotoProfilUrl; // Default
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _namaPengguna = "Tidak ada user";
        _email = "-";
        _jenisKelamin = "-";
        _tanggalLahir = "-";
        _telepon = "-";
        _fotoProfilUrl = null;
        _isLoading = false;
      });
      return;
    }

    _email = user.email ?? "Email tidak tersedia";

    try {
      final userDataResponse =
          await Supabase.instance.client
              .from('users')
              .select(
                'full_name, avatar_url, jenis_kelamin, tanggal_lahir, telepon',
              ) 
              .eq('id', user.id)
              .single(); 

      if (mounted) {
        setState(() {
          _namaPengguna = userDataResponse['full_name'] ?? "Nama Belum Diatur";
          _fotoProfilUrl = userDataResponse['avatar_url'];
          print("URL Foto Profil dari DB di ProfilPage: ${_fotoProfilUrl}");
          _jenisKelamin = userDataResponse['jenis_kelamin'] ?? "Belum diatur";

          // Format tanggal lahir jika ada
          if (userDataResponse['tanggal_lahir'] != null) {
            try {
              final date = DateTime.parse(
                userDataResponse['tanggal_lahir'].toString(),
              );
              _tanggalLahir = DateFormat('d MMMM yyyy', 'id_ID').format(date);
            } catch (e) {
              print("Error parsing tanggal lahir: $e");
              _tanggalLahir = "Format salah";
            }
          } else {
            _tanggalLahir = "Belum diatur";
          }

          _telepon = userDataResponse['telepon'] ?? "Belum diatur";
        });
      }
    } catch (e) {
      print("Error fetching data from 'users' table or no data for user: $e");
      if (mounted) {
        setState(() {
          _namaPengguna =
              user.userMetadata?['full_name'] ??
              user.userMetadata?['name'] ??
              "Nama Belum Diatur";
          _jenisKelamin = "Belum diatur";
          _tanggalLahir = "Belum diatur";
          _telepon = "Belum diatur";
          _fotoProfilUrl = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profil"),
          backgroundColor: Colors.indigo.shade400,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(context, _namaPengguna, _fotoProfilUrl),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              children: [
                _buildInfoTile(
                  icon: Icons.person_outline,
                  label: "Jenis Kelamin",
                  value: _jenisKelamin,
                ),
                const SizedBox(height: 16),
                _buildInfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: "Tanggal Lahir",
                  value: _tanggalLahir,
                ),
                const SizedBox(height: 16),
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  label: "Email",
                  value: _email,
                ),
                const SizedBox(height: 16),
                _buildInfoTile(
                  icon: Icons.phone_outlined,
                  label: "Telepon",
                  value: _telepon,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String nama,
    String? fotoProfilUrlFromState,
  ) {
    print("Membangun Header di ProfilPage, URL Foto: $fotoProfilUrlFromState");

    ImageProvider? backgroundImageToShow;

    if (fotoProfilUrlFromState != null && fotoProfilUrlFromState.isNotEmpty) {
      if (fotoProfilUrlFromState.startsWith('http')) {
        backgroundImageToShow = NetworkImage(fotoProfilUrlFromState);
      } else {
        // Ini untuk kasus jika Anda menyimpan path aset lokal, jarang untuk foto profil dinamis
        // backgroundImageToShow = AssetImage(fotoProfilUrlFromState);
        print(
          "Peringatan: _fotoProfilUrl tidak dimulai dengan http: $fotoProfilUrlFromState. Diasumsikan path aset, mungkin salah.",
        );
      }
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 60.0,
        bottom: 30.0,
        left: 20.0,
        right: 20.0,
      ),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage(
            'assets/IMG-11.png',
          ),
          fit: BoxFit.cover,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40.0),
          bottomRight: Radius.circular(40.0),
        ),
      ),
      child: Column(
        children: [
          Text(
            "Profil",
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.8),
            backgroundImage:
                backgroundImageToShow,
            child:
                backgroundImageToShow ==
                        null 
                    ? Icon(Icons.person, size: 50, color: Colors.grey.shade600)
                    : null,
          ),
          const SizedBox(height: 12),
          Text(
            nama,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRoutes.editProfil,
              );
              if (result == true && mounted) {
                _fetchUserData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            child: Text(
              "Edit Profil",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 17,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Divider(color: Colors.grey.shade300, height: 1),
      ],
    );
  }
}
