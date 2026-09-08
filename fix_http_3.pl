#!/usr/bin/perl
undef $/;
my $file = 'lib/controller/user/orders/booking_details_controller.dart';
open(my $fh, '<', $file) or die $!;
my $content = <$fh>;
close($fh);

$content =~ s/    final dueConfirmUri = Uri.parse\([\s\n]*"\$\{ApiService\.BASE_URL\}\$\{_bookingBasePath\(source\)\}\/\$bookingId\/due\/confirm",[\s\n]*\);[\s\n]*_logApiRequest\('POST', dueConfirmUri\);[\s\n]*final confirmRes = await http\.post\([\s\n]*dueConfirmUri,[\s\n]*headers: \{[^}]+\},[\s\n]*\);[\s\n]*_logApiResponse\('POST', dueConfirmUri, confirmRes\);/    final confirmRes = await ApiService.post(endpoint: '\$\{_bookingBasePath(source)\}\/\$bookingId\/due\/confirm', requireAuth: true, body: \{\});/g;

$content =~ s/      final uri = Uri.parse\([\s\n]*"\$\{ApiService\.BASE_URL\}\$\{_bookingBasePath\(_activeSource\.value\)\}\/\$id\/review",[\s\n]*\);[\s\n]*final reqBody = jsonEncode\(\{"rating": rating, "comment": trimmedComment\}\);[\s\n]*_logApiRequest\('POST', uri, body: reqBody\);[\s\n]*final response = await http\.post\([\s\n]*uri,[\s\n]*headers: \{[^}]+\},[\s\n]*body: reqBody,[\s\n]*\);[\s\n]*_logApiResponse\('POST', uri, response\);/      final response = await ApiService.post(endpoint: '\$\{_bookingBasePath(_activeSource.value)\}\/\$id\/review', requireAuth: true, body: {"rating": rating, "comment": trimmedComment});/g;

open(my $out, '>', $file) or die $!;
print $out $content;
close($out);
