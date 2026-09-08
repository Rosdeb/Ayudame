#!/usr/bin/perl
undef $/;
my $file = 'lib/controller/user/orders/booking_details_controller.dart';
open(my $fh, '<', $file) or die $!;
my $content = <$fh>;
close($fh);

$content =~ s/Future<void> cancelBooking\(String id\) async \{\s*try \{\s*isLoading\(true\);/Future<void> cancelBooking(String id) async {\n    try {\n      showActionLoadingDialog();/g;
$content =~ s/Future<void> payDue\(String id\) async \{\s*try \{\s*isLoading\(true\);/Future<void> payDue(String id) async {\n    try {\n      showActionLoadingDialog();/g;
$content =~ s/Future<void> payDownPayment\(String id\) async \{\s*try \{\s*isLoading\(true\);/Future<void> payDownPayment(String id) async {\n    try {\n      showActionLoadingDialog();/g;
$content =~ s/Future<void> submitReview\([^)]+\) async \{\s*try \{\s*isLoading\(true\);/Future<void> submitReview(String bookingId, int rating, String comment) async {\n    try {\n      showActionLoadingDialog();/g;

# Fix the finally blocks for these methods
# This is tricky because fetchBookingDetails still needs isLoading(false).
# I'll just change all `isLoading(false);` to `isLoading(false); hideActionLoadingDialog();`
$content =~ s/isLoading\(false\);/isLoading(false);\n      hideActionLoadingDialog();/g;

open(my $out, '>', $file) or die $!;
print $out $content;
close($out);
