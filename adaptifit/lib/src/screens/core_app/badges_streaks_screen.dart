import 'package:flutter/material.dart';
import 'package:adaptifit/src/constants/app_colors.dart';

class BadgesStreaksScreen extends StatelessWidget {
  const BadgesStreaksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withAlpha(127),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withAlpha(12),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.primaryGreen,
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 0,
                  child: Icon(
                    Icons.show_chart,
                    color: AppColors.grey.withAlpha(178),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: 10,
                  child: Icon(
                    Icons.access_time,
                    size: 20,
                    color: AppColors.grey.withAlpha(178),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This feature will be available in a future update.\nStay tuned!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: AppColors.subtitleGray,
                height: 1.5,
              ),
            ),
            const Spacer(flex: 3),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  side:
                      const BorderSide(color: AppColors.primaryGreen, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  foregroundColor: AppColors.primaryGreen,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
