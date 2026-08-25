import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/models/business_employee_model.dart';
import 'package:middle_ware/models/user/categories/category_model.dart';
import 'package:middle_ware/services/business_employee_service.dart';
import 'package:middle_ware/widgets/CustomDashedBorder.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import 'package:middle_ware/widgets/custom_loading_button.dart';
import 'package:middle_ware/services/api_service.dart';
import 'package:middle_ware/utils/token_service.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class ProviderCreateServicePage extends StatefulWidget {
  const ProviderCreateServicePage({Key? key}) : super(key: key);

  @override
  State<ProviderCreateServicePage> createState() =>
      _ProviderCreateServicePageState();
}

class _ProviderCreateServicePageState extends State<ProviderCreateServicePage> {
  final BusinessEmployeeService _employeeService = BusinessEmployeeService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _headlineController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = false;
  bool _employeesLoading = false;
  String _employeesError = '';
  String? _selectedEmployeeId;
  List<BusinessEmployeeModel> _employees = [];

  final List<TextEditingController> _whyChooseControllers = [
    TextEditingController(text: '24/7 Service'),
    TextEditingController(text: 'Efficient & Fast.'),
    TextEditingController(text: 'Affordable Prices.'),
    TextEditingController(text: 'Expert Team.'),
  ];
  bool _makeAppointment = false;
  String? _selectedCategoryId;
  List<CategoryModel> _categories = [];
  bool _categoriesLoading = false;
  String _categoriesError = '';
  int _charCount = 0;
  XFile? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final ext = image.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      Get.snackbar(
        AppTranslations.translateValue("Invalid Format"),
        AppTranslations.translateValue(
          "Only JPG, JPEG, PNG, or WEBP files are allowed.",
        ),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _image = image;
    });
  }

  // Appointment fields
  final TextEditingController _availableTimeController = TextEditingController(
    text: '06:00am-09:00pm',
  );
  final List<Map<String, TextEditingController>> _durationPriceControllers = [
    {
      'duration': TextEditingController(text: '30 min'),
      'price': TextEditingController(text: '\$50'),
    },
    {
      'duration': TextEditingController(text: '1 hour'),
      'price': TextEditingController(text: '\$150'),
    },
    {
      'duration': TextEditingController(text: '1.5 hour'),
      'price': TextEditingController(text: '\$200'),
    },
  ];
  @override
  void dispose() {
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
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchEmployees();
  }

  BusinessEmployeeModel? _selectedEmployee() {
    if (_selectedEmployeeId == null) return null;
    for (final employee in _employees) {
      if ((employee.id ?? '').trim() == _selectedEmployeeId) {
        return employee;
      }
    }
    return null;
  }

  Future<void> _fetchEmployees() async {
    if (!mounted) return;
    setState(() {
      _employeesLoading = true;
      _employeesError = '';
    });

    try {
      final employees = await _employeeService.getAllEmployees();
      if (!mounted) return;
      setState(() {
        _employees = employees;
        if (_employees.isEmpty) {
          _employeesError = AppTranslations.translateValue(
            "No employees found",
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceAll("Exception: ", "").trim();
      setState(() {
        _employeesError = message.isEmpty
            ? AppTranslations.translateValue("Failed to load employees")
            : message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _employeesLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _categoriesLoading = true;
      _categoriesError = '';
    });

    try {
      await TokenService().init();
      final token = await TokenService().getToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse("${ApiService.BASE_URL}/api/categories"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list =
            data["data"]?["categories"] ?? data["categories"] ?? [];
        _categories = list
            .map((e) => CategoryModel.fromJson(e))
            .where((c) => c.isActive)
            .toList();
        if (_categories.isEmpty) {
          _categoriesError = "No categories found.";
        }
      } else {
        _categoriesError =
            "Failed to load categories (${response.statusCode}).";
      }
    } catch (e) {
      _categoriesError = e.toString();
    } finally {
      setState(() {
        _categoriesLoading = false;
      });
    }
  }

  int? _parseIntValue(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return null;
    final value = double.tryParse(cleaned);
    return value?.round();
  }

  Future<void> _createService() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedEmployeeId == null || _selectedEmployeeId!.isEmpty) {
      Get.snackbar(
        AppTranslations.translateValue("Error"),
        AppTranslations.translateValue("Please select an employee"),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final selectedEmployee = _selectedEmployee();
    if (selectedEmployee == null || selectedEmployee.id == null) {
      Get.snackbar(
        AppTranslations.translateValue("Error"),
        AppTranslations.translateValue(
          "Selected employee is invalid. Please reload and try again.",
        ),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedCategoryId == null || _selectedCategoryId!.trim().isEmpty) {
      Get.snackbar(
        AppTranslations.translateValue("Error"),
        AppTranslations.translateValue("Please select a category"),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_image == null) {
      Get.snackbar(
        AppTranslations.translateValue("Service Photo Required"),
        AppTranslations.translateValue("Please upload a service photo."),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final basePrice = _parseIntValue(_priceController.text.trim());
    if (!_makeAppointment && (basePrice == null || basePrice <= 0)) {
      Get.snackbar(
        AppTranslations.translateValue("Invalid Price"),
        AppTranslations.translateValue("Please enter a valid base price."),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final appointmentOptions = <AppointmentOption>[];
    if (_makeAppointment) {
      for (var i = 0; i < _durationPriceControllers.length; i++) {
        final durationText =
            _durationPriceControllers[i]['duration']?.text.trim() ?? '';
        final priceText =
            _durationPriceControllers[i]['price']?.text.trim() ?? '';

        if (durationText.isEmpty && priceText.isEmpty) {
          continue;
        }

        final priceValue = _parseIntValue(priceText);
        if (durationText.isEmpty || priceValue == null || priceValue <= 0) {
          Get.snackbar(
            AppTranslations.translateValue("Invalid Slot"),
            AppTranslations.translateValue(
              "Please enter valid duration and price for slot ${i + 1}.",
            ),
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        appointmentOptions.add(
          AppointmentOption(
            duration: durationText,
            price: priceValue.toDouble(),
          ),
        );
      }

      if (appointmentOptions.isEmpty) {
        Get.snackbar(
          AppTranslations.translateValue("Missing Slots"),
          AppTranslations.translateValue(
            "Please add at least one appointment slot.",
          ),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final model = BusinessEmployeeModel(
        id: selectedEmployee.id,
        name: selectedEmployee.name,
        phone: selectedEmployee.phone,
        email: selectedEmployee.email,
        serviceCategory: _selectedCategoryId,
        headline: _headlineController.text.trim(),
        about: _aboutController.text.trim(),
        whyChooseUs: _whyChooseControllers
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
        price: _makeAppointment ? null : basePrice?.toDouble(),
        isAppointmentBased: _makeAppointment,
        availableTime: _availableTimeController.text.trim(),
        appointmentOptions: _makeAppointment ? appointmentOptions : null,
        serviceId: selectedEmployee.serviceId,
      );

      await _employeeService.addServiceToEmployee(
        employeeId: selectedEmployee.id!,
        employee: model,
        servicePhotoPath: _image!.path,
      );

      if (!mounted) return;
      Get.snackbar(
        AppTranslations.translateValue("Success"),
        AppTranslations.translateValue("Service assigned successfully"),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back(result: true);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        AppTranslations.translateValue("Error"),
        e.toString().replaceAll("Exception: ", ""),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Create Service", showBackButton: false),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Upload Photo Section
                      Text(
                        AppTranslations.translateValue(
                          'Upload your service photo',
                        ),
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
                            color: const Color(0xFF2D6A4F), // Your theme green
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
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      if (_image != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _image!.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Select Category
                      Text(
                        AppTranslations.translateValue('Select category'),
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                          ),
                          hint: Text(
                            AppTranslations.translateValue(
                              'Select service category',
                            ),
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 13,
                              color: Color(0xFF999999),
                            ),
                          ),
                          value: _selectedCategoryId,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF2D6A4F),
                            size: 24,
                          ),
                          items: _categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(
                                    category.name,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select a category";
                            }
                            return null;
                          },
                        ),
                      ),
                      if (_categoriesLoading)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            AppTranslations.translateValue(
                              "Loading categories...",
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      if (_categoriesError.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _categoriesError,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      Text(
                        AppTranslations.translateValue('Select employee'),
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2D6A4F),
                            width: 1.5,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                          ),
                          hint: Text(
                            AppTranslations.translateValue('Select employee'),
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 13,
                              color: Color(0xFF999999),
                            ),
                          ),
                          value:
                              _selectedEmployeeId != null &&
                                  _employees.any(
                                    (e) =>
                                        (e.id ?? '').trim() ==
                                        _selectedEmployeeId,
                                  )
                              ? _selectedEmployeeId
                              : null,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF2D6A4F),
                            size: 24,
                          ),
                          items: _employees
                              .where((e) => (e.id ?? '').trim().isNotEmpty)
                              .map((employee) {
                                final id = (employee.id ?? '').trim();
                                final name = (employee.name ?? '').trim();
                                final phone = (employee.phone ?? '').trim();
                                final label = name.isNotEmpty
                                    ? name
                                    : (phone.isNotEmpty ? phone : id);
                                return DropdownMenuItem<String>(
                                  value: id,
                                  child: Text(
                                    label,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              })
                              .toList(),
                          onChanged: _employeesLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedEmployeeId = value;
                                  });
                                },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please select an employee";
                            }
                            return null;
                          },
                        ),
                      ),
                      if (_employeesLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            AppTranslations.translateValue(
                              "Loading employees...",
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      if (_employeesError.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _employeesError,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _employeesLoading
                                    ? null
                                    : _fetchEmployees,
                                child: Text(
                                  AppTranslations.translateValue("Retry"),
                                ),
                              ),
                            ],
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
                      TextFormField(
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a headline";
                          }
                          return null;
                        },
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
                          TextFormField(
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please add a description";
                              }
                              return null;
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
                      }).toList(),
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
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: AppTranslations.translateValue('\$150'),
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
                        validator: (value) {
                          if (_makeAppointment) {
                            return null;
                          }
                          final parsed = _parseIntValue(value ?? '');
                          if (parsed == null || parsed <= 0) {
                            return "Please enter a valid price";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Make an Appointment
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppTranslations.translateValue(
                              'Make an Appointment',
                            ),
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
                              activeColor: Colors.white,
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
                          child: Container(
                            // Increased height from 12 to a functional size (e.g., 48)
                            height: 48,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize:
                                  MainAxisSize.min, // Adjusts width to content
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
                        const SizedBox(height: 20),

                        // Duration and Price pairs
                        ..._durationPriceControllers.asMap().entries.map((
                          entry,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                // Duration field
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              ],
                            ),
                          );
                        }).toList(),
                      ],

                      const SizedBox(height: 15),

                      // Create Service/Appointment Button
                      CustomLoadingButton(
                        title: _makeAppointment
                            ? 'Create Appointment'
                            : 'Create Service',
                        isLoading: _isLoading,
                        onTap: _createService,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
