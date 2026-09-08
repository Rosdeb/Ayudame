#!/usr/bin/perl
undef $/;
my $file = 'lib/controller/user/orders/booking_details_controller.dart';
open(my $fh, '<', $file) or die $!;
my $content = <$fh>;
close($fh);

# _payDownPayment - checkout session
$content =~ s/    final checkoutUri = Uri.parse\([\s\n]*"\$\{ApiService\.BASE_URL\}\$\{_bookingBasePath\(source\)\}\/\$bookingId\/checkout-session",[\s\n]*\);[\s\n]*_logApiRequest\('GET', checkoutUri\);[\s\n]*final response = await http\.get\([\s\n]*checkoutUri,[\s\n]*headers: \{[^}]+\},[\s\n]*\);[\s\n]*_logApiResponse\('GET', checkoutUri, response\);/    final response = await ApiService.get(endpoint: '\$\{_bookingBasePath(source)\}\/\$bookingId\/checkout-session', requireAuth: true);/g;

# _payDueAmount - due/intent
$content =~ s/    final dueIntentUri = Uri.parse\([\s\n]*"\$\{ApiService\.BASE_URL\}\$\{_bookingBasePath\(source\)\}\/\$bookingId\/due\/intent",[\s\n]*\);[\s\n]*_logApiRequest\('GET', dueIntentUri\);[\s\n]*final intentRes = await http\.get\([\s\n]*dueIntentUri,[\s\n]*headers: \{[^}]+\},[\s\n]*\);[\s\n]*_logApiResponse\('GET', dueIntentUri, intentRes\);/    final intentRes = await ApiService.get(endpoint: '\$\{_bookingBasePath(source)\}\/\$bookingId\/due\/intent', requireAuth: true);/g;

# confirm-due (POST)
$content =~ s/    final confirmUri = Uri.parse\([\s\n]*"\$\{ApiService\.BASE_URL\}\$\{_bookingBasePath\(source\)\}\/\$bookingId\/due\/confirm",[\s\n]*\);[\s\n]*_logApiRequest\('POST', confirmUri\);[\s\n]*final confirmRes = await http\.post\([\s\n]*confirmUri,[\s\n]*headers: \{[^}]+\},[\s\n]*\);[\s\n]*_logApiResponse\('POST', confirmUri, confirmRes\);/    final confirmRes = await ApiService.post(endpoint: '\$\{_bookingBasePath(source)\}\/\$bookingId\/due\/confirm', requireAuth: true, body: \{\});/g;

# submit review (POST)
$content =~ s/      final uri = Uri.parse\([\s\n]*"\$\{ApiService\.BASE_URL\}\/api\/reviews",[\s\n]*\);[\s\n]*_logApiRequest\('POST', uri\);[\s\n]*final response = await http\.post\([\s\n]*uri,[\s\n]*headers: \{[^}]+\},[\s\n]*body: reqBody,[\s\n]*\);[\s\n]*_logApiResponse\('POST', uri, response\);/      final response = await ApiService.post(endpoint: '\/api\/reviews', requireAuth: true, body: jsonDecode(reqBody));/g;


open(my $out, '>', $file) or die $!;
print $out $content;
close($out);
