import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:reward_hub_customer/Utils/SharedPrefrence.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/Utils/phone_dialer.dart';
import 'package:reward_hub_customer/profile/profile_screen.dart';
import 'package:reward_hub_customer/provider/user_data_provider.dart';
import 'package:reward_hub_customer/store/model/search_vendor_details.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:reward_hub_customer/store/model/search_filter_store_model.dart'
    as filter;

class StoreDetails extends StatefulWidget {
  final dynamic storeList;
  StoreDetails({
    super.key,
    this.storeList,
  });
  @override
  State<StoreDetails> createState() => StoreDetailsState();
}

class StoreDetailsState extends State<StoreDetails> {
  List<String> imgList = [];
  List<String> tagList = [];
  static const platform = MethodChannel('dialer.channel/call');
  @override
  void initState() {
    super.initState();
    if (widget.storeList is Vendor) {
      imgList = [
        widget.storeList.vendorBusinessPicUrl1 ?? "",
        widget.storeList.vendorBusinessPicUrl2 ?? "",
        widget.storeList.vendorBusinessPicUrl3 ?? "",
        widget.storeList.vendorBusinessPicUrl4 ?? "",
        widget.storeList.vendorBusinessPicUrl5 ?? "",
        widget.storeList.vendorBusinessPicUrl6 ?? "",
      ];
    } else if (widget.storeList is filter.Vendor) {
      imgList = [
        widget.storeList.vendorBusinessPicUrl1 ?? "",
        widget.storeList.vendorBusinessPicUrl2 ?? "",
        widget.storeList.vendorBusinessPicUrl3 ?? "",
        widget.storeList.vendorBusinessPicUrl4 ?? "",
        widget.storeList.vendorBusinessPicUrl5 ?? "",
      ];
    }
    tagList = widget.storeList.vendorCategories.split(',');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildAppBar(context),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    homeTopBannerWidget(),
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(Icons.arrow_back, size: 30),
            ),
          ),
          Expanded(
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
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ProfileScreen()));
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
                            borderRadius: BorderRadius.all(Radius.circular(20)),
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
          // Padding(
          //   padding: EdgeInsets.only(right: 10),
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(20),
          //     child: Consumer<UserData>(
          //       builder: (context, userdata, _) {
          //         String profilePhotoPath =
          //             SharedPrefrence().getUserProfilePhoto();
          //         File profilePhotoFile = File(profilePhotoPath);
          //         return profilePhotoFile.existsSync()
          //             ? Image.file(
          //                 profilePhotoFile,
          //                 height: 40,
          //                 width: 40,
          //                 fit: BoxFit.fill,
          //               )
          //             : Image.asset(
          //                 "assets/images/ic_profile.png",
          //                 height: 40,
          //                 width: 40,
          //                 fit: BoxFit.cover,
          //               );
          //       },
          //     ),
          //   ),),
        ],
      ),
    );
  }

  Widget _buildStoreInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.storeList is Vendor
                  ? widget.storeList.vendorBusinessName ?? ""
                  : (widget.storeList is filter.Vendor
                      ? widget.storeList.vendorBusinessName ?? ""
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
                widget.storeList is Vendor
                    ? "${widget.storeList.landMark ?? ""}"
                    : (widget.storeList is filter.Vendor
                        ? '${widget.storeList.landMark ?? ""}'
                        : '')),
            _buildInfoRow(
                Icons.place,
                "Place:",
                widget.storeList is Vendor
                    ? "${widget.storeList.vendorPlaceName ?? ""}"
                    : (widget.storeList is filter.Vendor
                        ? '${widget.storeList.vendorBranchName ?? ""}'
                        : '')),
            _buildInfoRow(
                Icons.location_city,
                "Town:",
                widget.storeList is Vendor
                    ? "${widget.storeList.vendorTownName ?? ""}"
                    : (widget.storeList is filter.Vendor
                        ? '${widget.storeList.vendorAddressL1 ?? ""}'
                        : '')),
            _buildInfoRow(
                Icons.map,
                "District:",
                widget.storeList is Vendor
                    ? "${widget.storeList.vendorDistrictName ?? ""}"
                    : (widget.storeList is filter.Vendor
                        ? '${widget.storeList.vendorBranchName ?? ""}'
                        : '')),
            _buildInfoRow(
                Icons.pin_drop,
                "Pin Code:",
                widget.storeList is Vendor
                    ? "${widget.storeList.vendorPinCode ?? ""}"
                    : (widget.storeList is filter.Vendor
                        ? '${widget.storeList.vendorPinCode ?? ""}'
                        : '')),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  makePhoneCall(
                      context,
                      widget.storeList is Vendor
                          ? widget.storeList.vendorRegisteredMobileNumber
                                  .toString() ??
                              ""
                          : (widget.storeList is filter.Vendor
                              ? widget.storeList.vendorRegisteredMobileNumber
                                      .toString() ??
                                  ""
                              : ''),
                      platform);
                },
                icon: Icon(
                  Icons.call,
                  color: Colors.white,
                ),
                label: Text(''),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
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
              widget.storeList is Vendor
                  ? widget.storeList.vendorBusinessDescription ?? ""
                  : (widget.storeList is filter.Vendor
                      ? widget.storeList.vendorBusinessDescription ?? ""
                      : ''),
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
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
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget homeTopBannerWidget() {
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
                height: 250,
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
}
