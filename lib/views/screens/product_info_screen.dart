import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../controllers/barcode_controller.dart';

class ProductInfoScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  final BarcodeController controller = Get.find();

  ProductInfoScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed('/');
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Obx(() {
                      final product = controller.currentProduct.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width - 40,
                              height: 250,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.08),
                                    offset: Offset(0, 4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: product != null
                                    ? product.image != null
                                        ? Image.network(
                                            product.image!,
                                            width: 200,
                                            height: 200,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/img/13434972.png',
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.contain,
                                              );
                                            },
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            'assets/img/13434972.png',
                                            width: 200,
                                            height: 200,
                                            fit: BoxFit.contain,
                                          )
                                    : Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 80,
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          if (product != null) ...[
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RedHatText',
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              product.price,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Description',
                              style: TextStyle(
                                color: Colors.grey.withOpacity(0.7),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              product.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ] else
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 20),
                                  Text(
                                    'Barcode yang anda scan tidak ditemukan, pastikan kondisi barcode bersih dan tidak rusak ataupun tercoret',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.red,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
                SizedBox(height: 20),
                // Scan Again Button
                ElevatedButton(
                  onPressed: () {
                    controller.resetScanner();
                    Get.offNamed('/scanner');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Color.fromARGB(255, 226, 226, 226),
                    padding:
                        EdgeInsets.symmetric(vertical: 14, horizontal: 24.0),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code, color: Colors.black),
                      SizedBox(width: 10),
                      Text('Scan Barcode Lagi'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
