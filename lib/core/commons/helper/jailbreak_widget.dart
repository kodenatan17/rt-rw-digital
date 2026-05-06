import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasconnect/core/commons/components/atoms/button/button.dart';
import 'package:pasconnect/core/commons/components/atoms/colors/colors.dart';
import 'package:pasconnect/core/commons/components/atoms/text/text.dart';

class JailbreakWidget extends StatelessWidget {
  const JailbreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              BaseText.titleMediumBold(
                text: "Jaibreak Detected",
                textColor: AppColors.primaryBackground,
              ),
              const SizedBox(height: 10),
              BaseText.bodyMediumBold(
                text: "Sakura is not supported on jaibroken devices",
                textColor: AppColors.primaryBackground,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: BaseButton.filled(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  height: 40,
                  text: "Exit App",
                  textColor: AppColors.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}