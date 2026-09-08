import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

import '../models/business_employee_model.dart';
import 'api_service.dart';

class BusinessEmployeeService {
  final RegExp _objectIdRegex = RegExp(r'^[a-fA-F0-9]{24}$');

  bool _isObjectId(String? value) {
    if (value == null) return false;
    return _objectIdRegex.hasMatch(value.trim());
  }

  String _trim(String? value) => value?.trim() ?? '';

  List<Map<String, dynamic>> _buildAppointmentSlots(
    List<AppointmentOption>? options,
  ) {
    if (options == null || options.isEmpty) return <Map<String, dynamic>>[];

    return options.map((slot) {
      return {
        'duration':
            int.tryParse(
              slot.duration?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0',
            ) ??
            0,
        'durationUnit': 'minutes',
        'price': slot.price ?? 0,
      };
    }).toList();
  }

  Map<String, String> _buildWhyChooseMap(List<String>? whyChooseUs) {
    final Map<String, String> reasons = <String, String>{};
    if (whyChooseUs == null || whyChooseUs.isEmpty) return reasons;

    for (int i = 0; i < whyChooseUs.length; i++) {
      final String reason = whyChooseUs[i].trim();
      if (reason.isNotEmpty) {
        reasons['reason${i + 1}'] = reason;
      }
    }
    return reasons;
  }

  /// Create Employee
  Future<BusinessEmployeeModel> createEmployee({
    required BusinessEmployeeModel employee,
    String? idCardFront,
    String? idCardBack,
  }) async {
    try {
      final String categoryId = _trim(employee.serviceCategory);
      if (!_isObjectId(categoryId)) {
        throw Exception('Please select a valid category');
      }

      final bool appointmentEnabled = employee.isAppointmentBased == true;
      final fields = <String, String>{
        'fullName': _trim(employee.name),
        'mobileNumber': _trim(employee.phone),
        'email': _trim(employee.email),
        'headline': _trim(employee.headline),
        'description': _trim(employee.about),
        'appointmentEnabled': appointmentEnabled.toString(),
        'category': categoryId,
        'categories': jsonEncode(<String>[categoryId]),
      };
      final String availableTime = _trim(employee.availableTime);
      if (availableTime.isNotEmpty) {
        fields['availableTime'] = availableTime;
      }

      final Map<String, String> reasons = _buildWhyChooseMap(
        employee.whyChooseUs,
      );
      if (reasons.isNotEmpty) {
        fields['whyChooseUs'] = jsonEncode(reasons);
        fields['whyChooseService'] = jsonEncode(reasons);
      }

      if (appointmentEnabled) {
        final List<Map<String, dynamic>> slots = _buildAppointmentSlots(
          employee.appointmentOptions,
        );
        if (slots.isNotEmpty) {
          fields['appointmentSlots'] = jsonEncode(slots);
        }
      } else if (employee.price != null) {
        fields['basePrice'] = employee.price.toString();
      }

      final files = <String, dynamic>{};
      // Backend expects both profilePhoto and servicePhoto
      if (idCardFront != null && idCardFront.isNotEmpty) {
        files['profilePhoto'] = idCardFront;
      }
      if (idCardBack != null && idCardBack.isNotEmpty) {
        files['servicePhoto'] = idCardBack;
      }

      // 🔍 DEBUG: Print what we're sending
      debugPrint("📤 Creating Employee - Fields: $fields");
      debugPrint("📤 Creating Employee - Files: ${files.keys.toList()}");

      final streamedResponse = await ApiService.postMultipart(
        endpoint: '/api/business-owners/employees',
        fields: fields,
        files: files,
        requireAuth: true,
      );

      final responseBody = await streamedResponse.stream.bytesToString();
      final statusCode = streamedResponse.statusCode;

      // 🔍 DEBUG: Print response
      debugPrint("📥 Response Status: $statusCode");
      debugPrint("📥 Response Body: $responseBody");

      if (statusCode == 200 || statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          debugPrint("✅ Employee Created Successfully");

          final data = jsonResponse['data'];
          final employeeData = data['employee'] as Map<String, dynamic>?;

          if (employeeData != null) {
            debugPrint("👤 Employee Data Keys: ${employeeData.keys.toList()}");
            debugPrint("📸 ProfilePhoto: ${employeeData['profilePhoto']}");

            // Check for service (singular) or services (plural list)
            Map<String, dynamic>? serviceData;
            if (data['service'] != null) {
              serviceData = data['service'] as Map<String, dynamic>;
              debugPrint("🔧 Found 'service' (singular)");
            } else if (data['services'] != null &&
                (data['services'] as List).isNotEmpty) {
              serviceData = data['services'][0] as Map<String, dynamic>;
              debugPrint("🔧 Found 'services' (plural) - using first item");
              debugPrint("🔧 Service Data Keys: ${serviceData.keys.toList()}");
              debugPrint("📸 ServicePhoto: ${serviceData['servicePhoto']}");
              debugPrint("📝 Headline: ${serviceData['headline']}");
              debugPrint("📝 Description: ${serviceData['description']}");
              debugPrint("💰 BasePrice: ${serviceData['basePrice']}");
              debugPrint(
                "📅 AppointmentSlots: ${serviceData['appointmentSlots']}",
              );
            }

            final model = BusinessEmployeeModel.fromJsonWithService(
              employeeData: employeeData,
              serviceData: serviceData,
            );

            debugPrint(
              "🎯 Final Model - ProfilePicture: ${model.profilePicture}",
            );
            debugPrint("🎯 Final Model - ServicePhoto: ${model.servicePhoto}");
            debugPrint("🎯 Final Model - Headline: ${model.headline}");
            debugPrint("🎯 Final Model - About: ${model.about}");
            debugPrint("🎯 Final Model - Price: ${model.price}");
            debugPrint(
              "🎯 Final Model - AppointmentOptions: ${model.appointmentOptions?.length}",
            );

            return model;
          }
        }
        return BusinessEmployeeModel.fromJson(jsonResponse); // Fallback
      } else {
        final errorResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        throw Exception(
          errorResponse['message'] ?? 'Failed to create employee',
        );
      }
    } catch (e) {
      debugPrint("❌ Create Employee Error: $e");
      rethrow;
    }
  }

  /// Create Employee only (without creating service/appointment)
  Future<BusinessEmployeeModel> createEmployeeOnly({
    required BusinessEmployeeModel employee,
    required String password,
    String? profilePhotoPath,
  }) async {
    try {
      final fields = <String, String>{
        'fullName': _trim(employee.name),
        'mobileNumber': _trim(employee.phone),
        'email': _trim(employee.email),
        'password': password,
      };

      final files = <String, dynamic>{};
      if (profilePhotoPath != null && profilePhotoPath.isNotEmpty) {
        files['profilePhoto'] = profilePhotoPath;
      }

      final streamedResponse = await ApiService.postMultipart(
        endpoint: '/api/business-owners/employees/basic',
        fields: fields,
        files: files,
        requireAuth: true,
      );

      final responseBody = await streamedResponse.stream.bytesToString();
      final statusCode = streamedResponse.statusCode;

      if (statusCode == 200 || statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final dynamic data = jsonResponse['data'];
          if (data is Map<String, dynamic> && data['employee'] != null) {
            return BusinessEmployeeModel.fromJson(data['employee']);
          }
          if (data is Map<String, dynamic>) {
            return BusinessEmployeeModel.fromJson(data);
          }
        }
        return BusinessEmployeeModel.fromJson(jsonResponse);
      }

      final errorResponse = jsonDecode(responseBody) as Map<String, dynamic>;
      throw Exception(errorResponse['message'] ?? 'Failed to create employee');
    } catch (e) {
      debugPrint('Create Employee Only Error: $e');
      rethrow;
    }
  }

  /// Add a new service for an existing employee
  Future<BusinessEmployeeModel> addServiceToEmployee({
    required String employeeId,
    required BusinessEmployeeModel employee,
    required String servicePhotoPath,
  }) async {
    try {
      final String categoryId = _trim(employee.serviceCategory);
      if (!_isObjectId(categoryId)) {
        throw Exception('Please select a valid category');
      }

      final bool appointmentEnabled = employee.isAppointmentBased == true;
      final fields = <String, String>{
        'employeeId': employeeId,
        'headline': _trim(employee.headline),
        'description': _trim(employee.about),
        'appointmentEnabled': appointmentEnabled.toString(),
        // New service-table API usually accepts a single category.
        'category': categoryId,
        // Keep compatibility with older payload contracts.
        'categories': jsonEncode(<String>[categoryId]),
      };
      final String availableTime = _trim(employee.availableTime);
      if (availableTime.isNotEmpty) {
        fields['availableTime'] = availableTime;
      }

      final Map<String, String> reasons = _buildWhyChooseMap(
        employee.whyChooseUs,
      );
      if (reasons.isNotEmpty) {
        // Service-table APIs may use whyChooseUs map
        fields['whyChooseUs'] = jsonEncode(reasons);
        // Keep compatibility with existing field name
        fields['whyChooseService'] = jsonEncode(reasons);
      }

      if (appointmentEnabled) {
        final List<Map<String, dynamic>> slots = _buildAppointmentSlots(
          employee.appointmentOptions,
        );
        if (slots.isNotEmpty) {
          fields['appointmentSlots'] = jsonEncode(slots);
        }
      } else if (employee.price != null) {
        fields['basePrice'] = employee.price.toString();
      }

      final files = <String, dynamic>{'servicePhoto': servicePhotoPath};
      
      final role = await StorageService.getUserRole();
      String endpoint = '/api/services'; // fallback
      
      if (role == 'business') {
        endpoint = '/api/business-owners/services';
      } else if (role == 'provider') {
        endpoint = '/api/providers/services';
      }

      final streamedResponse = await ApiService.postMultipart(
        endpoint: endpoint,
        fields: fields,
        files: files,
        requireAuth: true,
      );

      final responseBody = await streamedResponse.stream.bytesToString();
      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        return await getEmployeeDetail(employeeId);
      }

      try {
        final errorResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        throw Exception(errorResponse['message'] ?? 'Failed to add service');
      } catch (e) {
        if (e.toString().contains('Exception:')) rethrow;
        throw Exception('Failed to add service. Status: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Add Service To Employee Error: $e');
      rethrow;
    }
  }

  /// Get All Employees
  Future<List<BusinessEmployeeModel>> getAllEmployees() async {
    try {
      final response = await ApiService.get(
        endpoint: '/api/business-owners/employees',
        requireAuth: true,
      );

      debugPrint("📥 Get All Employees Status: ${response.statusCode}");
      debugPrint("📥 Get All Employees Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        debugPrint("📋 Total Employees: ${data.length}");

        if (data.isEmpty) return [];

        debugPrint("📋 First Item Keys: ${(data[0] as Map).keys.toList()}");
        debugPrint("📋 First Employee Full Data: ${jsonEncode(data[0])}");

        // Check if data contains employee and services separately
        if (data[0]['employee'] != null) {
          debugPrint(
            "✅ Response has separate 'employee' and 'services' fields",
          );
          // Response format: [{ employee: {...}, services: [...] }]
          return data.map((item) {
            final employeeData = item['employee'] as Map<String, dynamic>;
            final services = item['services'] as List?;

            final serviceData = (services != null && services.isNotEmpty)
                ? services[0] as Map<String, dynamic>
                : null;

            return BusinessEmployeeModel.fromJsonWithService(
              employeeData: employeeData,
              serviceData: serviceData,
            );
          }).toList();
        } else {
          debugPrint(
            "ℹ️ Response has direct employee objects (no separate services)",
          );

          // Check if the first employee has service details
          final firstEmployee = data[0] as Map<String, dynamic>;
          final hasServiceData =
              firstEmployee['profilePhoto'] != null ||
              firstEmployee['headline'] != null ||
              firstEmployee['servicePhoto'] != null;

          if (!hasServiceData && firstEmployee['_id'] != null) {
            debugPrint(
              "⚠️ List response missing service data - fetching full details for each employee",
            );

            // Fetch full details for each employee
            List<BusinessEmployeeModel> employees = [];
            for (var item in data) {
              try {
                final employeeId = item['_id'] ?? item['id'];
                if (employeeId != null) {
                  debugPrint("🔄 Fetching details for employee: $employeeId");
                  final fullEmployee = await getEmployeeDetail(employeeId);
                  employees.add(fullEmployee);
                }
              } catch (e) {
                debugPrint("❌ Failed to fetch employee detail: $e");
                // Fallback to basic data
                employees.add(BusinessEmployeeModel.fromJson(item));
              }
            }
            return employees;
          }
        }

        // Standard format: direct employee objects with all data
        return data.map((e) => BusinessEmployeeModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Get All Employees Error: $e");
      rethrow;
    }
  }

  /// Get Employee Detail
  Future<BusinessEmployeeModel> getEmployeeDetail(String id) async {
    try {
      final response = await ApiService.get(
        endpoint: '/api/business-owners/employees/$id',
        requireAuth: true,
      );

      debugPrint("📥 Get Employee Detail Status: ${response.statusCode}");
      debugPrint("📥 Get Employee Detail Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        debugPrint(
          "📋 Employee Detail Data Keys: ${jsonResponse['data']?.keys.toList()}",
        );

        final data = jsonResponse['data'];

        // Check if response has nested employee and services structure
        if (data['employee'] != null) {
          debugPrint(
            "✅ Detail response has 'employee' and 'services' structure",
          );
          final employeeData = data['employee'] as Map<String, dynamic>;
          final services = data['services'] as List?;

          debugPrint("👤 Employee: ${employeeData['fullName']}");
          debugPrint("📸 ProfilePhoto: ${employeeData['profilePhoto']}");

          Map<String, dynamic>? serviceData;
          if (services != null && services.isNotEmpty) {
            serviceData = services[0] as Map<String, dynamic>;
            debugPrint("🔧 Service Data Found");
            debugPrint("📸 ServicePhoto: ${serviceData['servicePhoto']}");
            debugPrint("📝 Headline: ${serviceData['headline']}");
            debugPrint("📝 Description: ${serviceData['description']}");
            debugPrint("💰 BasePrice: ${serviceData['basePrice']}");
          }

          final model = BusinessEmployeeModel.fromJsonWithService(
            employeeData: employeeData,
            serviceData: serviceData,
          );

          debugPrint(
            "🎯 Detail Model - ProfilePicture: ${model.profilePicture}",
          );
          debugPrint("🎯 Detail Model - ServicePhoto: ${model.servicePhoto}");
          debugPrint("🎯 Detail Model - Headline: ${model.headline}");
          debugPrint("🎯 Detail Model - About: ${model.about}");

          return model;
        }

        // Fallback to direct parsing
        return BusinessEmployeeModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to load employee details');
      }
    } catch (e) {
      debugPrint("❌ Get Employee Detail Error: $e");
      rethrow;
    }
  }

  /// Update Employee
  Future<BusinessEmployeeModel> updateEmployee({
    required String id,
    required BusinessEmployeeModel employee,
    String? idCardFront,
    String? idCardBack,
  }) async {
    try {
      // Check if we need to use Multipart (if images are provided)
      if ((idCardFront != null && idCardFront.isNotEmpty) ||
          (idCardBack != null && idCardBack.isNotEmpty)) {
        final bool hasServiceId =
            employee.serviceId != null && employee.serviceId!.trim().isNotEmpty;
        final bool appointmentEnabled = employee.isAppointmentBased == true;
        final String headline = _trim(employee.headline);
        final String description = _trim(employee.about);
        final String categoryId = _trim(employee.serviceCategory);

        final fields = <String, String>{
          'fullName': _trim(employee.name),
          'mobileNumber': _trim(employee.phone),
          'email': _trim(employee.email),
          '_method': 'PUT', // Method override for backends that need it
        };

        // Add employeeServiceId if available
        debugPrint("Employee serviceId: ${employee.serviceId}");
        if (hasServiceId) {
          fields['employeeServiceId'] = employee.serviceId!.trim();
          debugPrint("Added employeeServiceId to fields");
        } else {
          debugPrint("serviceId is null - cannot add employeeServiceId");
        }

        if (hasServiceId) {
          if (headline.isNotEmpty) {
            fields['headline'] = headline;
          }
          if (description.isNotEmpty) {
            fields['description'] = description;
          }
          fields['appointmentEnabled'] = appointmentEnabled.toString();
          final String availableTime = _trim(employee.availableTime);
          if (availableTime.isNotEmpty) {
            fields['availableTime'] = availableTime;
          }

          if (_isObjectId(categoryId)) {
            fields['category'] = categoryId;
            fields['categories'] = jsonEncode(<String>[categoryId]);
          }

          final Map<String, String> reasons = _buildWhyChooseMap(
            employee.whyChooseUs,
          );
          if (reasons.isNotEmpty) {
            fields['whyChooseUs'] = jsonEncode(reasons);
            fields['whyChooseService'] = jsonEncode(reasons);
          }

          if (appointmentEnabled) {
            final List<Map<String, dynamic>> slots = _buildAppointmentSlots(
              employee.appointmentOptions,
            );
            if (slots.isNotEmpty) {
              fields['appointmentSlots'] = jsonEncode(slots);
            }
          } else if (employee.price != null) {
            fields['basePrice'] = employee.price.toString();
          }
        }

        final files = <String, dynamic>{};
        // Backend expects both profilePhoto and servicePhoto
        if (idCardFront != null && idCardFront.isNotEmpty) {
          files['profilePhoto'] = idCardFront;
        }
        if (hasServiceId && idCardBack != null && idCardBack.isNotEmpty) {
          files['servicePhoto'] = idCardBack;
        }

        debugPrint("📤 Updating Employee - Fields: $fields");
        debugPrint("📤 Updating Employee - Files: ${files.keys.toList()}");

        // Use direct PUT for multipart updates (matching the pattern that works for profile)
        final streamedResponse = await ApiService.postMultipart(
          endpoint: '/api/business-owners/employees/$id?_method=PUT',
          fields: fields,
          files: files,
          requireAuth: true,
          method: 'PUT',
        );

        final responseBody = await streamedResponse.stream.bytesToString();
        debugPrint("📥 Update Response: $responseBody");

        if (streamedResponse.statusCode == 200 ||
            streamedResponse.statusCode == 201) {
          final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            final data = jsonResponse['data'];
            final employeeData = data['employee'] as Map<String, dynamic>?;

            if (employeeData != null) {
              Map<String, dynamic>? serviceData;
              if (data['service'] != null) {
                serviceData = data['service'] as Map<String, dynamic>;
              } else if (data['services'] != null &&
                  (data['services'] as List).isNotEmpty) {
                serviceData = data['services'][0] as Map<String, dynamic>;
              }

              return BusinessEmployeeModel.fromJsonWithService(
                employeeData: employeeData,
                serviceData: serviceData,
              );
            }
            return BusinessEmployeeModel.fromJson(data);
          }
        }

        // Parse error message from response
        try {
          final errorResponse =
              jsonDecode(responseBody) as Map<String, dynamic>;
          throw Exception(
            errorResponse['message'] ?? 'Failed to update employee with images',
          );
        } catch (e) {
          if (e.toString().contains('Exception:')) rethrow;
          throw Exception('Failed to update employee with images');
        }
      }

      // Standard JSON update if no images
      final bool hasServiceId =
          employee.serviceId != null && employee.serviceId!.trim().isNotEmpty;
      final bool appointmentEnabled = employee.isAppointmentBased == true;
      final String headline = _trim(employee.headline);
      final String description = _trim(employee.about);
      final String categoryId = _trim(employee.serviceCategory);

      final body = <String, dynamic>{
        'fullName': _trim(employee.name),
        'mobileNumber': _trim(employee.phone),
        'email': _trim(employee.email),
      };

      if (hasServiceId) {
        body['employeeServiceId'] = employee.serviceId!.trim();

        if (headline.isNotEmpty) {
          body['headline'] = headline;
        }
        if (description.isNotEmpty) {
          body['description'] = description;
        }

        body['appointmentEnabled'] = appointmentEnabled;
        final String availableTime = _trim(employee.availableTime);
        if (availableTime.isNotEmpty) {
          body['availableTime'] = availableTime;
        }

        if (_isObjectId(categoryId)) {
          body['category'] = categoryId;
          body['categories'] = <String>[categoryId];
        }

        final Map<String, String> reasons = _buildWhyChooseMap(
          employee.whyChooseUs,
        );
        if (reasons.isNotEmpty) {
          body['whyChooseUs'] = reasons;
          body['whyChooseService'] = reasons;
        }

        if (appointmentEnabled) {
          final List<Map<String, dynamic>> slots = _buildAppointmentSlots(
            employee.appointmentOptions,
          );
          if (slots.isNotEmpty) {
            body['appointmentSlots'] = slots;
          }
        } else if (employee.price != null) {
          body['basePrice'] = employee.price;
        }
      }

      body.removeWhere((key, value) => value == null);

      final response = await ApiService.put(
        endpoint: '/api/business-owners/employees/$id',
        body: body,
        requireAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          final employeeData = data['employee'] as Map<String, dynamic>?;

          if (employeeData != null) {
            Map<String, dynamic>? serviceData;
            if (data['service'] != null) {
              serviceData = data['service'] as Map<String, dynamic>;
            } else if (data['services'] != null &&
                (data['services'] as List).isNotEmpty) {
              serviceData = data['services'][0] as Map<String, dynamic>;
            }

            return BusinessEmployeeModel.fromJsonWithService(
              employeeData: employeeData,
              serviceData: serviceData,
            );
          }
          return BusinessEmployeeModel.fromJson(data);
        }
      }
      throw Exception('Failed to update employee');
    } catch (e) {
      debugPrint("❌ Update Employee Error: $e");
      rethrow;
    }
  }

  /// Delete Employee
  Future<void> deleteEmployee(String id) async {
    try {
      final response = await ApiService.delete(
        endpoint: '/api/business-owners/employees/$id',
        requireAuth: true,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete employee');
      }
    } catch (e) {
      debugPrint("❌ Delete Employee Error: $e");
      rethrow;
    }
  }

  /// Get Employee Stats Overview
  Future<Map<String, dynamic>> getEmployeeStats(String id) async {
    try {
      final response = await ApiService.get(
        endpoint: '/api/business-owners/employees/$id/overview',
        requireAuth: true,
      );

      debugPrint("📥 Get Employee Stats Status: ${response.statusCode}");
      debugPrint("📥 Get Employee Stats Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'] as Map<String, dynamic>;
        }
        throw Exception(jsonResponse['message'] ?? 'Failed to get stats');
      } else {
        throw Exception('Failed to load employee stats');
      }
    } catch (e) {
      debugPrint("❌ Get Employee Stats Error: $e");
      rethrow;
    }
  }

  /// Search Employees
  Future<List<BusinessEmployeeModel>> searchEmployees(String query) async {
    try {
      final response = await ApiService.get(
        endpoint: '/api/business-owners/employees/search?q=$query',
        requireAuth: true,
      );

      debugPrint("📥 Search Employees Status: ${response.statusCode}");
      debugPrint("📥 Search Employees Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((e) => BusinessEmployeeModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to search employees: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Search Employees Error: $e");
      rethrow;
    }
  }

  /// Get Employee Phone
  Future<String?> getEmployeePhone(String id) async {
    try {
      final response = await ApiService.get(
        endpoint: '/api/business-owners/employees/$id/phone',
        requireAuth: true,
      );

      debugPrint("📥 Get Employee Phone Status: ${response.statusCode}");
      debugPrint("📥 Get Employee Phone Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          if (data is String) return data;
          if (data is Map) {
            return data['phoneNumber']?.toString() ??
                data['phone']?.toString() ??
                data['mobileNumber']?.toString();
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint("❌ Get Employee Phone Error: $e");
      return null;
    }
  }

  /// Toggle Employee Status (Block/Unblock)
  Future<bool> toggleEmployeeStatus(String id) async {
    try {
      final response = await ApiService.patch(
        endpoint: '/api/business-owners/employees/$id/toggle-status',
        body: {},
        requireAuth: true,
      );

      debugPrint("📥 Toggle Employee Status Code: ${response.statusCode}");
      debugPrint("📥 Toggle Employee Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Toggle Employee Status Error: $e");
      rethrow;
    }
  }
}
