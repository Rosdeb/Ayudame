#!/usr/bin/perl
undef $/;
my $file = 'lib/views/user/orders/BookingDetailsScreen.dart';
open(my $fh, '<', $file) or die $!;
my $content = <$fh>;
close($fh);

$content =~ s/return\s*Expanded\(\s*child: SingleChildScrollView\(/return SingleChildScrollView(/s;

# I need to also remove the closing brace for the removed Expanded
# But it might be tricky. Let's just find `\n            \)\n          \],\n        \);\n      \}\),`
# Wait, let's see the end of the file.
