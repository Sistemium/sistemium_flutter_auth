import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stm_extensions/stm_extensions.dart';

class ConfirmSms extends StatelessWidget {
  final smsLength = 6;
  final String verificationId;
  const ConfirmSms({super.key, required this.verificationId});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('enter to vfs master'.tr.toUpperCase()),
      ),
      child: SafeArea(
        child: Material(
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.15,
              left: 20,
              right: 20,
            ),
            child: PinCodeTextField(
              appContext: context,
              length: smsLength,
              obscureText: false,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                selectedFillColor: Colors.grey.shade200,
                borderWidth: 2,
                activeColor: Colors.grey.shade800, // Active border color
                inactiveColor: Colors.grey.shade400, // Inactive border color
                selectedColor: Colors.grey.shade800, // Selected border color
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) async {
                if (value.length == smsLength) {
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: verificationId, smsCode: value);
                  FirebaseAuth.instance
                      .signInWithCredential(credential)
                      .then((value) {
                    Get.back();
                  }).catchError((e) {
                    if (e.message
                        .contains('phone auth credential is invalid')) {
                      Get.dialog(CupertinoAlertDialog(
                        title: Text('error'.tr.onlyCapitalizeFirst()),
                        content: Text(
                            '${'phone auth credential is invalid'.tr.onlyCapitalizeFirst()}. ${'please try again'.tr.onlyCapitalizeFirst()}.'),
                        actions: [
                          CupertinoDialogAction(
                            child: Text('ok'.tr.capitalize ?? 'ok'),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                        ],
                      ));
                      return;
                    }
                    if (e.message.contains('SMS code has expired')) {
                      Get.dialog(CupertinoAlertDialog(
                        title: Text('error'.tr.onlyCapitalizeFirst()),
                        content: Text(
                            '${'SMS code has expired'.tr.onlyCapitalizeFirst()}. ${'please try again'.tr.onlyCapitalizeFirst()}.'),
                        actions: [
                          CupertinoDialogAction(
                            child: Text('ok'.tr.capitalize ?? 'ok'),
                            onPressed: () {
                              Get.back();
                              Get.back();
                            },
                          ),
                        ],
                      ));
                      return;
                    }
                    Get.back();
                  });
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
