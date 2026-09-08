import 'package:get/get.dart';
import '../../models/business_employee_model.dart';
import '../../viewmodels/business_employee_viewmodel.dart';

class EmployeeDetailsController extends GetxController {
  final BusinessEmployeeViewModel _viewModel = Get.find<BusinessEmployeeViewModel>();
  
  var selectedTab = 0.obs;
  var isActive = true.obs;
  late BusinessEmployeeModel employee;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is BusinessEmployeeModel) {
      employee = Get.arguments as BusinessEmployeeModel;
      if (employee.id != null) {
        _viewModel.fetchEmployeeStats(employee.id!);
      }
    } else {
      employee = BusinessEmployeeModel(name: "Unknown");
    }
    isActive.value = employee.isActive ?? true;
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  Future<void> toggleStatus() async {
    if (employee.id != null) {
      bool success = await _viewModel.toggleEmployeeStatus(employee.id!);
      if (success) {
        isActive.value = !isActive.value;
      }
    }
  }
}
