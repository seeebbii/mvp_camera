import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app/constant/controllers.dart';
import '../../app/utils/colors.dart';

class QaRootScreen extends StatefulWidget {
  const QaRootScreen({Key? key}) : super(key: key);

  @override
  _QaRootScreenState createState() => _QaRootScreenState();
}

class _QaRootScreenState extends State<QaRootScreen> {

  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
    //     overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
    //     overlays: []);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if(mounted){debugPrint("Mounted");}else{debugPrint("Not Mounted");}
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Obx(() => GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: mapController.currentLocationCameraPosition.value,
            onMapCreated: (GoogleMapController controller) {
              mapController.googleMapController.complete(controller);
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
          )),
          Positioned(
            top: 3.sp,
            left: 3.sp,
            child: ElevatedButton(onPressed: () { navigationController.goBack(); },
              child: Text("Back", style: Theme.of(context).textTheme.headline1?.copyWith(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),),
              style: ElevatedButton.styleFrom(
                onPrimary: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                primary: primaryColor,
                shape: RoundedRectangleBorder( //to set border radius to button
                    borderRadius: BorderRadius.circular(12)
                ),
              ),),
          ),
        ],
      ),
    );
  }
}
