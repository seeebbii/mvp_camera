import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const CustomButton(
      {Key? key, required this.buttonText, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: ElevatedButton(
          style: Theme.of(context).elevatedButtonTheme.style,
          onPressed: onPressed,
          child: Text(buttonText, style: Theme.of(context).textTheme.headline1?.copyWith(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),),
        ),
      ),
    );
  }
}