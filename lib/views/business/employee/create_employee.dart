import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/widgets/CustomDashedBorder.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import '../../../../models/business_employee_model.dart';
import '../../../../viewmodels/business_employee_viewmodel.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class CreateEmployee extends StatefulWidget {
  final BusinessEmployeeModel? employee;
  const CreateEmployee({super.key, this.employee});

  @override
  State<CreateEmployee> createState() => _CreateEmployeeState();
}

class _CreateEmployeeState extends State<CreateEmployee> {
  final BusinessEmployeeViewModel _viewModel = Get.put(
    BusinessEmployeeViewModel(),
  );

  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  XFile? _employeePhoto;

  String t(String keyOrText) => AppTranslations.translateValue(keyOrText);

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      final e = widget.employee!;
      _employeeNameController.text = e.name ?? '';
      _mobileNumberController.text = e.phone ?? '';
      _emailController.text = e.email ?? '';
    }
  }

  Future<void> _pickEmployeePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _employeePhoto = image;
      });
    }
  }

  Future<void> _submit() async {
    final bool isUpdate = widget.employee?.id != null;
    final String name = _employeeNameController.text.trim();
    final String mobile = _mobileNumberController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (name.isEmpty || mobile.isEmpty || email.isEmpty) {
      Get.snackbar(
        t('common.error'),
        t('Employee name, mobile number and email are required'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!isUpdate && (password.isEmpty || password.length < 6)) {
      Get.snackbar(
        t('common.error'),
        t('Password must be at least 6 characters'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final employeeModel = BusinessEmployeeModel(
      name: name,
      phone: mobile,
      email: email,
    );

    if (isUpdate) {
      await _viewModel.updateEmployee(
        id: widget.employee!.id!,
        employee: employeeModel,
        idCardFront: _employeePhoto?.path,
      );
      return;
    }

    await _viewModel.createEmployeeOnly(
      employee: employeeModel,
      password: password,
      profilePhotoPath: _employeePhoto?.path,
    );
  }

  @override
  void dispose() {
    _employeeNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.employee != null
            ? t('Update Employee')
            : t('Create Employee'),
      ),
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.translateValue('Upload Employee photo'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pickEmployeePhoto,
                      child: CustomPaint(
                        painter: DashedBorderPainter(
                          color: const Color(0xFF2D6A4F),
                          strokeWidth: 1.5,
                          dashWidth: 6,
                          dashSpace: 4,
                          borderRadius: 8,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _employeePhoto != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(_employeePhoto!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : (widget.employee?.profilePicture != null &&
                                    widget.employee!.profilePicture!.isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    widget.employee!.profilePicture!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2D6A4F),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      AppTranslations.translateValue(
                                        'Click to upload',
                                      ),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    _buildLabel('Employee name'),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _employeeNameController,
                      style: const TextStyle(fontSize: 13),
                      decoration: _inputDecoration('Enter employee name'),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Mobile number'),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _mobileNumberController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 13),
                      decoration: _inputDecoration('Enter mobile number'),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('E-mail address'),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 13),
                      decoration: _inputDecoration('Enter e-mail address'),
                    ),
                    if (widget.employee == null) ...[
                      const SizedBox(height: 20),
                      _buildLabel('Password'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDecoration('Enter password'),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _viewModel.isLoading.value
                              ? null
                              : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D6A4F),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _viewModel.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  widget.employee != null
                                      ? t('Update Now')
                                      : t('Create Now'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      AppTranslations.translateValue(text),
      style: const TextStyle(
        fontSize: 14,
        fontFamily: "Inter",
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: AppTranslations.translateValue(hint),
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2D6A4F), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2D6A4F), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2D6A4F), width: 1.5),
      ),
    );
  }
}
