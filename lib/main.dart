import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/scanner_screen.dart';
import 'views/screens/product_info_screen.dart';
import 'views/screens/manual_input_screen.dart';
import 'controllers/barcode_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "config.env");

  final cameras = await availableCameras();

  Get.put(AnimationControllerProvider());
  Get.put(BarcodeController(cameras));

  runApp(MyApp(cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp(this.cameras, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barcode Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => HomeScreen(cameras: cameras),
        ),
        GetPage(
          name: '/scanner',
          page: () => ScannerScreen(cameras: cameras),
        ),
        GetPage(
          name: '/product-info',
          page: () => ProductInfoScreen(cameras: cameras),
        ),
        GetPage(
          name: '/manual-input',
          page: () => ManualInputScreen(cameras: cameras),
        ),
      ],
    );
  }
}
