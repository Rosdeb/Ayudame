import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/core/localization/locale_controller.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'WelcomeScreen.dart';
import 'package:middle_ware/services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool privacyAccepted = false;
  bool termsAccepted = false;
  final LocaleController _localeController = Get.find<LocaleController>();

  @override
  void initState() {
    super.initState();
    _checkTermsStatus();
  }

  Future<void> _checkTermsStatus() async {
    final accepted = await StorageService.isTermsAccepted();
    if (accepted && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Title
              Text(
                AppTranslations.translateValue('onboarding.language_prompt'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.050),

              // Language Selection Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // English Card
                  Flexible(
                    child: _buildLanguageCard(
                      context: context,
                      language: 'English',
                      flag: '🇺🇸',
                      imagePath: 'assets/images/uk.png',
                      cardColor: Color(0xFF1C5941),
                      textColor: Colors.white,
                      onTap: () {
                        _handleLanguageSelection(context, 'English');
                      },
                    ),
                  ),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.05,
                  ), // 5% of screen width
                  // Spanish Card
                  Flexible(
                    child: _buildLanguageCard(
                      context: context,
                      language: 'Spanish',
                      flag: '🇪🇸',
                      textColor: Colors.black,
                      imagePath: 'assets/images/spain.png',
                      cardColor: AppColors.mainAppColor.withOpacity(0.1),
                      onTap: () {
                        _handleLanguageSelection(context, 'Spanish');
                      },
                    ),
                  ),
                ],
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required BuildContext context,
    required String language,
    required String flag,
    required String imagePath,
    required Color cardColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: cardColor, // Different color for each card
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.mainAppColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Flag Icon - Circular with border
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white, // White background for flag circle
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  imagePath, // Different image for each card
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to emoji if image fails to load
                    return Center(
                      child: Text(flag, style: const TextStyle(fontSize: 20)),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Language Name
            Text(
              language,
              style: TextStyle(
                // REMOVED 'const' from here
                fontWeight: FontWeight.w500,
                color: textColor, // This makes it non-constant
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLanguageSelection(
    BuildContext context,
    String language,
  ) async {
    await _localeController.setLocale(
      language == 'Spanish'
          ? AppTranslations.spanishLocale
          : AppTranslations.englishLocale,
    );

    final termsAlreadyAccepted = await StorageService.isTermsAccepted();
    if (!context.mounted) return;

    if (termsAlreadyAccepted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
      );
    } else {
      setState(() {
        privacyAccepted = false;
      });
      _showPrivacyPolicyDialog(context, language);
    }
  }

  void _showPrivacyPolicyDialog(BuildContext context, String language) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.all(28),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Text(
                      AppTranslations.translateValue(
                        'legal.privacy_policy_title',
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 24,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Last updated date
                    Text(
                      AppTranslations.translateValue('legal.last_updated'),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description
                    Text(
                      AppTranslations.translateValue('legal.privacy_intro_1'),
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      AppTranslations.translateValue('legal.privacy_intro_2'),
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section 1
                    Text(
                      AppTranslations.translateValue(
                        'legal.privacy_section_1_title',
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      AppTranslations.translateValue(
                        'legal.privacy_section_1_body',
                      ),
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section 2
                    Text(
                      AppTranslations.translateValue(
                        'legal.privacy_section_2_title',
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      AppTranslations.translateValue(
                        'legal.privacy_section_2_body',
                      ),
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Accept Terms Checkbox
                    InkWell(
                      onTap: () {
                        setDialogState(() {
                          privacyAccepted = !privacyAccepted;
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: privacyAccepted
                                  ? const Color(0xFF9CCCA9)
                                  : Colors.white,
                              border: Border.all(
                                color: const Color(0xFF9CCCA9),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: privacyAccepted
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppTranslations.translateValue(
                              'legal.accept_terms',
                            ),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: privacyAccepted
                            ? () {
                                Navigator.of(context).pop();
                                _handleGetStarted(context, language);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006400),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppTranslations.translateValue('common.next'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleGetStarted(BuildContext context, String language) {
    setState(() {
      termsAccepted = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(),
                    child: Text(
                      AppTranslations.translateValue('legal.terms_title'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.translateValue(
                              'legal.terms_welcome_title',
                            ),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            AppTranslations.translateValue('legal.terms_intro'),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            AppTranslations.translateValue(
                              'legal.terms_section_user_responsibilities',
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            AppTranslations.translateValue(
                              'legal.terms_user_agree',
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                          ),

                          const SizedBox(height: 10),

                          _buildBulletPoint(
                            AppTranslations.translateValue(
                              'legal.terms_bullet_1',
                            ),
                          ),
                          _buildBulletPoint(
                            AppTranslations.translateValue(
                              'legal.terms_bullet_2',
                            ),
                          ),
                          _buildBulletPoint(
                            AppTranslations.translateValue(
                              'legal.terms_bullet_3',
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            AppTranslations.translateValue(
                              'legal.terms_section_intellectual_property',
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            AppTranslations.translateValue(
                              'legal.terms_intellectual_body',
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            AppTranslations.translateValue(
                              'legal.terms_section_disclaimers',
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            AppTranslations.translateValue(
                              'legal.terms_disclaimer_body',
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 20),

                          InkWell(
                            onTap: () {
                              setDialogState(() {
                                termsAccepted = !termsAccepted;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),

                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: termsAccepted
                                          ? const Color(0xFF9CCCA9)
                                          : Colors.white,
                                      border: Border.all(
                                        color: const Color(0xFF9CCCA9),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: termsAccepted
                                        ? const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    AppTranslations.translateValue(
                                      'legal.accept_terms',
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Next Button
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: termsAccepted
                            ? () async {
                                await StorageService.saveTermsAccepted(true);
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WelcomeScreen(),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF72DF8D),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppTranslations.translateValue('common.next'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 10),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
