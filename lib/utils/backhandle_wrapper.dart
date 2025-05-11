import 'package:flutter/material.dart';

class BackHandlerWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBack;

  const BackHandlerWrapper({super.key, required this.child, this.onBack});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (onBack != null) {
          onBack!();
        } else {
          if (Navigator.canPop(context)) {
            Navigator.pop(
              context,
            ); // Jika ada halaman di stack, kembali ke halaman sebelumnya
          } else {
            // Jika tidak ada halaman sebelumnya di stack, bisa keluar atau berikan behavior lain
            return true; // Bisa diganti sesuai kebutuhan Anda (misalnya keluar dari aplikasi)
          }
        }
        return false;
      },
      child: child,
    );
  }
}
