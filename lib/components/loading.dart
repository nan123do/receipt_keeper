import 'package:flutter/material.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/utils/theme.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var orientation = MediaQuery.of(context).orientation;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: size.height / 3.5,
          ),
          Center(
            child: Column(
              children: [
                orientation == Orientation.portrait
                    ? Image.asset(
                        'assets/logo/logo.png',
                        height: 180,
                        width: 300,
                      )
                    : Container(),
                const CircularProgressIndicator(),
                20.gap,
                Text(
                  'Sedang memuat data... ',
                  style: TextStyle(
                    color: CareraTheme.mainColor,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
