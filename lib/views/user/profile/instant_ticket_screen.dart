import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/core/routes/app_routes.dart';
import 'package:middle_ware/models/user/home/ticket_purchase_model.dart';
import 'package:middle_ware/views/user/profile/e_ticket_screen.dart';

class InstantTicketScreen extends StatefulWidget {
  const InstantTicketScreen({super.key});

  @override
  State<InstantTicketScreen> createState() => _InstantTicketScreenState();
}

class _InstantTicketScreenState extends State<InstantTicketScreen> {
  TicketPurchaseDetail? ticket;

  @override
  void initState() {
    super.initState();
    final dynamic args = Get.arguments;
    if (args is TicketPurchaseDetail) {
      ticket = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2318),
      body: SafeArea(
        child: ticket == null
            ? _MissingTicketState(onViewAll: _openAllTickets)
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        _CircleIconBtn(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.maybePop(context),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Purchased Ticket',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                        _CircleIconBtn(
                          icon: Icons.confirmation_num_outlined,
                          onTap: _openAllTickets,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SuccessBanner(
                    title: AppTranslations.translateValue("Payment Completed"),
                    subtitle: AppTranslations.translateValue(
                      "Your ticket is ready right now",
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      children: [
                        TicketCard(ticket: ticket!),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _openAllTickets,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF3FD2B8),
                                  ),
                                  foregroundColor: const Color(0xFF3FD2B8),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  AppTranslations.translateValue("All Tickets"),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Get.offAllNamed(
                                  AppRoutes.userBottomNavScreen,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B8C78),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  AppTranslations.translateValue("Done"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _openAllTickets() {
    Get.offNamed(AppRoutes.userETicket);
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF25BE9E), Color(0xFF17705D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF25BE9E).withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  const _CircleIconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _MissingTicketState extends StatelessWidget {
  const _MissingTicketState({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.confirmation_num_outlined,
              color: Colors.white,
              size: 52,
            ),
            const SizedBox(height: 10),
            Text(
              AppTranslations.translateValue("Ticket data not found"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onViewAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B8C78),
              ),
              child: Text(AppTranslations.translateValue("View All Tickets")),
            ),
          ],
        ),
      ),
    );
  }
}
