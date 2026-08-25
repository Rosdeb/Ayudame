import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/models/event_model.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';

class EventDetailPage extends StatelessWidget {
  final EventModel event;

  const EventDetailPage({super.key, required this.event});

  String t(String value) => AppTranslations.translateValue(value);

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'N/A') return 'N/A';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM, yyyy hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppBar(title: t("event.event_details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Earnings Summary Card (Stats)
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('Earnings Summary'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem(
                        t('Total Tickets'),
                        '${event.maximumNumberOfTickets ?? 0}',
                      ),
                      _buildSummaryItem(
                        t('Revenue'),
                        '\$${event.revenue?.toStringAsFixed(2) ?? '0.00'}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem(
                        t('Tickets Sold'),
                        '${event.soldTickets ?? 0}',
                        icon: Icons.confirmation_num_outlined,
                      ),
                      _buildSummaryItem(
                        t('Attendees'),
                        '${event.soldTickets ?? 0}',
                        icon: Icons.people_outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Event Info Card
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        event.eventImage != null &&
                            event.eventImage!.startsWith('http')
                        ? Image.network(
                            event.eventImage!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    event.eventType ?? t("event.event_type"),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    event.eventName ?? t("event.untitled_event"),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t("event.event_details"),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildIconDetail(
                    Icons.calendar_today_outlined,
                    t("Date & Time"),
                    "${_formatDateTime(event.eventStartDateTime)} - ${_formatDateTime(event.eventEndDateTime)}",
                  ),
                  _buildIconDetail(
                    Icons.location_on_outlined,
                    t("common.location"),
                    event.eventLocation ?? t("No location"),
                  ),
                  _buildIconDetail(
                    Icons.confirmation_num_outlined,
                    t("event.ticket_price"),
                    "\$${event.ticketPrice?.toStringAsFixed(2) ?? '0.00'} ${t("per ticket")}",
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t("common.description"),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    event.eventDescription ?? t("No description provided."),
                    style: const TextStyle(color: Colors.grey, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const SizedBox(height: 32),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 180,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _buildSummaryItem(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null)
              Icon(icon, size: 20, color: const Color(0xFF1C5941)),
            if (icon != null) const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconDetail(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
