import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';

class AnimationControllerProvider extends GetxController
    with GetSingleTickerProviderStateMixin {}

class BarcodeController extends GetxController {
  final List<CameraDescription> cameras;
  final Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  final RxBool isScanning = false.obs;
  final RxBool isFlashOn = false.obs;
  final RxString currentBarcode = ''.obs;
  final Rx<Product?> currentProduct = Rx<Product?>(null);
  final ApiService _apiService = ApiService();

  late AnimationController animationController;
  late Animation<double> animation;

  BarcodeController(this.cameras);

  @override
  void onInit() {
    super.onInit();
    _initializeScreen();
  }

  void _initializeScreen() {
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: Get.find<AnimationControllerProvider>(),
    )..repeat(reverse: true);

    animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      if (cameras.isEmpty) return;

      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      if (cameraController.value != null) {
        await cameraController.value!.dispose();
        cameraController.value = null;
      }

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888,
      );

      await controller.initialize();
      cameraController.value = controller;
      isScanning.value = true;
      startScanning();
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void resetScanner() {
    isScanning.value = false;
    if (cameraController.value != null) {
      cameraController.value!.dispose();
      cameraController.value = null;
    }
    _initializeCamera();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        scanBarcodeFromImage(image.path);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> scanBarcodeFromImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final barcodeScanner = GoogleMlKit.vision.barcodeScanner();

    try {
      final List<Barcode> barcodes =
          await barcodeScanner.processImage(inputImage);
      if (barcodes.isNotEmpty && barcodes[0].displayValue != null) {
        processBarcode(barcodes[0].displayValue!);
      } else {
        showErrorDialog();
      }
    } catch (e) {
      print('Error scanning barcode: $e');
      showErrorDialog();
    } finally {
      barcodeScanner.close();
    }
  }

  Future<void> startScanning() async {
    if (!isScanning.value || cameraController.value == null) return;

    try {
      final image = await cameraController.value!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final barcodeScanner = GoogleMlKit.vision.barcodeScanner();

      final barcodes = await barcodeScanner.processImage(inputImage);
      if (barcodes.isNotEmpty && barcodes[0].displayValue != null) {
        processBarcode(barcodes[0].displayValue!);
      } else if (isScanning.value) {
        Future.delayed(Duration(milliseconds: 500), startScanning);
      }

      await barcodeScanner.close();
    } catch (e) {
      print('Error scanning barcode: $e');
      if (isScanning.value) {
        Future.delayed(Duration(milliseconds: 500), startScanning);
      }
    }
  }

  Future<void> processBarcode(String barcode) async {
    try {
      currentBarcode.value = barcode;
      final product = await _apiService.getProductByBarcode(barcode);

      if (product != null) {
        currentProduct.value = product;
        Get.toNamed('/product-info');
      } else {
        showErrorDialog();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch product information',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> toggleFlash() async {
    try {
      if (cameraController.value != null) {
        if (isFlashOn.value) {
          await cameraController.value!.setFlashMode(FlashMode.off);
        } else {
          await cameraController.value!.setFlashMode(FlashMode.torch);
        }
        isFlashOn.value = !isFlashOn.value;
      }
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  void submitManualBarcode(String barcode) {
    if (barcode.isNotEmpty) {
      processBarcode(barcode);
    } else {
      Get.snackbar(
        'Error',
        'Please enter a valid barcode',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void showErrorDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Barcode Salah",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            SizedBox(height: 20),
            Text(
              "Gambar barcode yang anda miliki salah, silahkan upload ulang barcode",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showManualInputError() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Barcode Salah",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            SizedBox(height: 20),
            Text(
              "Angka Barcode yang anda masukan salah, silahkan coba lagi",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              child: Text(
                'OK',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    animationController.dispose();
    isScanning.value = false;
    cameraController.value?.dispose();
    super.onClose();
  }
}
