import 'package:flutter/material.dart';

import '../pallete.dart';


class LoginField extends StatelessWidget {
  final String hintText;
  const LoginField({
    Key? key,
    required this.hintText, required TextEditingController controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: TextFormField(
        style: TextStyle(color: Colors.black), // Mengubah warna teks saat mengetik
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(27),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Pallete.borderColor,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Pallete.gradient2,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.black // Warna hint text saat tidak ada teks di dalam field
          ),
        ),
      ),
    );
  }
}
