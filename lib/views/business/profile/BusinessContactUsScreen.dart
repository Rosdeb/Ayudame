import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/views/components/custom_app_bar.dart';

class BusinessContactUsScreen extends StatelessWidget {
  const BusinessContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title:  AppTranslations.translateValue('Contact Us'),showBackButton: true,),
      backgroundColor: const Color(0xFFE8F0ED),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildContactItem(
                  icon: Icons.camera_alt_outlined,
                  title: AppTranslations.translateValue('Instagram'),
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildContactItem(
                  icon: Icons.language,
                  title: AppTranslations.translateValue('Website'),
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildContactItem(
                  icon: Icons.phone_outlined,
                  title: AppTranslations.translateValue('Twitter'),
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildContactItem(
                  icon: Icons.email_outlined,
                  title: AppTranslations.translateValue('Email'),
                  onTap: () {
                    // Launch Email
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 24, color: Colors.black87),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
