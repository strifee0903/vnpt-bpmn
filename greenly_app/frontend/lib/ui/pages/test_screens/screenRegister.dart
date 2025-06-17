import 'package:flutter/material.dart';
import 'package:greenly_app/ui/pages/screens/screen1.dart';
import 'package:greenly_app/ui/pages/screens/screen2.dart';
import 'package:greenly_app/ui/pages/screens/screen3.dart';

final Map<String, Widget Function()> screenRegistry = {
  'Bước 1': () => Screen1(),
  'Bước 2': () => Screen2(),
  'Bước 3': () => Screen3(),
};
