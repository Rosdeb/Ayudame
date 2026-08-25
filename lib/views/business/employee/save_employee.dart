import '../../../../models/business_employee_model.dart';
import 'save_employee_Service.dart';

class SaveEmployee extends SaveEmployeeService {
  const SaveEmployee({super.key, BusinessEmployeeModel? employee})
    : super(employee: employee);
}
