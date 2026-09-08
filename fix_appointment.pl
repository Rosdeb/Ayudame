#!/usr/bin/perl
undef $/;
my $file = 'lib/views/user/orders/AppointmentDetailsScreen.dart';
open(my $fh, '<', $file) or die $!;
my $content = <$fh>;
close($fh);

$content =~ s/      body: Obx\(\(\) \{\s+if \(controller\.isLoading\.value\) \{\s+return const Center\(\s+child: CircularProgressIndicator\(color: Color\(0xFF1E523F\)\),\s+\);\s+\}/      body: Column(\n        children: [\n          \/\/ Custom Curved Header\n          Container(\n            height: 120,\n            padding: const EdgeInsets.only(top: 40, left: 16, right: 16),\n            decoration: const BoxDecoration(\n              color: Color(0xFF1E523F),\n              borderRadius: BorderRadius.only(\n                bottomLeft: Radius.circular(30),\n                bottomRight: Radius.circular(30),\n              ),\n            ),\n            child: Row(\n              children: [\n                IconButton(\n                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),\n                  onPressed: () => Get.back(),\n                ),\n                Expanded(\n                  child: Text(\n                    AppTranslations.translateValue("Appointment details"),\n                    textAlign: TextAlign.center,\n                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),\n                  ),\n                ),\n                const SizedBox(width: 40),\n              ],\n            ),\n          ),\n          Expanded(\n            child: Obx(() {\n              if (controller.isLoading.value) {\n                return const Center(\n                  child: CircularProgressIndicator(color: Color(0xFF1E523F)),\n                );\n              }/s;

$content =~ s/        return Column\(\s+children: \[\s+\/\/ Custom Curved Header.*?const SizedBox\(width: 40\),\s+\],\s+\),\s+\),\s+Expanded\(\s+child: SingleChildScrollView\(/        return SingleChildScrollView(/s;

$content =~ s/\s+\),\s+\),\s+\],\s+\);\s+\}\),/              ),\n            );\n          }),\n          ),\n        ],\n      ),/s;

open(my $out, '>', $file) or die $!;
print $out $content;
close($out);
