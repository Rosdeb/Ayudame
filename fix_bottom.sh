#!/bin/bash
FILE="lib/widgets/bottom_navb.dart"
sed -i '' -e 's/return Scaffold(/return PopScope(\n      canPop: false,\n      onPopInvokedWithResult: (didPop, result) {\n        if (didPop) return;\n        if (selectedIndex != 0) {\n          setState(() {\n            selectedIndex = 0;\n          });\n        }\n      },\n      child: Scaffold(/g' $FILE
sed -i '' -e 's/    );/      ),\n    );/g' $FILE
