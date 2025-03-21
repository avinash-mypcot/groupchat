import 'package:flutter/material.dart';

class TextFieldContainer extends StatelessWidget {
  final TextEditingController? controller;
  final bool? isObscureText;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  const TextFieldContainer(
      {Key? key,
      this.keyboardType,
      this.prefixIcon,
      this.hintText,
      this.controller,
      this.isObscureText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Color(0xFF424242).withOpacity(0.2),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: TextField(
        obscureText: isObscureText == true ? true : false,
        keyboardType: keyboardType == null ? TextInputType.text : keyboardType,
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon == null ? Icons.circle : prefixIcon),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
