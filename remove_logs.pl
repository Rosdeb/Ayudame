#!/usr/bin/perl
undef $/;
my $file = 'lib/controller/user/orders/booking_details_controller.dart';
open(my $fh, '<', $file) or die $!;
my $content = <$fh>;
close($fh);

$content =~ s/  void _logApiRequest\(String method, Uri uri, \{String\? body\}\) \{.*?\}\n//s;
$content =~ s/  void _logApiResponse\(String method, Uri uri, http\.Response response\) \{.*?\}\n//s;

open(my $out, '>', $file) or die $!;
print $out $content;
close($out);
