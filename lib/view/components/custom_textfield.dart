import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mvp_camera/app/utils/colors.dart';

class CustomTextField extends StatelessWidget {

  final TextEditingController controller;
  Color containerBoxColor;
  double borderRadius;
  String? hintText;

  bool obSecureText;
  dynamic validator;
  TextInputAction action;
  TextInputType keyType;

  Widget suffixIcon;
  List<TextInputFormatter>? formatter = [];

  AutovalidateMode? validateMode = AutovalidateMode.disabled;

  CustomTextField({Key? key, required this.controller,
    required this.containerBoxColor,
    required this.borderRadius,
    required this.obSecureText,
    required this.validator,
    required this.action,
    required this.keyType,
    required this.suffixIcon,
    this.hintText, this.formatter = const [], this.validateMode = AutovalidateMode.disabled, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: primaryColor)
      ),
      child: TextFormField(
        style: Theme
            .of(context)
            .textTheme
            .bodyText1?.copyWith(color: Colors.white, fontSize: 15.sp),
        cursorWidth: 1,
        textInputAction: action,
        keyboardType: keyType,
        autovalidateMode: validateMode,
        inputFormatters: formatter,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: Theme
              .of(context)
              .inputDecorationTheme
              .hintStyle,
          suffixIcon: suffixIcon,
        ),
        obscureText: obSecureText,
        cursorColor: Colors.red.shade400,
        validator: validator,
      ),
    );
  }
}