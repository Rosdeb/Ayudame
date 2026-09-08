#!/usr/bin/perl
undef $/;
my $file = 'lib/controller/user/service/appointment_details_controller.dart';
open(my $fh, '<', $file) or die $!;
my $content = <$fh>;
close($fh);

$content =~ s/Future<void> payAppointment\(String id\) async \{\s*try \{\s*isLoading\(true\);/Future<void> payAppointment(String id) async {\n    try {\n      showActionLoadingDialog();/g;

# Fix finally block
$content =~ s/isLoading\(false\);/isLoading(false);\n      hideActionLoadingDialog();/g;

# Replace Stripe error snackbar
$content =~ s/Get\.snackbar\(\s*'\''Payment Error'\'',\s*_humanizeError[^;]+;/if (Get.context != null) { FloatingErrorBar.show(Get.context!, message: "Payment failed"); }/g;

open(my $out, '>', $file) or die $!;
print $out $content;
close($out);
