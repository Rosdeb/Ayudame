import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import '../../../../controller/provider/portfolio_controller.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class AddPortfolioScreen extends StatefulWidget {
  const AddPortfolioScreen({super.key});

  @override
  State<AddPortfolioScreen> createState() => _AddPortfolioScreenState();
}

class _AddPortfolioScreenState extends State<AddPortfolioScreen> {
  final PortfolioController controller = Get.find<PortfolioController>();

  final Rx<File?> beforeImage = Rx<File?>(null);
  final Rx<File?> afterImage = Rx<File?>(null);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final RxInt currentLength = 0.obs;

  final int maxLength = 1000;

  @override
  void initState() {
    super.initState();
    _aboutController.addListener(() {
      currentLength.value = _aboutController.text.length;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _serviceTypeController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isBefore) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (isBefore) {
        beforeImage.value = File(image.path);
      } else {
        afterImage.value = File(image.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryGreen = const Color(0xFF2C5F4F);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.translateValue("Add Portfolio"),
      ),
      body: Obx(() {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      AppTranslations.translateValue("Title"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: AppTranslations.translateValue(
                          "Hair Transformation",
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Service Type
                    Text(
                      AppTranslations.translateValue("Service Type"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _serviceTypeController,
                      decoration: InputDecoration(
                        hintText: AppTranslations.translateValue(
                          "Hair Styling",
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Images
                    Row(
                      children: [
                        _buildUploadBox("Before work", beforeImage.value, true),
                        const SizedBox(width: 6),
                        _buildUploadBox("After work", afterImage.value, false),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // About
                    Text(
                      AppTranslations.translateValue("About"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _aboutController,
                      maxLines: 6,
                      maxLength: maxLength,
                      decoration: InputDecoration(
                        hintText: AppTranslations.translateValue(
                          "Describe your portfolio work...",
                        ),
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: primaryGreen,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        counterText: '',
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${currentLength.value}/$maxLength",
                        style: TextStyle(
                          fontSize: 12,
                          color: currentLength.value > maxLength
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () async {
                                if (beforeImage.value != null &&
                                    afterImage.value != null &&
                                    _titleController.text.isNotEmpty &&
                                    _serviceTypeController.text.isNotEmpty &&
                                    _aboutController.text.isNotEmpty) {
                                  bool success = await controller.addPortfolio(
                                    title: _titleController.text,
                                    serviceType: _serviceTypeController.text,
                                    about: _aboutController.text,
                                    beforeImage: beforeImage.value!,
                                    afterImage: afterImage.value!,
                                  );

                                  if (success) {
                                    Get.back();
                                  }
                                } else {
                                  Get.snackbar(
                                    AppTranslations.translateValue("Error"),
                                    AppTranslations.translateValue(
                                      "Please complete all fields",
                                    ),
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                AppTranslations.translateValue("Publish"),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildUploadBox(String label, File? imageFile, bool isBefore) {
    return Expanded(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _pickImage(isBefore),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(imageFile, fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Color(0xFF2C5F4F),
                        size: 32,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
