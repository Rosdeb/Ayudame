import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showActionLoadingDialog() {
  if (Get.isDialogOpen == true) return;
  Get.dialog(
    const Center(
      child: CircularProgressIndicator(color: Color(0xFF1E523F)),
    ),
    barrierDismissible: false,
    barrierColor: Colors.black26,
  );
}

void hideActionLoadingDialog() {
  if (Get.isDialogOpen == true) {
    Get.back();
  }
}
