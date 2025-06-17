import 'package:flutter/material.dart';
import 'screen1.dart';
import 'screen2.dart';
import 'screen3.dart';

final Map<String, Widget Function()> screenRegistry = {
  'Bước 1': () => Screen1(),
  'Bước 2': () => Screen2(),
  'Bước 3': () => Screen3(),
};
