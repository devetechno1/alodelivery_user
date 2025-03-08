import 'package:get/get.dart';

extension StringHelper on String{
  String get removeZerosInFirst => replaceFirst(RegExp(r'^0+'), '').trim();
  String getTranslateWithArg([String wordToChange = '', String value = '']){
  return tr.replaceAll(wordToChange, value);
}
}