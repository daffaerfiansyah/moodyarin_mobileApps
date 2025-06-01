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
  String _jenisKelamin = "-"; 
  String _tanggalLahir = "-"; 
  String _telepon = "-";
  String? _fotoProfilUrl; 
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
          _namaPengguna = userDataResponse['full_name'] ?? "-";
          _fotoProfilUrl = userDataResponse['avatar_url'];
          print("URL Foto Profil dari DB di ProfilPage: ${_fotoProfilUrl}");
          _jenisKelamin = userDataResponse['jenis_kelamin'] ?? "-";

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
            _tanggalLahir = "-";
          }
          _telepon = userDataResponse['telepon'] ?? "-";
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
          _jenisKelamin = "-";
          _tanggalLahir = "-";
          _telepon = "-";
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

  Future<void> _signOut() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Keluar',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun Anda?',
            style: GoogleFonts.poppins(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.grey.shade700),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                'Keluar',
                style: GoogleFonts.poppins(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        if (mounted) {
          setState(() {
            _isLoading = true; // Tampilkan loading saat proses logout
          });
        }
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal log out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(""),
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
            child: RefreshIndicator(
              onRefresh: _fetchUserData,
              color: Colors.indigo.shade600,
              backgroundColor: Colors.white,
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
                  const SizedBox(height: 12), // Beri jarak dari item terakhir
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ), // Padding agar tidak terlalu lebar
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        "Keluar Akun",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: _signOut, // Panggil fungsi _signOut
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
            )
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
        print(
          "Peringatan: _fotoProfilUrl tidak dimulai dengan http: $fotoProfilUrlFromState. Diasumsikan path aset, mungkin salah.",
        );
      }
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 30.0,
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
          const SizedBox(height: 10),
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
