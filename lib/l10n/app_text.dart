import 'package:flutter/material.dart';

bool isEnglish(BuildContext context) => Localizations.localeOf(context).languageCode == 'en';

String tr(BuildContext context, String vi, String en) => isEnglish(context) ? en : vi;
