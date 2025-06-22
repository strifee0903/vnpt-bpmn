import 'package:flutter/material.dart';
import 'step1.dart';
import 'step2.dart';
import 'step3.dart';

final Map<
    String,
    Widget Function(
      VoidCallback next,
      VoidCallback back,
      bool last,
      void Function(String message) onComplete,
    )> screenRegistry = {
  'Bước 1': (next, back, last, onComplete) =>
      Step1(onNext: next, onBack: back, isLast: last, onComplete: onComplete),
  'Bước 2': (next, back, last, onComplete) =>
      Step2(onNext: next, onBack: back, isLast: last, onComplete: onComplete),
  'Bước 3': (next, back, last, onComplete) =>
      Step3(onNext: next, onBack: back, isLast: last, onComplete: onComplete),
};
