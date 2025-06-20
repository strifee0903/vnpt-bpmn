import 'package:flutter/material.dart';
import 'step1.dart';
import 'step2.dart';
import 'step3.dart';

final Map<String, Widget Function(VoidCallback next, VoidCallback back)>
    screenRegistry = {
  'Bước 1': (next, back) => Step1(onNext: next, onBack: back),
  'Bước 2': (next, back) => Step2(onNext: next, onBack: back),
  'Bước 3': (next, back) => Step3(onNext: next, onBack: back),
};
