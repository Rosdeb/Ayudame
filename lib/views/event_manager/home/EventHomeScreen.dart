import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/app_icons.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/views/event_manager/home/EventNotificationPage.dart';
import 'package:middle_ware/viewmodels/event_manager_notification_controller.dart';
import 'package:middle_ware/viewmodels/event_viewmodel.dart';
import 'package:middle_ware/viewmodels/event_manager_viewmodel.dart';
import 'EditEventPage.dart';
import 'EventDetailPage.dart';
import 'cancel.dart';
import 'EventAttendeesScreen.dart';
class EventHomeScreen extends StatefulWidget {
  const EventHomeScreen({super.key});

  @override
  State<EventHomeScreen> createState() => _EventHomeScreenState();
}

class _EventHomeScreenState extends State<EventHomeScreen> {
  final EventViewModel _eventViewModel = Get.put(EventViewModel());
  final EventManagerViewModel _managerViewModel = Get.put(
    EventManagerViewModel(),
  );
  final EventManagerNotificationController _notificationController = Get.put(
    EventManagerNotificationController(),
  );
  String t(String value) => AppTranslations.translateValue(value);

  @override
  void initState() {
    super.initState();
    _eventViewModel.fetchEvents(refresh: true);
    _eventViewModel.fetchSalesOverview();
    _managerViewModel.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Obx(
          () => AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: AppColors.mainAppColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            flexibleSpace: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFD4B896),
                    backgroundImage:
                        _managerViewModel
                                    .currentManager
                                    .value
                                    ?.profilePicture !=
                                null &&
                            _managerViewModel
                                .currentManager
                                .value!
                                .profilePicture!
                                .isNotEmpty
                        ? NetworkImage(
                                _managerViewModel
                                    .currentManager
                                    .value!
                                    .profilePicture!,
                              )
                              as ImageProvider
                        : const AssetImage('assets/images/men.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t('home.welcome_back'),
                          style: TextStyle(
                            fontFamily: "Inter",
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _managerViewModel.currentManager.value?.fullName ?? '',
                          style: const TextStyle(
                            fontFamily: "Inter",
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    return InkWell(
                      onTap: () {
                        Get.to(() => EventNotificationPage());
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(10),
                            child: SvgPicture.asset(
                              AppIcons.notification,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF2D6A4F),
                                BlendMode.srcIn,
                              ),
                              width: 20,
                              height: 20,
                            ),
                          ),
                          if (_notificationController.unreadCount.value > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${_notificationController.unreadCount.value}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _eventViewModel.fetchEvents(refresh: true);
          await _eventViewModel.fetchSalesOverview();
        },
        child: Obx(() {
          if (_eventViewModel.isLoading.value && _eventViewModel.events.isEmpty) {
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDashboard(),
                const SizedBox(height: 24),
                Text(
                  t('profile.my_events'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 16),
                if (_eventViewModel.isLoading.value && _eventViewModel.events.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_eventViewModel.events.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(t('event.no_events_found')),
                    ),
                  )
                else
                  ..._eventViewModel.events.map((event) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildEventCard(context, event: event),
                  )),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, {required dynamic event}) {
    return GestureDetector(
      onTap: () {
        Get.to(() => EventDetailPage(event: event));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  if (event.eventImage != null &&
                      event.eventImage.startsWith('http'))
                    Image.network(
                      event.eventImage,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderImage(),
                    )
                  else
                    _buildPlaceholderImage(),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      event.eventType ?? t('event.event_category'),
                      style: const TextStyle(
                        color: Color(0xFF1C5941),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.eventName ?? t('event.untitled_event'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date & Time
                  Row(
                    children: [
                      _buildInfoCol(
                        t('common.date'),
                        _formatDate(event.eventStartDateTime),
                      ),
                      _buildInfoCol(
                        t('common.time'),
                        _formatTime(event.eventStartDateTime),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tickets Sales & Revenue
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEBEBEB)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t('Sales Performance'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '\$${(event.salesPerformance?.earned ?? 0).toStringAsFixed(2)} ${t('Earned')}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C5941),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t('Tickets Sold'),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              event.salesPerformance?.sold ?? '0 / 0',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (event.salesPerformance?.soldPerformancePercent ?? 0) / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4B896)),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        AppIcons.location,
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          Colors.grey[600]!,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.eventLocation ?? t('event.no_location_provided'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.to(() => EditEventPage(event: event));
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F8F4),
                            foregroundColor: const Color(0xFF1C5941),
                            side: const BorderSide(color: Color(0xFF1C5941)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            t('common.edit'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.to(() => EventAttendeesScreen(event: event));
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD4B896),
                            side: const BorderSide(color: Color(0xFFD4B896)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            t('Attendees'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => showCancelEventDialog(
                            context: context,
                            event: event,
                            eventViewModel: _eventViewModel,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C5941),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            t('common.cancel'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildInfoCol(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 160,
      color: Colors.grey[200],
      child: Center(
        child: SvgPicture.asset(
          AppIcons.create,
          width: 50,
          height: 50,
          colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
        ),
      ),
    );
  }

  String _formatDate(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return t('N/A');
    try {
      final dateTime = DateTime.tryParse(dateTimeStr);
      if (dateTime == null) return dateTimeStr.split(' ')[0];
      return DateFormat('dd MMM, yyyy').format(dateTime);
    } catch (e) {
      return dateTimeStr.split('T')[0];
    }
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return t('N/A');
    try {
      final dateTime = DateTime.tryParse(dateTimeStr);
      if (dateTime == null) {
        if (dateTimeStr.contains(' ')) return dateTimeStr.split(' ')[1];
        if (dateTimeStr.contains('T')) {
          return dateTimeStr.split('T')[1].split('.')[0].substring(0, 5);
        }
        return t('N/A');
      }
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return t('N/A');
    }
  }

  Widget _buildDashboard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('Sales Overview'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
              _buildPeriodSelector(),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDashboardStat(
                  t('Total Revenue'),
                  '\$${(_eventViewModel.salesOverview['totalRevenue'] ?? 0).toStringAsFixed(2)}',
                  AppIcons.income,
                  const Color(0xFF1C5941),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDashboardStat(
                  t('Tickets Sold'),
                  '${_eventViewModel.salesOverview['totalTicketsSold'] ?? 0}',
                  AppIcons.ticket,
                  const Color(0xFFD4B896), 
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'monthly') {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(_eventViewModel.salesYear.value, _eventViewModel.salesMonth.value),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            helpText: t('Select any date in the target month'),
          );
          if (picked != null) {
            _eventViewModel.fetchSalesOverview(
              period: 'monthly',
              month: picked.month,
              year: picked.year,
            );
          }
        } else {
          _eventViewModel.fetchSalesOverview(period: 'all_time');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F8F4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _eventViewModel.salesPeriod.value == 'all_time' 
                ? t('All Time') 
                : DateFormat('MMM yyyy').format(DateTime(_eventViewModel.salesYear.value, _eventViewModel.salesMonth.value)),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C5941),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF1C5941), size: 16),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'monthly',
          child: Text(t('Monthly')),
        ),
        PopupMenuItem(
          value: 'all_time',
          child: Text(t('All Time')),
        ),
      ],
    );
  }

  Widget _buildDashboardStat(String label, String value, String iconPath, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
