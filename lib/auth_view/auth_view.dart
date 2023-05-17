import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sign_button/sign_button.dart';
import 'package:stm_extensions/stm_extensions.dart';

import 'confirm_sms/confirm_sms.dart';

class AuthView extends StatelessWidget {
  final TextEditingController _phoneController = TextEditingController();
  final int phoneLength = 12;

  AuthView({super.key});

  sendPhoneError() {
    Get.dialog(CupertinoAlertDialog(
      title: Text('error'.tr.onlyCapitalizeFirst()),
      content: Text(
          '${'invalid phone number or login was interrupted'.tr.onlyCapitalizeFirst()}. ${'please try again'.tr.onlyCapitalizeFirst()}.'),
      actions: [
        CupertinoDialogAction(
          child: Text('ok'.tr.capitalize ?? 'ok'),
          onPressed: () {
            Get.back();
          },
        ),
      ],
    ));
  }

  sendPhone({required BuildContext context}) async {
    if (_phoneController.text.isEmpty) return;
    context.loaderOverlay.show();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        context.loaderOverlay.hide();
        // ANDROID ONLY!
        // Sign the user in (or link) with the auto-generated credential
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        context.loaderOverlay.hide();
        sendPhoneError();
      },
      codeSent: (String verificationId, int? resendToken) async {
        context.loaderOverlay.hide();
        Get.to(() => ConfirmSms(
              verificationId: verificationId,
            ))?.then((value) {});
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        context.loaderOverlay.hide();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('enter to vfs master'.tr.toUpperCase()),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.14,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: CupertinoTextField(
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(color: Colors.black),
                ),
                onSubmitted: (value) {
                  sendPhone(context: context);
                },
                placeholder: "+370 123 4567", // Lithuanian phone placeholder
                padding: const EdgeInsets.all(20),
                onChanged: (value) async {
                  if (_phoneController.text.length >= phoneLength) {
                    sendPhone(context: context);
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SignInButton(
                buttonType: ButtonType.google,
                buttonSize: ButtonSize.medium,
                btnText: 'sign in with Google'.tr.onlyCapitalizeFirst(),
                onPressed: () async {
                  final loaderOverlay = context.loaderOverlay;
                  loaderOverlay.show();
                  try {
                    final GoogleSignInAccount? googleUser =
                        await GoogleSignIn().signIn();
                    if (googleUser == null) {
                      loaderOverlay.hide();
                      return;
                    }
                    final GoogleSignInAuthentication googleAuth =
                        await googleUser.authentication;
                    final credential = GoogleAuthProvider.credential(
                      accessToken: googleAuth.accessToken,
                      idToken: googleAuth.idToken,
                    );
                    await FirebaseAuth.instance
                        .signInWithCredential(credential);
                  } catch (e) {
                    print(e.toString());
                  }
                  loaderOverlay.hide();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SignInButton(
                buttonType: ButtonType.apple,
                buttonSize: ButtonSize.medium,
                btnText: 'sign in with Apple'.tr.onlyCapitalizeFirst(),
                onPressed: () async {
                  final loaderOverlay = context.loaderOverlay;
                  loaderOverlay.show();
                  final appleProvider = AppleAuthProvider();
                  try {
                    if (kIsWeb) {
                      await FirebaseAuth.instance
                          .signInWithPopup(appleProvider);
                    } else {
                      await FirebaseAuth.instance
                          .signInWithProvider(appleProvider);
                    }
                  } catch (_) {}

                  loaderOverlay.hide();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
