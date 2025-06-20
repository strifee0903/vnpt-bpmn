import 'package:flutter/material.dart';
import 'step1.dart';
import 'step2.dart';
import 'step3.dart';

final Map<String,
        Widget Function(VoidCallback next, VoidCallback back, bool last)>
    screenRegistry = {
  'Bước 1': (next, back, last) =>
      Step1(onNext: next, onBack: back, isLast: last),
  'Bước 2': (next, back, last) =>
      Step2(onNext: next, onBack: back, isLast: last),
  'Bước 3': (next, back, last) =>
      Step3(onNext: next, onBack: back, isLast: last),
};
