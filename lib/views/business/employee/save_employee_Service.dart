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

class SaveEmployeeService extends StatefulWidget {
  final BusinessEmployeeModel? employee;
  const SaveEmployeeService({super.key, this.employee});

  @override
  State<SaveEmployeeService> createState() => _SaveEmployeeServiceState();
}

class _SaveEmployeeServiceState extends State<SaveEmployeeService> {
  final BusinessEmployeeViewModel _viewModel =
      Get.find<BusinessEmployeeViewModel>();
  final RegExp _objectIdRegex = RegExp(r'^[a-fA-F0-9]{24}$');

  // Employee Info Controllers
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Service Controllers
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _headlineController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final List<TextEditingController> _whyChooseControllers = [
    TextEditingController(text: '24/7 Service'),
    TextEditingController(text: 'Efficient & Fast.'),
    TextEditingController(text: 'Affordable Prices.'),
    TextEditingController(text: 'Expert Team.'),
  ];

  bool _makeAppointment = false;
  int _charCount = 0;
  XFile? _image;
  XFile? _profileImage;
  bool _isObjectId(String? value) =>
      value != null && _objectIdRegex.hasMatch(value.trim());

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  // Appointment fields
  final TextEditingController _availableTimeController = TextEditingController(
    text: '06:00am-09:00pm',
  );
  final List<Map<String, TextEditingController>> _durationPriceControllers = [
    {
      'duration': TextEditingController(text: '30 min'),
      'price': TextEditingController(text: '50'),
    },
    {
      'duration': TextEditingController(text: '1 hour'),
      'price': TextEditingController(text: '150'),
    },
    {
      'duration': TextEditingController(text: '1.5 hour'),
      'price': TextEditingController(text: '200'),
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      final e = widget.employee!;
      _employeeNameController.text = e.name ?? '';
      _mobileNumberController.text = e.phone ?? '';
      _emailController.text = e.email ?? '';
      _categoryController.text = e.serviceCategory ?? '';
      _headlineController.text = e.headline ?? '';
      _aboutController.text = e.about ?? '';
      _charCount = _aboutController.text.length;
      _priceController.text = e.price?.toString() ?? '';
      _availableTimeController.text = e.availableTime ?? '06:00am-09:00pm';
      _makeAppointment = e.isAppointmentBased == true;

      if (e.whyChooseUs != null && e.whyChooseUs!.isNotEmpty) {
        for (
          int i = 0;
          i < e.whyChooseUs!.length && i < _whyChooseControllers.length;
          i++
        ) {
          _whyChooseControllers[i].text = e.whyChooseUs![i];
        }
      }

      if (e.appointmentOptions != null && e.appointmentOptions!.isNotEmpty) {
        _durationPriceControllers.clear();
        for (var option in e.appointmentOptions!) {
          _durationPriceControllers.add({
            'duration': TextEditingController(text: option.duration ?? ''),
            'price': TextEditingController(
              text: option.price?.toString() ?? '',
            ),
          });
        }
      }
    }
  }

  Future<void> _submit() async {
    final bool isUpdate = widget.employee?.id != null;
    final bool hasExistingService = (widget.employee?.serviceId ?? '')
        .trim()
        .isNotEmpty;
    final String name = _employeeNameController.text.trim();
    final String mobile = _mobileNumberController.text.trim();
    final String email = _emailController.text.trim();
    final String categoryId = _categoryController.text.trim();
    final String headline = _headlineController.text.trim();
    final String about = _aboutController.text.trim();

    if (name.isEmpty || mobile.isEmpty) {
      Get.snackbar(
        AppTranslations.translateValue("Error"),
        AppTranslations.translateValue(
          "Employee Name and Mobile Number are required",
        ),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!_isObjectId(categoryId)) {
      Get.snackbar(
        AppTranslations.translateValue("Error"),
        AppTranslations.translateValue("Please enter a valid category ID"),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (headline.isEmpty || about.isEmpty) {
      Get.snackbar(
        AppTranslations.translateValue("Error"),
        AppTranslations.translateValue(
          "Service headline and description are required",
        ),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final String normalizedPrice = _priceController.text
        .replaceAll(RegExp(r'[^0-9.]'), '')
        .trim();
    final double? parsedPrice = normalizedPrice.isEmpty
        ? null
        : double.tryParse(normalizedPrice);

    // Build appointment slots if enabled
    List<Map<String, dynamic>> appointmentSlots = [];
    if (_makeAppointment) {
      for (var pair in _durationPriceControllers) {
        String duration = pair['duration']!.text.trim();
        String priceStr = pair['price']!.text
            .replaceAll(RegExp(r'[^0-9.]'), '')
            .trim();
        final double? slotPrice = double.tryParse(priceStr);
        if (duration.isNotEmpty && slotPrice != null && slotPrice > 0) {
          appointmentSlots.add({'duration': duration, 'price': slotPrice});
        }
      }

      if (appointmentSlots.isEmpty) {
        Get.snackbar(
          AppTranslations.translateValue("Error"),
          AppTranslations.translateValue(
            "Please add at least one valid appointment slot",
          ),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    } else {
      if (parsedPrice == null || parsedPrice <= 0) {
        Get.snackbar(
          AppTranslations.translateValue("Error"),
          AppTranslations.translateValue("Please enter a valid base price"),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    if (!isUpdate && (_profileImage == null || _image == null)) {
      Get.snackbar(
        AppTranslations.translateValue("Error"),
        AppTranslations.translateValue(
          "Profile photo and employee photo are required for new employees",
        ),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (isUpdate && !hasExistingService && _image == null) {
      Get.snackbar(
        AppTranslations.translateValue("Error"),
        AppTranslations.translateValue(
          "Employee photo is required when creating a new service",
        ),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Create employee model
    final employeeModel = BusinessEmployeeModel(
      name: name,
      phone: mobile,
      email: email,
      serviceCategory: categoryId,
      headline: headline,
      about: about,
      whyChooseUs: _whyChooseControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      price: _makeAppointment ? null : parsedPrice,
      isAppointmentBased: _makeAppointment,
      availableTime: _availableTimeController.text.trim(),
      appointmentOptions: _makeAppointment
          ? appointmentSlots
                .map(
                  (slot) => AppointmentOption(
                    duration: slot['duration'],
                    price: slot['price'],
                  ),
                )
                .toList()
          : null,
      serviceId: widget.employee?.serviceId,
    );

    debugPrint("🔍 Original employee serviceId: ${widget.employee?.serviceId}");
    debugPrint("🔍 New model serviceId: ${employeeModel.serviceId}");

    if (isUpdate) {
      if (hasExistingService) {
        // Existing employee + existing service => update both payload segments.
        await _viewModel.updateEmployee(
          id: widget.employee!.id!,
          employee: employeeModel,
          idCardFront: _profileImage?.path,
          idCardBack: _image?.path,
        );
      } else {
        // Existing employee + no service => create service in service table.
        await _viewModel.addServiceToEmployee(
          employeeId: widget.employee!.id!,
          employee: employeeModel,
          servicePhotoPath: _image!.path,
          profilePhotoPath: _profileImage?.path,
        );
      }
      return;
    }

    await _viewModel.createEmployee(
      employee: employeeModel,
      idCardFront: _profileImage!.path,
      idCardBack: _image!.path,
    );
  }

  @override
  void dispose() {
    _employeeNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _categoryController.dispose();
    _headlineController.dispose();
    _aboutController.dispose();
    _priceController.dispose();
    _availableTimeController.dispose();
    for (var controller in _whyChooseControllers) {
      controller.dispose();
    }
    for (var pair in _durationPriceControllers) {
      pair['duration']?.dispose();
      pair['price']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.employee != null ? "Update Employee" : "Save Employee",
        showBackButton: true,
        onBackTap: () => Get.back(),
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
                    // Profile Image Picker
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _profileImage != null
                                ? FileImage(File(_profileImage!.path))
                                : (widget.employee?.profileImage != null &&
                                      widget.employee!.profileImage!.isNotEmpty)
                                ? NetworkImage(widget.employee!.profilePicture!)
                                      as ImageProvider
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                final img = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (img != null) {
                                  setState(() => _profileImage = img);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2D6A4F),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Employee Name
                    Text(
                      AppTranslations.translateValue('Employee name'),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _employeeNameController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: AppTranslations.translateValue(
                          'Enter employee name',
                        ),
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Mobile Number
                    Text(
                      AppTranslations.translateValue('Mobile number'),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _mobileNumberController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: AppTranslations.translateValue(
                          'Enter mobile number',
                        ),
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email Address
                    Text(
                      AppTranslations.translateValue('E-mail address'),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: AppTranslations.translateValue(
                          'Enter e-mail address',
                        ),
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Upload Service Photo
                    Text(
                      AppTranslations.translateValue('Upload Service Photo'),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pickImage,
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
                          height: 134,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(_image!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : (widget.employee?.idCardBack != null &&
                                    widget.employee!.idCardBack!.isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    widget.employee!.servicePhoto!,
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
                                      style: TextStyle(
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

                    // Select Category
                    Text(
                      AppTranslations.translateValue('Category ID'),
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _categoryController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText:
                            'Enter category ID (e.g., 691a3d69bd6bcc9b83148ed6)'
                                .tr,
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      AppTranslations.translateValue('Headline'),
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _headlineController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: AppTranslations.translateValue(
                          'Enter service name',
                        ),
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // About this service
                    Text(
                      AppTranslations.translateValue('About this service'),
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        TextField(
                          controller: _aboutController,
                          maxLines: 4,
                          maxLength: 500,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: AppTranslations.translateValue(
                              'Write service details',
                            ),
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF999999),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFD0D0D0),
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF2D6A4F),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF2D6A4F),
                                width: 1.5,
                              ),
                            ),
                            counterText: '',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _charCount = value.length;
                            });
                          },
                        ),
                        Positioned(
                          bottom: 10,
                          right: 14,
                          child: Text(
                            '$_charCount/500',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Why choose us
                    Text(
                      AppTranslations.translateValue('Why choose us'),
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._whyChooseControllers.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextField(
                          controller: entry.value,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFD0D0D0),
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF2D6A4F),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF2D6A4F),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // Service pricing
                    Text(
                      AppTranslations.translateValue('Service pricing'),
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: AppTranslations.translateValue('150'),
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 14, right: 8),
                          child: Icon(
                            Icons.attach_money,
                            color: Color(0xFF999999),
                            size: 18,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D0D0),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Make an Appointment
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTranslations.translateValue('Make an Appointment'),
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: _makeAppointment,
                            onChanged: (value) {
                              setState(() {
                                _makeAppointment = value;
                              });
                            },
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.mainAppColor,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFFE0E0E0),
                          ),
                        ),
                      ],
                    ),

                    // Appointment Section - Shows when toggle is ON
                    if (_makeAppointment) ...[
                      const SizedBox(height: 20),

                      // Available time
                      Text(
                        AppTranslations.translateValue('Available time'),
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _availableTimeController,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: AppTranslations.translateValue(
                            '06:00am to 09:00pm',
                          ),
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF999999),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD0D0D0),
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD0D0D0),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF2D6A4F),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Add Duration & Price button
                      CustomPaint(
                        painter: DashedBorderPainter(
                          color: AppColors.grey,
                          strokeWidth: 1.5,
                          dashWidth: 5,
                          dashSpace: 3,
                          borderRadius: 8,
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _durationPriceControllers.add({
                                'duration': TextEditingController(),
                                'price': TextEditingController(),
                              });
                            });
                          },
                          child: Container(
                            height: 48,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppTranslations.translateValue(
                                    'Add Duration & Price',
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                    fontFamily: "Inter",
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Duration and Price pairs
                      ..._durationPriceControllers.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              // Duration field
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppTranslations.translateValue(
                                        'Duration',
                                      ),
                                      style: TextStyle(
                                        fontFamily: "Inter",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: entry.value['duration'],
                                      style: const TextStyle(fontSize: 13),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFD0D0D0),
                                            width: 1.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFD0D0D0),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF2D6A4F),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Price field
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppTranslations.translateValue('Price'),
                                      style: TextStyle(
                                        fontFamily: "Inter",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: entry.value['price'],
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: InputDecoration(
                                        prefixIcon: const Padding(
                                          padding: EdgeInsets.only(
                                            left: 14,
                                            right: 8,
                                          ),
                                          child: Icon(
                                            Icons.attach_money,
                                            color: Color(0xFF999999),
                                            size: 18,
                                          ),
                                        ),
                                        prefixIconConstraints:
                                            const BoxConstraints(
                                              minWidth: 0,
                                              minHeight: 0,
                                            ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFD0D0D0),
                                            width: 1.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFD0D0D0),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF2D6A4F),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _durationPriceControllers.removeAt(
                                      entry.key,
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    const SizedBox(height: 15),

                    // Save Service/Appointment Button
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
                                      ? 'Update Now'
                                      : 'Save Now',
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
}
