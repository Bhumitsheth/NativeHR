import 'package:attendanceapp/utils/responsive_flutter.dart';
import 'package:flutter/material.dart';

import 'common_method.dart';

class NoInternetDialog extends StatelessWidget {
  NoInternetDialog(this.onRetryPressed);

  Function()? onRetryPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,size: 250,),
          SizedBox(height: 20),
          Text(
            'No Internet Connection!',
            style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(24),),

          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your internet connection is down. please fix it and then you can continue using Nativeway Hr',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(18), color: Colors.grey, height: 1.2,),
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () async {
              bool hasInternet = await isInternetAvailable();
              if (hasInternet) {
                onRetryPressed!();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40),
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveFlutter.of(context).scale(100),
                ),
              ),
              textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            child: Text(
              "Retry",
              style: TextStyle(color: Colors.white),
            ),
          )
          // FilledButtonView(
          //   "Retry",
          //   fontWeight: FontWeight.w600,
          //   color: Color(primaryColor),
          //   textColor: Color(whiteColor),
          //   onPressed: () async {
          //     bool hasInternet = await isInternetAvailable();
          //     if (hasInternet) {
          //       onRetryPressed!();
          //     }
          //   },
          //   horizontalPadding: 40,
          //   borderRad: ResponsiveFlutter.of(context).scale(Dimens.dimen_100dp),
          // ),
        ],
      ),
    );
  }
}
