library sistemium_flutter_auth;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'auth_translations/auth_translations.dart';
import 'auth_view/auth_view.dart';

class Auth extends StatelessWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance
        .setLanguageCode(Get.deviceLocale?.languageCode.toString());
    return GetMaterialApp(
      translations: AuthTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      home: LoaderOverlay(
          overlayOpacity: 0.5,
          useDefaultLoading: false,
          overlayWidget: const Center(
            child: CircularProgressIndicator(),
          ),
          child: AuthView()),
    );
  }
}
