import re
with open('lib/controller/user/orders/booking_details_controller.dart', 'r') as f:
    content = f.read()

# fetchBookingDetails
content = re.sub(
    r"final uri = Uri.parse\([\s\n]*\"\$\{ApiService\.BASE_URL\}\$\{_bookingBasePath\(_activeSource\.value\)\}/\$id\",[\s\n]*\);[\s\n]*_logApiRequest\('GET', uri\);[\s\n]*final response = await http\.get\([\s\n]*uri,[\s\n]*headers: \{[^}]+\},[\s\n]*\);[\s\n]*_logApiResponse\('GET', uri, response\);",
    r"final response = await ApiService.get(endpoint: '${_bookingBasePath(_activeSource.value)}/$id', requireAuth: true);",
    content
)

# cancelBooking
content = re.sub(
    r"final uri = Uri.parse\([\s\n]*\"\$\{ApiService\.BASE_URL\}\$\{_bookingBasePath\(_activeSource\.value\)\}/\$id/cancel\",[\s\n]*\);[\s\n]*_logApiRequest\('PATCH', uri\);[\s\n]*final response = await http\.patch\([\s\n]*uri,[\s\n]*headers: \{[^}]+\},[\s\n]*\);[\s\n]*_logApiResponse\('PATCH', uri, response\);",
    r"final response = await ApiService.patch(endpoint: '${_bookingBasePath(_activeSource.value)}/$id/cancel', requireAuth: true, body: {});",
    content
)

# _payDownPayment - payment-status
content = re.sub(
    r"final statusUri = Uri.parse\([\s\n]*\"\$\{ApiService\.BASE_URL\}\$\{_bookingBasePath\(source\)\}/\$bookingId/payment-status\",[\s\n]*\);[\s\n]*_logApiRequest\('GET', statusUri\);[\s\n]*final statusRes = await http\.get\([\s\n]*statusUri,[\s\n]*headers: \{[^}]+\},[\s\n]*\);[\s\n]*_logApiResponse\('GET', statusUri, statusRes\);",
    r"final statusRes = await ApiService.get(endpoint: '${_bookingBasePath(source)}/$bookingId/payment-status', requireAuth: true);",
    content
)

# _payDownPayment - checkout-session
content = re.sub(
    r"final intentUri = Uri.parse\([\s\n]*\"\$\{ApiService\.BASE_URL\}\$\{_bookingBasePath\(source\)\}/\$bookingId/checkout-session\",[\s\n]*\);[\s\n]*_logApiRequest\('GET', intentUri\);[\s\n]*final intentRes = await http\.get\([\s\n]*intentUri,[\s\n]*headers: \{[^}]+\},[\s\n]*\);[\s\n]*_logApiResponse\('GET', intentUri, intentRes\);",
    r"final intentRes = await ApiService.get(endpoint: '${_bookingBasePath(source)}/$bookingId/checkout-session', requireAuth: true);",
    content
)

# payDue - payment-status
content = re.sub(
    r"final statusUri = Uri.parse\([\s\n]*\"\$\{ApiService\.BASE_URL\}\$\{_bookingBasePath\(_activeSource\.value\)\}/\$id/payment-status\",[\s\n]*\);[\s\n]*_logApiRequest\('GET', statusUri\);[\s\n]*final statusRes = await http\.get\([\s\n]*statusUri,[\s\n]*headers: \{[^}]+\},[\s\n]*\);[\s\n]*_logApiResponse\('GET', statusUri, statusRes\);",
    r"final statusRes = await ApiService.get(endpoint: '${_bookingBasePath(_activeSource.value)}/$id/payment-status', requireAuth: true);",
    content
)

# _payDueAmount - confirm-payment (POST)
content = re.sub(
    r"final confirmUri = Uri.parse\([\s\n]*\"\$\{ApiService\.BASE_URL\}\$\{_bookingBasePath\(source\)\}/\$bookingId/confirm-payment\",[\s\n]*\);[\s\n]*_logApiRequest\('POST', confirmUri\);[\s\n]*final confirmRes = await http\.post\([\s\n]*confirmUri,[\s\n]*headers: \{[^}]+\},[\s\n]*\);[\s\n]*_logApiResponse\('POST', confirmUri, confirmRes\);",
    r"final confirmRes = await ApiService.post(endpoint: '${_bookingBasePath(source)}/$bookingId/confirm-payment', requireAuth: true, body: {});",
    content
)

# submitReview (POST)
content = re.sub(
    r"final uri = Uri.parse\([\s\n]*\"\$\{ApiService\.BASE_URL\}/api/reviews\",[\s\n]*\);[\s\n]*_logApiRequest\('POST', uri\);[\s\n]*final response = await http\.post\([\s\n]*uri,[\s\n]*headers: \{[^}]+\},[\s\n]*body: reqBody,[\s\n]*\);[\s\n]*_logApiResponse\('POST', uri, response\);",
    r"final response = await ApiService.post(endpoint: '/api/reviews', requireAuth: true, body: jsonDecode(reqBody));",
    content
)

with open('lib/controller/user/orders/booking_details_controller.dart', 'w') as f:
    f.write(content)
