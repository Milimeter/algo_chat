import 'package:flutter/material.dart';
import 'package:get/get.dart';

showLoading() => Get.defaultDialog(
      title: "Loading...",
      content: Center(
        child: CircularProgressIndicator(),
      ),
    );

dismissLoading() => Get.back();
