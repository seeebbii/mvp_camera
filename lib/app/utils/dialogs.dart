import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'colors.dart';

class Dialogs{

  // static void showDialog(){
  //   Get.defaultDialog(
  //     title: "GeeksforGeeks",
  //     middleText: "Hello world!",
  //     backgroundColor: Colors.transparent,
  //
  //   );
  // }
  static openErrorSnackBar(context, String text ) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(text),
      duration: const Duration(milliseconds: 2500),
    ));
  }

  static openIconSnackBar(context, String text, Widget icon) {
    ScaffoldMessenger.of(context).showSnackBar( SnackBar(
      backgroundColor: Colors.green,
      content: Row(
        children: [
          icon,
          SizedBox(width: 5,),
          Text(text)
        ],
      ),
      duration: const Duration(milliseconds: 2500),
    ));
  }

  static Future<void> showLoadingDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  // key: key,
                  backgroundColor: backgroundColor,
                  children: <Widget>[
                    Center(
                      child: Column(children:  [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10,),
                        Text("Fetching your pictures...",style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),)
                      ]),
                    )
                  ]));
        });
  }

}