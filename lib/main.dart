import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/pages/Onboarding.dart';


void main() => runApp(
      EasyLocalization(
          supportedLocales: [Locale('en', 'US'), Locale('bn', 'BD')],
          path: 'lang', // <-- change patch to your
          fallbackLocale: Locale('en', 'US'),
          child: MyApp()),
    );

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Onboarding(),
    );
  }
}
