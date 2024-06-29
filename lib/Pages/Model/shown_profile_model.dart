import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormData {
  late final String igusername;
  late final String phrase;
  late final Map<String, dynamic> package;

  var image;

  FormData({
    required this.igusername,
    required this.phrase,
    required this.package,
    required this.image,
  });
}

class ShownProfileController extends GetxController {
  final FormData formData = FormData(
    igusername: '',
    phrase: '',
    image: null,
    package: {},
  );

  @override
  void onInit() {
    super.onInit();
  }

  void onSubmit() async {
    // Make an HTTP request to submit the form data to the server
    // ...
    Get.snackbar('Form submitted successfully!', '');
  }
}
