import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mvp_camera/app/constant/controllers.dart';
import 'package:mvp_camera/app/utils/colors.dart';

class InAppGallery extends StatefulWidget {
  const InAppGallery({Key? key}) : super(key: key);

  @override
  State<InAppGallery> createState() => _InAppGalleryState();
}

class _InAppGalleryState extends State<InAppGallery> {

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: []);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text('Gallery', style: Theme.of(context).textTheme.headline2?.copyWith(color: primaryColor, fontSize: 17.sp, fontWeight: FontWeight.bold)),
        leading: IconButton(onPressed: () {
          navigationController.goBack();
        }, icon: Icon(Icons.chevron_left,color: primaryColor, size: 25.sp,),),
      ),
      body: Obx(() => GridView.count(
        cacheExtent: 999,
        addAutomaticKeepAlives: true,
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: myCameraController.listOfCapturedImages
            .map((image) => Image.file(image, fit: BoxFit.cover, filterQuality: FilterQuality.low,))
            .toList(),
      )),
    );
  }
}
