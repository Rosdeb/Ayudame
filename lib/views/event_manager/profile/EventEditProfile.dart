import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/viewmodels/event_manager_viewmodel.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import '../../../widgets/custom_text_field.dart';

class EventEditProfileScreen extends StatefulWidget {
  const EventEditProfileScreen({super.key});

  @override
  State<EventEditProfileScreen> createState() => _EventEditProfileScreenState();
}

class _EventEditProfileScreenState extends State<EventEditProfileScreen> {
  final _viewModel = Get.find<EventManagerViewModel>();
  String t(String value) => AppTranslations.translateValue(value);

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _categoryController = TextEditingController();
  final _currentPassController = TextEditingController();
  final _idNumberController = TextEditingController();
  String? _selectedIdType;
  final _formKey = GlobalKey<FormState>();

  bool _isObscurePass = true;
  bool _isObscureConfirm = true;
  bool _isObscureCurrent = true;

  File? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _categoryController.dispose();
    _currentPassController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    final manager = _viewModel.currentManager.value;
    if (manager != null) {
      _nameController.text = manager.fullName ?? '';
      _emailController.text = manager.email ?? '';
      _phoneController.text = manager.phoneNumber ?? '';
      _dobController.text = manager.dateOfBirth ?? '';
      _categoryController.text = manager.category ?? '';
      _addressController.text = manager.address ?? '';
      _idNumberController.text = manager.identificationNumber ?? '';
      _selectedIdType = manager.idType?.toLowerCase();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Using gallery as default
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppBar(title: t("profile.edit_profile"), showBackButton: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          child: Column(
            children: [
              // Profile Picture Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (_viewModel
                                              .currentManager
                                              .value
                                              ?.profilePicture !=
                                          null &&
                                      _viewModel
                                          .currentManager
                                          .value!
                                          .profilePicture!
                                          .isNotEmpty
                                  ? NetworkImage(
                                          _viewModel
                                              .currentManager
                                              .value!
                                              .profilePicture!,
                                        )
                                        as ImageProvider
                                  : const AssetImage(
                                      'assets/images/profile.png',
                                    )),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 30.h,
                          width: 30.w,
                          decoration: const BoxDecoration(
                            color: AppColors.mainAppColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30.h),

              // ১. Full Name Field
              CustomTextField(
                controller: _nameController,
                hintText: t('auth.full_name'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? t('common.required')
                        : null,
              ),
              SizedBox(height: 16.h),

              // ২. E-mail address Field
              CustomTextField(
                controller: _emailController,
                hintText: t('auth.email_address_or_phone'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t('common.required');
                  }
                  if (!GetUtils.isEmail(value)) return t('validation.invalid_email');
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Current Password (Required for password changes)
              CustomTextField(
                controller: _currentPassController,
                hintText: t('Current Password'),
                isPassword: _isObscureCurrent,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscureCurrent
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade400,
                    size: 20.sp,
                  ),
                  onPressed: () =>
                      setState(() => _isObscureCurrent = !_isObscureCurrent),
                ),
              ),
              SizedBox(height: 16.h),

              // ৩. New Password Field
              CustomTextField(
                controller: _passController,
                hintText: t('auth.new_password'),
                isPassword: _isObscurePass,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscurePass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade400,
                    size: 20.sp,
                  ),
                  onPressed: () =>
                      setState(() => _isObscurePass = !_isObscurePass),
                ),
              ),
              SizedBox(height: 16.h),

              // ৪. Confirm Password Field
              CustomTextField(
                controller: _confirmPassController,
                hintText: t('auth.confirm_password'),
                isPassword: _isObscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade400,
                    size: 20.sp,
                  ),
                  onPressed: () =>
                      setState(() => _isObscureConfirm = !_isObscureConfirm),
                ),
                validator: (value) {
                  if (_passController.text.isNotEmpty &&
                      value != _passController.text) {
                    return t('validation.passwords_dont_match');
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              CustomTextField(
                controller: _phoneController,
                hintText: t('common.phone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t('common.required');
                  }
                  if (value.trim().length < 10) return t('validation.invalid_phone');
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // ID Type Field
              _buildDropdownField(),
              SizedBox(height: 16.h),

              // Identification Number Field
              CustomTextField(
                controller: _idNumberController,
                hintText: t('event_auth.identification_number'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? t('common.required')
                        : null,
              ),
              SizedBox(height: 16.h),

              // ৬. Date of Birth Field (With Calendar Icon)
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: _dobController,
                    hintText: t('event_auth.date_hint'),
                    readOnly: true,
                    suffixIcon: Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.grey.shade400,
                      size: 22.sp,
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty)
                            ? t('common.required')
                            : null,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // ৭. Category Field
              CustomTextField(
                controller: _categoryController,
                hintText: t('Category'),
              ),
              SizedBox(height: 16.h),

              // ৮. Business Address Field
              CustomTextField(
                controller: _addressController,
                hintText: t('Business Address'),
              ),
              SizedBox(height: 40.h),

              // ৯. Save Button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: Obx(
        () => ElevatedButton(
          onPressed: _viewModel.isLoading.value ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B4D3E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
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
                  t('Save Changes'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // If new password is provided, current password must be provided
      if (_passController.text.isNotEmpty &&
          _currentPassController.text.isEmpty) {
        Get.snackbar(
          t("common.error"),
          t("Current password is required to set a new password"),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      _viewModel.updateProfile(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        dateOfBirth: _dobController.text,
        birthdate: _dobController.text,
        currentPassword: _currentPassController.text.isNotEmpty
            ? _currentPassController.text
            : null,
        newPassword: _passController.text.isNotEmpty
            ? _passController.text
            : null,
        confirmPassword: _confirmPassController.text.isNotEmpty
            ? _confirmPassController.text
            : null,
        newConfirmPassword: _confirmPassController.text.isNotEmpty
            ? _confirmPassController.text
            : null,
        category: _categoryController.text.isNotEmpty
            ? _categoryController.text
            : null,
        address: _addressController.text.isNotEmpty
            ? _addressController.text
            : null,
        businessAddress: _addressController.text.isNotEmpty
            ? _addressController.text
            : null,
        idType: _selectedIdType,
        identificationNumber: _idNumberController.text.trim(),
        profilePicturePath: _selectedImage?.path,
      );

      // Note: ViewModel handles navigation back on success
    }
  }

  Widget _buildDropdownField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFD8D8D8)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          initialValue: _selectedIdType,
          hint: Text(
            t("event_auth.select_id_type_hint"),
            style: TextStyle(
              color: const Color(0xFF737373),
              fontFamily: "Inter",
              fontSize: 14.sp,
            ),
          ),
          decoration: const InputDecoration(border: InputBorder.none),
          validator: (value) =>
              (value == null || value.isEmpty) ? t('common.required') : null,
          items: [
            DropdownMenuItem<String>(
              value: "nid",
              child: Text(t("event_auth.id_type_nid")),
            ),
            DropdownMenuItem<String>(
              value: "passport",
              child: Text(t("event_auth.id_type_passport")),
            ),
            DropdownMenuItem<String>(
              value: "driving license",
              child: Text(t("event_auth.id_type_driving_license")),
            ),
          ],
          onChanged: (newValue) => setState(() => _selectedIdType = newValue),
        ),
      ),
    );
  }
}
