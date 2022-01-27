import 'dart:io';

import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:get/get.dart';
import 'package:mvp_camera/app/utils/handle_file.dart';
import 'package:mvp_camera/model/file_data_model.dart';
import 'package:path_provider/path_provider.dart';

import '../app/constant/controllers.dart';

class FetchFilesController extends GetxController {
  static FetchFilesController instance = Get.find();

  var listOfProjects = <FileSystemEntity>[].obs;
  var listOfAvailableProject = <String>[].obs;
  var filesInCurrentProject = <FileDataModel>[].obs;

  Future<FileDataModel> createObject(String filePath) async {
    HandleFile handleFile = HandleFile();
    File imageFile = File(filePath);
    FlutterExif fileData = handleFile.getExif(filePath);
    return FileDataModel(imageFile: imageFile, fileData: fileData);
  }

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchDirectories() async {
    final dir = await getRootDirectory();
    if (dir != null) {
      listOfProjects.value = dir.listSync();
      listOfAvailableProject.value = splitAvailableProjects();
    }
  }

  Future<void> checkDirectoriesAndFetch(String project) async {
    print(project);
    if(Platform.isAndroid){
      final dir = await getExternalStorageDirectory();
      Directory newDir = await Directory('${dir?.path}/$project').create(recursive: true);
      filesInCurrentProject.value = await fetchNumberOfFiles(project, newDir);
    }if(Platform.isIOS){
      final dir = await getApplicationDocumentsDirectory();
      Directory newDir = await Directory('${dir.path}/$project').create();
      filesInCurrentProject.value = await fetchNumberOfFiles(project, newDir);
    }
  }

  Future<List<FileDataModel>> fetchNumberOfFiles(String project, Directory newDir) async {
    List<FileSystemEntity> tempFiles = newDir.listSync();
    List<FileDataModel> files = <FileDataModel>[];
    tempFiles.forEach((element) async {
      FileDataModel tempObj = await createObject(element.path);
      files.add(tempObj);
    });
    return files;
  }



  List<String> splitAvailableProjects() {
    List<String> tempProjects = <String>[];

    for (var element in listOfProjects) {
      // BREAKING DIRECTORIES
      List<String> subStringsList = element.path.split('/');
      // ADDING LAST INDEX OF BROKEN DIRECTORY WHICH INCLUDES PROJECT NAME
      tempProjects.add(subStringsList[subStringsList.length - 1]);
    }

    return tempProjects;
  }

  Future<Directory?> getRootDirectory() async {
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory();
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

}
