import 'dart:convert';
import 'dart:io';
import 'package:edit_exif/edit_exif.dart' as edt;
import 'dart:typed_data';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:metadata/metadata.dart' as meta;
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvp_camera/app/utils/angle_calculator.dart';
import 'package:mvp_camera/app/utils/handle_file.dart';
import 'package:mvp_camera/controller/map_controller.dart';
import 'package:mvp_camera/model/file_data_model.dart';
import 'package:path_provider/path_provider.dart';

import '../app/constant/controllers.dart';
import '../app/utils/dialogs.dart';
import 'navigation_controller.dart';

class FetchFilesController extends GetxController {
  static FetchFilesController instance = Get.find();

  var listOfProjects = <FileSystemEntity>[].obs;
  var listOfAvailableProject = <String>[].obs;
  var filesInCurrentProject = <FileDataModel>[].obs;
  var filesInCurrentProjectForIos = <FileDataModelForIos>[].obs;

  double freeDiskSpace = 0.0;
  double totalDiskSpace = 0.0;

  Future<FileDataModel> createObject(String filePath) async {
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


    String latitudeRef = content.exifData['gps']['GPSLatitudeRef'];
    String longitudeRef =  content.exifData['gps']['GPSLongitudeRef'];

    // FETCHING GYRO INFO FROM NAME OF FILE
    Map<String, dynamic> gyroInfo = splitStringFromPercentageForGyro(filePath);
    Map<String, dynamic> absoluteOrientation =
        splitStringFromPercentageForAbsoluteOrientation(filePath);

    AngleCalculator angleCalculations = AngleCalculator(
        yaw: double.parse(absoluteOrientation['yaw'].toString()),
        roll: double.parse(absoluteOrientation['roll'].toString()),
        pitch: double.parse(absoluteOrientation['pitch'].toString()));

    return FileDataModel(
        imageFile: imageFile,
        fileData: fileData,
        position: latLng,
        metaData: content.exifData,
        gyroInfo: gyroInfo,
        absoluteOrientation: absoluteOrientation,
        angleCalculations: angleCalculations, latitudeRef:latitudeRef, longitudeRef: longitudeRef);
  }

  Future<FileDataModelForIos> createObjectForIos(String filePath) async {
    HandleFile handleFile = HandleFile();

    // CREATING FILE
    File imageFile = File(filePath);

    edt.FlutterExif fileData = handleFile.getExifForIos(imageFile.path);
    Map exifData = await fileData.getExif('GPS');
    dynamic latLongData = exifData["{GPS}"];
    // print("LATLONGDATA FROM CREATE OBJECT FUNCTION IOS: $latLongData");
    LatLng latLng = const LatLng(0.0, 0.0);

    String latitudeRef = latLongData['LatitudeRef'];
    String longitudeRef = latLongData['LongitudeRef'];

    latLng = LatLng(latLongData['Latitude'], latLongData['Longitude']);

    if(latitudeRef == "S"){
      latLng = LatLng(0 - double.parse(latLongData['Latitude'].toString()), latLongData['Longitude']);
    }

    if(longitudeRef == "W"){
      latLng = LatLng(latLongData['Latitude'], 0 - double.parse(latLongData['Longitude'].toString()));
    }


    // print(latLongData);
    // print(latLng);


    // return FileDataModel(imageFile: null);

    // FETCHING GYRO INFO FROM NAME OF FILE
    Map<String, dynamic> gyroInfo = splitStringFromPercentageForGyro(filePath);
    Map<String, dynamic> absoluteOrientation =
        splitStringFromPercentageForAbsoluteOrientation(filePath);

    // print(absoluteOrientation);

    AngleCalculator angleCalculations = AngleCalculator(
        yaw: double.parse(absoluteOrientation['yaw']),
        roll: double.parse(absoluteOrientation['roll'].toString()),
        pitch: double.parse(absoluteOrientation['pitch'].toString()));

    return FileDataModelForIos(
        imageFile: imageFile,
        fileData: fileData,
        metaData: exifData,
        position: latLng,
        gyroInfo: gyroInfo,
        absoluteOrientation: absoluteOrientation,
        angleCalculations: angleCalculations,
        latitudeRef: latitudeRef,
        longitudeRef: longitudeRef);
  }

  Future<void> initializeDeviceStorageInfo() async {
    freeDiskSpace = (await DiskSpace.getFreeDiskSpace)!;
    totalDiskSpace = (await DiskSpace.getTotalDiskSpace)!;
  }

  @override
  void onInit() {
    initializeDeviceStorageInfo();
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
    print(myCameraController.projectNameController.value.text);
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
    List<FileDataModel> files = <FileDataModel>[];
    List<FileDataModelForIos> iosFile = <FileDataModelForIos>[];
    await Future.wait(tempFiles.map((e) async {
      if (Platform.isAndroid) {
        FileDataModel obj = await createObject(e.path);
        files.add(obj);
      } else {
        FileDataModelForIos obj = await createObjectForIos(e.path);

        iosFile.add(obj);
      }
    })).whenComplete(() async {
      if (Platform.isAndroid) {
        filesInCurrentProject.value = files;
        myCameraController.totalImagesCaptured.value = files.length;
        if (filesInCurrentProject.isNotEmpty) {
          mapController.animateCamera(CameraPosition(
              target: LatLng(
                filesInCurrentProject[0].position.latitude,
                filesInCurrentProject[0].position.longitude,
              ),
              zoom: 15.00));
        }
      } else {
        filesInCurrentProjectForIos.value = iosFile;
        myCameraController.totalImagesCaptured.value = iosFile.length;
        if (filesInCurrentProjectForIos.isNotEmpty) {
          mapController.animateCamera(CameraPosition(
              target: LatLng(
                filesInCurrentProjectForIos[0].position.latitude,
                filesInCurrentProjectForIos[0].position.longitude,
              ),
              zoom: 15.00));
        }
      }
      mapController.createMarkers();
    });
  }

  List<String> splitAvailableProjects() {
    List<String> tempProjects = <String>[];

    for (var element in listOfProjects) {
      // BREAKING DIRECTORIES
      List<String> subStringsList = element.path.split('/');
      // ADDING LAST INDEX OF BROKEN DIRECTORY WHICH INCLUDES PROJECT NAME
      // EXCLUDING CSV FOLDER
      if (subStringsList[subStringsList.length - 1] != 'csv') {
        tempProjects.add(subStringsList[subStringsList.length - 1]);
      }
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

  Map<String, dynamic> splitStringFromPercentageForGyro(String path) {
    String splittedPathName = path.split('/').last;
    int indexOfPercentage = splittedPathName.indexOf('%');
    int indexOfMimeTypeDot = splittedPathName.indexOf('.jpeg');

    String info =
        splittedPathName.substring(indexOfPercentage + 1, indexOfMimeTypeDot);

    List<String> listOfPercentage = info.split('%');

    Map<String, dynamic> gyroInfoDecoded = jsonDecode(listOfPercentage[0]);

    return gyroInfoDecoded;
  }

  Map<String, dynamic> splitStringFromPercentageForAbsoluteOrientation(
      String path) {
    String splittedPathName = path.split('/').last;
    int indexOfPercentage = splittedPathName.indexOf('%');
    int indexOfMimeTypeDot = splittedPathName.indexOf('.jpeg');

    String info =
        splittedPathName.substring(indexOfPercentage + 1, indexOfMimeTypeDot);

    List<String> listOfPercentage = info.split('%');

    Map<String, dynamic> acceleroMeterDecoded = jsonDecode(listOfPercentage[1]);

    return acceleroMeterDecoded;
  }
}
