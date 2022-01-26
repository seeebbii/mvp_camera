import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class FetchFilesController extends GetxController {
  static FetchFilesController instance = Get.find();


  @override
  void onInit() {
    super.onInit();

  }

  Future<void> fetchDirectories() async {
    final dir = await getRootDirectory();
    print(dir);

    if(dir != null){
      dir.list(followLinks: true);
    }

  }


  Future<Directory?> getRootDirectory() async{
    if(Platform.isAndroid){
      return await getExternalStorageDirectory();
    }else{
      return await getApplicationDocumentsDirectory();
    }
  }


}