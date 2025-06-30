import 'package:flutter/material.dart';
import 'step1.dart';
import 'step2.dart';
import 'step3.dart';
import 'chat.dart';

final Map<
    String,
    Widget Function(
      VoidCallback next,
      VoidCallback back,
      bool last,
      void Function(String message) onComplete,
    )> screenRegistry = {
  'Nhập thông tin chiến dịch': (next, back, last, onComplete) =>
      Step1(onNext: next, onBack: back, isLast: last, onComplete: onComplete),
  'Chia sẻ chiến dịch': (next, back, last, onComplete) =>
      Step2(onNext: next, onBack: back, isLast: last, onComplete: onComplete),
  'Mời tham gia': (next, back, last, onComplete) =>
      Step3(onNext: next, onBack: back, isLast: last, onComplete: onComplete),
  'Phòng trò chuyện': (next, back, last, onComplete) =>
      Chat(onNext: next, onBack: back, isLast: last, onComplete: onComplete),
};
