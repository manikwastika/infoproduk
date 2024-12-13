import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../controllers/barcode_controller.dart';
import '../widgets/scanner_overlay_painter.dart';
import '../widgets/scanner_button.dart';

class ScannerScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  final controller = Get.find<BarcodeController>();

  ScannerScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed('/');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan Barcode'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.offAllNamed('/'),
          ),
        ),
        body: Obx(() {
          if (controller.cameraController.value == null ||
              !controller.cameraController.value!.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              SizedBox(
                width: screenWidth,
                height: screenHeight,
                child: CameraPreview(controller.cameraController.value!),
              ),
              Positioned(
                top: screenHeight * 0.2,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: screenWidth * 0.7,
                    height: screenWidth * 0.7,
                    child: CustomPaint(
                      painter: ScannerOverlayPainter(
                        animation: controller.animation,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: Icon(
                    controller.isFlashOn.value
                        ? Icons.flash_on
                        : Icons.flash_off,
                    color: Colors.white,
                  ),
                  onPressed: controller.toggleFlash,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: screenHeight * 0.15,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScannerButton(
                          text: 'Scan Image',
                          width: screenWidth * 0.40,
                          onPressed: controller.pickImage,
                        ),
                        SizedBox(width: screenWidth * 0.05),
                        Container(
                          width: 1,
                          color: Color.fromARGB(255, 146, 146, 146),
                          height: 40,
                        ),
                        SizedBox(width: screenWidth * 0.05),
                        ScannerButton(
                          text: 'Manually',
                          width: screenWidth * 0.40,
                          onPressed: () => Get.toNamed('/manual-input'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
