import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'dart:io';
import 'dart:convert';
import '../../../services/api_service.dart';
import '../../../viewmodels/business_auth_viewmodel.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class BusinessSignUpScreen extends StatefulWidget {
  const BusinessSignUpScreen({super.key});

  @override
  State<BusinessSignUpScreen> createState() => _BusinessSignUpScreenState();
}

class _BusinessSignUpScreenState extends State<BusinessSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final BusinessAuthViewModel _authViewModel = Get.put(BusinessAuthViewModel());

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailPhoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessCategoryController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _referenceIdController = TextEditingController();

  File? _businessPhoto;
  File? _idCardFront;
  File? _idCardBack;
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _categoriesLoading = true;
  String _categoriesError = '';
  List<dynamic> _categories = [];
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await ApiService.get(
        endpoint: '/api/categories',
        requireAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _categories = data['data']['categories'] ?? [];
            _categoriesLoading = false;
          });
        } else {
          setState(() {
            _categoriesError = 'Failed to load categories';
            _categoriesLoading = false;
          });
        }
      } else {
        setState(() {
          _categoriesError = 'Server error: ${response.statusCode}';
          _categoriesLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _categoriesError = 'Network error. Try again.';
        _categoriesLoading = false;
      });
    }
  }

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailPhoneController.dispose();
    _dobController.dispose();
    _businessNameController.dispose();
    _businessCategoryController.dispose();
    _businessAddressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _occupationController.dispose();
    _referenceIdController.dispose();
    super.dispose();
  }

  // Image Picking Logic
  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (type == 'business') _businessPhoto = File(image.path);
        if (type == 'front') _idCardFront = File(image.path);
        if (type == 'back') _idCardBack = File(image.path);
      });
    }
  }

  // Date Picking Logic
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1C5941),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor, // AppColors.bgColor
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.translateValue('Sign Up'),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  AppTranslations.translateValue(
                    'It only takes a minute to create your account',
                  ),
                  style: TextStyle(fontSize: 13, color: Color(0xFF5E5E5E)),
                ),
                const SizedBox(height: 25),

                // Full Name
                _buildTextField(
                  _fullNameController,
                  'Full name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Email/Phone
                _buildTextField(
                  _emailPhoneController,
                  'E-mail address or phone number',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email or phone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date of Birth
                Text(
                  AppTranslations.translateValue('Date of birth'),
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: _buildTextField(
                      _dobController,
                      'dd/mm/yy',
                      suffixIcon: Icons.calendar_month_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select date of birth';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Business Details
                _buildLabelledField(
                  'Business name',
                  _businessNameController,
                  'Enter your business name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter business name';
                    }
                    return null;
                  },
                ),
                _buildCategoryDropdown(),
                _buildLabelledField(
                  'Business address',
                  _businessAddressController,
                  'Enter business address',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter business address';
                    }
                    return null;
                  },
                ),

                // Business Photo
                Text(
                  AppTranslations.translateValue('Business photo'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                _buildImagePickerBox(
                  'Upload',
                  _businessPhoto,
                  () => _pickImage('business'),
                  isLarge: true,
                ),
                const SizedBox(height: 20),

                // ID Information
                Text(
                  AppTranslations.translateValue('ID Information*'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  AppTranslations.translateValue(
                    'Please upload real and valid information',
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF5E5E5E),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildImagePickerBox(
                        'ID Card Front',
                        _idCardFront,
                        () => _pickImage('front'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildImagePickerBox(
                        'ID Card Back',
                        _idCardBack,
                        () => _pickImage('back'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Passwords
                _buildPasswordField(
                  _passwordController,
                  'Password',
                  _obscurePassword,
                  () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildPasswordField(
                  _confirmPasswordController,
                  'Confirm Password',
                  _obscureConfirmPassword,
                  () {
                    setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Optional Fields
                _buildLabelledField(
                  'Select occupation(Optional)',
                  _occupationController,
                  'Your profession',
                ),
                _buildLabelledField(
                  'Reference ID(Optional)',
                  _referenceIdController,
                  'Fill the number',
                  isNumber: true,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 30),

                // Sign Up Button
                Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _authViewModel.isLoading.value
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                if (_businessPhoto == null) {
                                  Get.snackbar(
                                    AppTranslations.translateValue("Required"),
                                    AppTranslations.translateValue(
                                      "Please upload a business photo",
                                    ),
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }
                                if (_idCardFront == null ||
                                    _idCardBack == null) {
                                  Get.snackbar(
                                    AppTranslations.translateValue("Required"),
                                    "Please upload both sides of your ID Card".tr,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }

                                _authViewModel.signUp(
                                  fullName: _fullNameController.text.trim(),
                                  contact: _emailPhoneController.text.trim(),
                                  businessName: _businessNameController.text.trim(),
                                  category: _businessCategoryController.text.trim(),
                                  address: _businessAddressController.text.trim(),
                                  password: _passwordController.text,
                                  dob: _dobController.text.trim(),
                                  occupation: _occupationController.text.trim(),
                                  referenceId: _referenceIdController.text.trim(),
                                  businessPhotoPath: _businessPhoto?.path,
                                  idCardFrontPath: _idCardFront?.path,
                                  idCardBackPath: _idCardBack?.path,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C5941),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _authViewModel.isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              AppTranslations.translateValue('Sign UP'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    IconData? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        fillColor: const Color(0xFFF8F9FA),
        filled: true,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBFBFBF), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1C5941)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(height: 0.1, fontSize: 10),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: const Color(0xFFBFBFBF), size: 20)
            : null,
      ),
    );
  }
  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business category',
          style: TextStyle(
            fontSize: 14,
            fontFamily: "Inter",
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _categoriesLoading
            ? const Center(child: CircularProgressIndicator())
            : _categoriesError.isNotEmpty
                ? Text(_categoriesError, style: const TextStyle(color: Colors.red))
                : DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    hint: const Text(
                      'Select category',
                      style: TextStyle(color: Color(0xFFBFBFBF), fontSize: 14),
                    ),
                    isExpanded: true,
                    decoration: InputDecoration(
                      fillColor: const Color(0xFFF8F9FA),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF1C5941)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                    items: _categories.map<DropdownMenuItem<String>>((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['_id']?.toString() ?? '',
                        child: Text(cat['name'] ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                        // Still update the old controller just in case it's read somewhere else, though we'll update the signUp call
                        _businessCategoryController.text = value ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a business category';
                      }
                      return null;
                    },
                  ),
        const SizedBox(height: 16),
      ],
    );
  }


  Widget _buildLabelledField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: "Inter",
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller,
          hint,
          keyboardType: isNumber ? TextInputType.number : keyboardType,
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String hint,
    bool obscure,
    VoidCallback toggle, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        fillColor: const Color(0xFFF8F9FA),
        filled: true,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBFBFBF), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1C5941)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(height: 0.1, fontSize: 10),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey,
            size: 20,
          ),
          onPressed: toggle,
        ),
      ),
    );
  }

  Widget _buildImagePickerBox(
    String label,
    File? image,
    VoidCallback onTap, {
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isLarge ? 130 : 110,
        width: isLarge ? 130 : double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD1D1D1),
            style: BorderStyle.solid,
          ),
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C5941),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.file(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
      ),
    );
  }
}
