import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart'; 
import 'dart:io';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  bool _isLoading = true;
  String? _fotoProfilUrl;
  File? _newProfileImageFile;

  late final TextEditingController _namaController;
  late final TextEditingController _emailController;
  late final TextEditingController _teleponController;
  late final TextEditingController _passwordController;
  late final TextEditingController _konfirmasiPasswordController;

  // State untuk data non-teks
  String _displayJenisKelamin = "Pilih Jenis Kelamin";
  String _displayTanggalLahir = "Pilih Tanggal Lahir";
  DateTime? _selectedTanggalLahir;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller
    _namaController = TextEditingController();
    _emailController = TextEditingController();
    _teleponController = TextEditingController();
    _passwordController = TextEditingController();
    _konfirmasiPasswordController = TextEditingController();

    _fetchAndInitializeData();
  }

  @override
  void dispose() {
    // Dispose semua controller
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndInitializeData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        // Handle jika tidak ada user, mungkin navigasi kembali atau tampilkan pesan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sesi pengguna tidak ditemukan."),
            backgroundColor: Colors.red,
          ),
        );
      });
      return;
    }

    // Email dari auth.users
    _emailController.text = user.email ?? "";

    try {
      final userDataResponse =
          await Supabase.instance.client
              .from('users') // PASTIKAN INI NAMA TABEL ANDA
              .select(
                'full_name, avatar_url, jenis_kelamin, tanggal_lahir, telepon',
              ) // Ambil semua kolom yang mungkin
              .eq('id', user.id)
              .maybeSingle(); // Gunakan maybeSingle agar tidak error jika row belum ada

      if (mounted && userDataResponse != null) {
        setState(() {
          _namaController.text =
              userDataResponse['full_name'] ??
              (user.userMetadata?['full_name'] ??
                  user.userMetadata?['name'] ??
                  '');
          _fotoProfilUrl = userDataResponse['avatar_url'];
          _displayJenisKelamin =
              userDataResponse['jenis_kelamin'] ?? "Pilih Jenis Kelamin";

          if (userDataResponse['tanggal_lahir'] != null) {
            try {
              _selectedTanggalLahir = DateTime.parse(
                userDataResponse['tanggal_lahir'].toString(),
              );
              _displayTanggalLahir = DateFormat(
                'd MMMM yyyy',
                'id_ID',
              ).format(_selectedTanggalLahir!);
            } catch (e) {
              print("Error parsing tanggal lahir dari DB: $e");
              _displayTanggalLahir = "Format Salah";
            }
          } else {
            _displayTanggalLahir = "Pilih Tanggal Lahir";
          }
          _teleponController.text = userDataResponse['telepon'] ?? "";
        });
      } else if (mounted && userDataResponse == null) {
        // Jika tidak ada data profil di tabel 'users', set nama dari metadata jika ada
        _namaController.text =
            user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? '';
      }
    } catch (e) {
      print("Error fetching profile data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat data profil: $e"),
            backgroundColor: Colors.red,
          ),
        );
        // Set nama dari metadata sebagai fallback jika query gagal
        _namaController.text =
            user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? '';
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        _cropImage(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cropImage(String filePath) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        // Mungkin beberapa versi lama tidak memiliki 'uiSettings' sebagai list,
        // tapi parameter terpisah seperti 'androidUiSettings' dan 'iosUiSettings'.
        // ATAU, beberapa parameter di dalam uiSettings yang saya berikan tidak ada.

        // COBA HAPUS ATAU SESUAIKAN uiSettings INI TERLEBIH DAHULU JIKA ERROR MERUJUK KE SANA
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Gambar',
            toolbarColor: Colors.indigo.shade600,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true, // Coba dengan ini saja dulu
            // initAspectRatio: CropAspectRatioPreset.square, // Mungkin ini tidak ada/berbeda
          ),
          IOSUiSettings(
            title: 'Potong Gambar',
            aspectRatioLockEnabled: true, // Coba dengan ini saja dulu
            // cropStyle: CropStyle.circle, // Mungkin ini tidak ada/berbeda di sini
            // rectX, rectY, dll. mungkin tidak diperlukan jika hanya ingin crop lingkaran/persegi standar
          ),
        ],

        // COBA HAPUS PARAMETER INI DULU JIKA ERROR MERUJUK KE SINI
        // cropStyle: CropStyle.circle,
        // aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        // aspectRatioPresets: [CropAspectRatioPreset.square],
        compressQuality: 70, // Ini biasanya aman
      );

      if (croppedFile != null) {
        setState(() {
          _newProfileImageFile = File(croppedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memotong gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil Foto dari Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pilihTanggalLahir() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedTanggalLahir ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    if (pickedDate != null && pickedDate != _selectedTanggalLahir) {
      setState(() {
        _selectedTanggalLahir = pickedDate;
        _displayTanggalLahir = DateFormat(
          'd MMMM yyyy',
          'id_ID',
        ).format(pickedDate);
      });
    }
  }

  Future<void> _pilihJenisKelamin() async {
    // Contoh menggunakan showDialog dengan RadioListTile
    String? pilihan = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? groupValue =
            _displayJenisKelamin != "Pilih Jenis Kelamin"
                ? _displayJenisKelamin
                : null;
        return AlertDialog(
          title: Text('Pilih Jenis Kelamin', style: GoogleFonts.poppins()),
          content: StatefulBuilder(
            // Untuk update UI di dalam dialog
            builder: (BuildContext context, StateSetter setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    <String>['Laki - laki', 'Perempuan'].map((String value) {
                      return RadioListTile<String>(
                        title: Text(value, style: GoogleFonts.poppins()),
                        value: value,
                        groupValue: groupValue,
                        onChanged: (String? newValue) {
                          setStateDialog(() {
                            groupValue = newValue;
                          });
                        },
                      );
                    }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: GoogleFonts.poppins()),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: Text('Pilih', style: GoogleFonts.poppins()),
              onPressed: () {
                Navigator.of(context).pop(groupValue);
              },
            ),
          ],
        );
      },
    );

    if (pilihan != null) {
      setState(() {
        _displayJenisKelamin = pilihan;
      });
    }
  }

  // Di dalam kelas _EditProfilPageState

  Future<void> _simpanPerubahan() async {
    if (!mounted) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sesi pengguna tidak valid."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String?
      newAvatarUrl; // Variabel untuk menyimpan URL gambar baru dari Supabase Storage

      // 1. PROSES UPLOAD GAMBAR JIKA ADA GAMBAR BARU YANG DIPILIH
      if (_newProfileImageFile != null) {
        final imageFile = _newProfileImageFile!;
        // Buat nama file yang unik, misalnya menggunakan user ID dan timestamp
        // atau biarkan Supabase yang membuat nama unik jika Anda tidak upsert.
        // Ekstensi file juga penting.
        final fileExt = imageFile.path.split('.').last.toLowerCase();
        final fileName =
            '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        // Upload ke Supabase Storage
        // Ganti 'avatars' dengan nama bucket Anda
        await Supabase.instance.client.storage
            .from('avatars') // NAMA BUCKET ANDA
            .upload(
              fileName,
              imageFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ), // upsert: false agar error jika file sudah ada (atau true untuk menimpa)
            );

        // Dapatkan URL publik dari gambar yang baru diunggah
        // Ganti 'avatars' dengan nama bucket Anda
        newAvatarUrl = Supabase.instance.client.storage
            .from('avatars') // NAMA BUCKET ANDA
            .getPublicUrl(fileName);

        print("Foto profil baru diunggah: $newAvatarUrl");
      }

      // 2. Kumpulkan data yang akan diupdate ke tabel 'users'
      final Map<String, dynamic> dataToUpdate = {
        'full_name': _namaController.text,
        // Jangan update email di sini kecuali Anda menangani alur verifikasi email baru Supabase
        'telepon': _teleponController.text,
        'jenis_kelamin':
            _displayJenisKelamin != "Pilih Jenis Kelamin"
                ? _displayJenisKelamin
                : null,
        'tanggal_lahir': _selectedTanggalLahir?.toIso8601String().substring(
          0,
          10,
        ),
        // Jika ada gambar baru, gunakan URL baru. Jika tidak, jangan ubah avatar_url
        // (atau set ke null jika ingin menghapus foto profil yang ada tanpa mengganti).
        // Di sini kita hanya update jika ada newAvatarUrl.
        if (newAvatarUrl != null) 'avatar_url': newAvatarUrl,
      };

      // Hapus field yang null atau placeholder agar tidak meng-overwrite data yang sudah ada dengan null
      // Kecuali untuk avatar_url, karena newAvatarUrl sudah dicek.
      // Jika Anda ingin bisa menghapus data (misal, menghapus nomor telepon), maka jangan remove key jika value-nya string kosong.
      // Sesuaikan logika removeWhere ini dengan kebutuhan Anda.
      dataToUpdate.removeWhere((key, value) {
        if (key == 'avatar_url')
          return false; // Jangan hapus avatar_url jika sudah ada di map
        return value == null ||
            (value is String && (value.isEmpty || value.startsWith("Pilih")));
      });

      // Hanya update jika ada data yang akan diubah (selain avatar_url yang mungkin baru)
      if (dataToUpdate.isNotEmpty) {
        await Supabase.instance.client
            .from('users')
            .update(dataToUpdate)
            .eq('id', user.id);
      }

      // Penanganan perubahan password (sudah ada di kode Anda)
      if (_passwordController.text.isNotEmpty) {
        if (_passwordController.text != _konfirmasiPasswordController.text) {
          throw Exception("Password dan konfirmasi password tidak cocok.");
        }
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: _passwordController.text),
        );
      }

      // Penanganan perubahan email (sudah ada di kode Anda)
      // Ingat bahwa mengubah email di Supabase Auth akan memicu email konfirmasi
      // dan pengguna mungkin perlu login ulang atau emailnya belum langsung aktif.
      if (_emailController.text.isNotEmpty &&
          _emailController.text != user.email) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(email: _emailController.text),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Instruksi perubahan email telah dikirim. Silakan cek email Anda.",
              ),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
        // Set state foto profil URL yang baru agar UI header langsung update jika ada perubahan
        if (newAvatarUrl != null) {
          setState(() {
            _fotoProfilUrl = newAvatarUrl;
            _newProfileImageFile =
                null; // Reset file gambar baru setelah diunggah
          });
        }
        // Anda mungkin ingin pop halaman setelah berhasil, atau fetch ulang data
        // Navigator.of(context).pop(true); // true untuk menandakan ada perubahan
      }
    } catch (e) {
      print("Error saving profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menyimpan profil: $e"),
            backgroundColor: Colors.red,
          ),
        );
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Edit Profil",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo.shade600,
        elevation: 0,
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [_buildProfileHeader(), _buildFormSection()],
                ),
              ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      decoration: BoxDecoration(color: Colors.indigo.shade600),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white.withOpacity(0.9),
                backgroundImage:
                    _newProfileImageFile != null
                        ? FileImage(
                          _newProfileImageFile!,
                        ) // Tampilkan gambar baru jika ada
                        : (_fotoProfilUrl != null &&
                                    _fotoProfilUrl!.startsWith('http')
                                ? NetworkImage(_fotoProfilUrl!)
                                : (_fotoProfilUrl != null
                                    ? AssetImage(
                                      _fotoProfilUrl!,
                                    ) // Jika path aset lokal dari DB (jarang)
                                    : null))
                            as ImageProvider?,
                child:
                    _newProfileImageFile == null && _fotoProfilUrl == null
                        ? Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey.shade400,
                        )
                        : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    _showImageSourceActionSheet(context);
                    print("Pilih foto");
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.indigo.shade600,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.indigo.shade600,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Untuk Nama, kita gunakan TextField langsung di sini agar bisa diedit
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: TextField(
              controller: _namaController,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: "Nama Lengkap",
                hintStyle: GoogleFonts.poppins(color: Colors.white70),
                border: InputBorder.none,
                suffixIcon: Icon(
                  Icons.edit_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.grey[100],
      child: Column(
        children: [
          _buildSelectableInfoRow(
            icon: Icons.wc_outlined,
            label: "Jenis Kelamin",
            value: _displayJenisKelamin,
            onTap: _pilihJenisKelamin,
          ),
          _buildSelectableInfoRow(
            icon: Icons.calendar_today_outlined,
            label: "Tanggal Lahir",
            value: _displayTanggalLahir,
            onTap: _pilihTanggalLahir,
          ),
          _buildTextFieldInfoRow(
            icon: Icons.email_outlined,
            label: "Email",
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          _buildTextFieldInfoRow(
            icon: Icons.phone_outlined,
            label: "Telepon",
            controller: _teleponController,
            keyboardType: TextInputType.phone,
          ),
          _buildTextFieldInfoRow(
            icon: Icons.lock_outline,
            label: "Password Baru",
            controller: _passwordController,
            obscureText: true,
            hintText: "Kosongkan jika tidak ingin diubah",
          ),
          _buildTextFieldInfoRow(
            icon: Icons.lock_outline,
            label: "Konfirmasi Password Baru",
            controller: _konfirmasiPasswordController,
            obscureText: true,
            showDivider: false,
            hintText: "Kosongkan jika tidak ingin diubah",
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _simpanPerubahan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 5,
              ),
              child: Text(
                "Simpan",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk field yang bisa dipilih (Jenis Kelamin, Tanggal Lahir)
  Widget _buildSelectableInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Icon(icon, color: Colors.grey.shade700, size: 22),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade500,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider) Divider(color: Colors.grey.shade300, height: 1),
      ],
    );
  }

  // Widget untuk field yang berupa TextField
  Widget _buildTextFieldInfoRow({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool showDivider = true,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade700, size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey.shade500,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 0,
            ), // Atur padding agar lebih pas
            border: InputBorder.none, // Hilangkan border default TextField
            isDense: true,
          ),
        ),
        if (showDivider)
          Divider(color: Colors.grey.shade300, height: 1, thickness: 1),
        const SizedBox(height: 8), // Spasi setelah divider
      ],
    );
  }
}
