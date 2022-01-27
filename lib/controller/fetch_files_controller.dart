import 'dart:io';
import 'dart:typed_data';
import 'package:metadata/metadata.dart' as meta;
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvp_camera/app/utils/handle_file.dart';
import 'package:mvp_camera/model/file_data_model.dart';
import 'package:path_provider/path_provider.dart';

import '../app/constant/controllers.dart';

class FetchFilesController extends GetxController {
  static FetchFilesController instance = Get.find();

  var listOfProjects = <FileSystemEntity>[].obs;
  var listOfAvailableProject = <String>[].obs;
  var filesInCurrentProject = <FileDataModel>[].obs;

  void createObject(String filePath) async {
    HandleFile handleFile = HandleFile();

    // CREATING FILE
    File imageFile = File(filePath);

    // READING FILE EXIF
    FlutterExif fileData = handleFile.getExif(filePath);

    // FETCHING LAT LONG FROM IMAGE
    Float64List? imagePosition = await fileData.getLatLong();

    // EXTRACTING IMAGE META DATA
    var content = meta.MetaData.exifData(imageFile.readAsBytesSync());

    // CHECKING IF LAT LNG IS NOT NULL
    LatLng latLng = const LatLng(0.0, 0.0);
    if (imagePosition != null) {
      latLng = LatLng(imagePosition[0], imagePosition[1]);
    }

    // RETURN [FileDataModel] Object
    filesInCurrentProject.add(FileDataModel(
        imageFile: imageFile,
        fileData: fileData,
        position: latLng,
        metaData: content.exifData));
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
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      Directory newDir =
          await Directory('${dir?.path}/$project').create(recursive: true);
      fetchNumberOfFiles(project, newDir);
    }
    if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      Directory newDir = await Directory('${dir.path}/$project').create();
      fetchNumberOfFiles(project, newDir);
    }
  }

  void fetchNumberOfFiles(String project, Directory newDir) async {
    List<FileSystemEntity> tempFiles = newDir.listSync();

    await Future.wait(tempFiles.map((e) async => createObject(e.path)));

    print("checkDirectoriesAndFetch FUNCTION: $filesInCurrentProject");
    // print("checkDirectoriesAndFetch FUNCTION: ${files.length}");
    // mapController.createMarkers(files);
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
