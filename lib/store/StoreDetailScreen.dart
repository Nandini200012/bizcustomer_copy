import 'dart:io';
// import 'dart:nativewrappers/_internal/vm/lib/developer.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:reward_hub_customer/Utils/SharedPrefrence.dart';
import 'package:reward_hub_customer/Utils/phone_dialer.dart';
import 'package:reward_hub_customer/profile/profile_screen.dart';
import 'package:reward_hub_customer/provider/user_data_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Utils/constants.dart';
import 'model/filter_model.dart' as filter;
import 'model/store_model.dart';

class StoreDetailScreen extends StatefulWidget {
  final dynamic storeList;

  StoreDetailScreen(this.storeList);

  @override
  State<StatefulWidget> createState() {
    return StoreDetailScreenState(this.storeList);
  }
}

class StoreDetailScreenState extends State<StoreDetailScreen> {
  List<String> imgList = [];
  List<String> tagList = [];
  dynamic storeList;
  static const platform = MethodChannel('dialer.channel/call');
  StoreDetailScreenState(this.storeList);

  @override
  void initState() {
    super.initState();
    print("StoreList Data=======: ${storeList}");
    debugPrint("StoreList Full Data: ${storeList.toString()}", wrapWidth: 1024);

    if (storeList is StoreModel) {
      imgList = [
        storeList.imageURL1 ?? "",
        storeList.imageURL2 ?? "",
        storeList.imageURL3 ?? "",
        storeList.imageURL4 ?? "",
        storeList.imageURL5 ?? "",
        storeList.imageURL6 ?? "",
      ];
    } else if (storeList is filter.Vendor) {
      imgList = [
        storeList.vendorBusinessPicUrl1 ?? "",
        storeList.vendorBusinessPicUrl2 ?? "",
        storeList.vendorBusinessPicUrl3 ?? "",
        storeList.vendorBusinessPicUrl4 ?? "",
        storeList.vendorBusinessPicUrl5 ?? "",
      ];
    }
    tagList = storeList.vendorCategories.split(',');
  }

  Widget profileImage() => FullScreenWidget(
        disposeLevel: DisposeLevel.High,
        child: Hero(
          tag: "profile_image",
          child: Consumer<UserData>(
            builder: (context, userdata, _) {
              String profilePhotoPath = SharedPrefrence().getUserProfilePhoto();
              File profilePhotoFile = File(profilePhotoPath);
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: profilePhotoFile.existsSync()
                    ? Image.file(
                        File(SharedPrefrence().getUserProfilePhoto()),
                        height: 40,
                        width: 40,
                        fit: BoxFit.fill,
                      )
                    : Image.asset(
                        "assets/images/ic_profile.png",
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
              );
            },
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 0,
              child: Container(
                height: 50,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 0,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back, size: 30),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "STORE",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Padding(
                        padding: EdgeInsets.only(right: 10.w, top: 10.h),
                        child: GestureDetector(
                          onTap: () {
                            //Navigator.pop(context, true);
                            //Navigator.push(context, SlideRightRoute(page: IntroScreen()));
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ProfileScreen()));
                            // Navigator.push(
                            //     context,
                            //     PageTransition(
                            //         type: PageTransitionType.rightToLeft,
                            //         child: ProfileScreen()));
                          },
                          child: Consumer<UserData>(
                            builder: (context, userData, _) {
                              String profilePhotoPath =
                                  SharedPrefrence().getUserProfilePhoto();
                              File profilePhotoFile = File(profilePhotoPath);
                              return profilePhotoFile.existsSync()
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      child: Image.file(
                                        profilePhotoFile,
                                        height: 40.h,
                                        width: 40.w,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      "assets/images/ic_profile.png",
                                      height: 40.h,
                                      width: 40.w,
                                    );
                            },
                            // child: Image.asset(
                            //   "assets/images/ic_profile.png",
                            //   height: 40.h,
                            //   width: 40.w,
                            // ),
                          ),
                        ),
                      ),
                    )
                    // Expanded(
                    //   flex: 0,
                    //   child: Padding(
                    //     padding: EdgeInsets.only(right: 10),
                    //     child: profileImage(),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    homeTopBannerWidget(storeList),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          _buildStoreInfoCard(),
                          SizedBox(height: 10),
                          _buildDescriptionCard(),
                          SizedBox(height: 10),
                          _buildTags(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              storeList is StoreModel
                  ? storeList.name ?? ""
                  : (storeList is filter.Vendor
                      ? storeList.vendorBusinessName ?? ""
                      : ''),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _buildInfoRow(
              Icons.location_on,
              "Landmark:",
              storeList is StoreModel
                  ? "${storeList.landMark ?? ""}"
                  : (storeList is filter.Vendor
                      ? '${storeList.landMark ?? ""}'
                      : ''),
            ),
            _buildInfoRow(
              Icons.place,
              "Place:",
              storeList is StoreModel
                  ? "${storeList.placeName ?? ""}"
                  : (storeList is filter.Vendor
                      ? '${storeList.vendorplaceName ?? ""}'
                      : ''),
            ),
            _buildInfoRow(
              Icons.location_city,
              "Town:",
              storeList is StoreModel
                  ? "${storeList.townName ?? ""}"
                  : (storeList is filter.Vendor
                      ? '${storeList.vendorTownName ?? ""}'
                      : ''),
            ),
            _buildInfoRow(
              Icons.map,
              "District:",
              storeList is StoreModel
                  ? "${storeList.districtName ?? ""}"
                  : (storeList is filter.Vendor
                      ? '${storeList.vendordistrictName ?? ""}'
                      : ''),
            ),
            _buildInfoRow(
              Icons.pin_drop,
              "Pin Code:",
              storeList is StoreModel
                  ? "${storeList.vendorPincode ?? ""}"
                  : (storeList is filter.Vendor
                      ? '${storeList.vendorPinCode ?? ""}'
                      : ''),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  makePhoneCall(
                      context, // Pass BuildContext here
                      storeList is StoreModel
                          ? storeList.mobileNumber ?? ""
                          : (storeList is filter.Vendor
                              ? storeList.vendorRegisteredMobileNumber
                                      .toString() ??
                                  ""
                              : ''),
                      platform);
                  // log("mobile number: ${storeList.mobileNumber}");
                },
                icon: Center(child: Icon(Icons.call, color: Colors.white)),
                label: Text(""),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Description",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(
              storeList is StoreModel
                  ? storeList.discription ?? ""
                  : (storeList is filter.Vendor
                      ? storeList.vendorBusinessDescription ?? ""
                      : ''),
              // textAlign: TextAlign.justify,
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Categories",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            ListView.separated(
              shrinkWrap:
                  true, // Ensures the ListView takes only the needed space
              physics:
                  NeverScrollableScrollPhysics(), // Prevents scrolling inside the ListView
              itemCount: tagList.length,
              separatorBuilder: (context, index) => SizedBox(height: 5),
              itemBuilder: (context, index) {
                return IntrinsicWidth(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Constants().appColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tagList[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget homeTopBannerWidget(dynamic storeList) {
    List<String> nonEmptyImageUrls =
        imgList.where((url) => url != null && url.isNotEmpty).toList();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.only(top: 0, bottom: 20),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 200,
                autoPlayAnimationDuration: Duration(milliseconds: 500),
                autoPlay: nonEmptyImageUrls.length > 1,
                autoPlayInterval: Duration(seconds: 2),
                autoPlayCurve: Curves.fastOutSlowIn,
                viewportFraction: 1,
              ),
              items: nonEmptyImageUrls
                  .map(
                    (item) => Container(
                      child: CachedNetworkImage(
                        imageUrl: item,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fitHeight,
                              colorFilter: ColorFilter.mode(
                                Colors.black54.withOpacity(0.5),
                                BlendMode.lighten,
                              ),
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Center(
                          child: CupertinoActivityIndicator(
                            color: Colors.black,
                            radius: 16,
                          ),
                        ),
                      ),
                      margin: EdgeInsets.only(right: 0, left: 0),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> makePhoneCall(context, phoneNumber, platform) async {
  if (phoneNumber.isEmpty) return;

  if (Platform.isAndroid) {
    try {
      await platform.invokeMethod('makeCall', {'number': phoneNumber});
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to make call: ${e.message}")),
      );
    }
  } else if (Platform.isIOS) {
    final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot launch dialer")),
      );
    }
  }
}
//   final status = await Permission.phone.status;
//   if (status.isDenied || status.isPermanentlyDenied) {
//     final result = await Permission.phone.request();
//     if (!result.isGranted) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text("Phone call permission denied"),
//       ));
//       return;
//     }
//   }

//   try {
//     await platform.invokeMethod('makeCall', {'number': phoneNumber});
//   } on PlatformException catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text("Failed to make call: ${e.message}"),
//     ));
//   }
// }
// Future<void> makePhoneCall(BuildContext context, String phoneNumber) async {
//   final status = await Permission.phone.status;

//   if (status.isGranted) {
//     // Permission granted — proceed to call
//     try {
//       await PhoneDialer.makeCall(context, phoneNumber);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not launch dialer: $e')),
//       );
//     }
//   } else {
//     // Request permission
//     final result = await Permission.phone.request();
//     if (result.isGranted) {
//       try {
//         await PhoneDialer.makeCall(context, phoneNumber);
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Could not launch dialer: $e')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Phone call permission denied')),
//       );
//     }
//   }
// }
// Future<void> makePhoneCall(BuildContext context, String phoneNumber) async {
//   await PhoneDialer.makeCall(context, phoneNumber);
// }
