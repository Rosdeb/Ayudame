import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/viewmodels/event_attendees_controller.dart';
import 'package:middle_ware/models/event_attendee_model.dart';

class EventAttendeesScreen extends StatefulWidget {
  final dynamic event;

  const EventAttendeesScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventAttendeesScreen> createState() => _EventAttendeesScreenState();
}

class _EventAttendeesScreenState extends State<EventAttendeesScreen> {
  final EventAttendeesController controller = Get.put(EventAttendeesController());
  final ScrollController _scrollController = ScrollController();
  String t(String value) => AppTranslations.translateValue(value);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAttendees(widget.event.id.toString(), isRefresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        controller.loadMore(widget.event.id.toString());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.dark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            Text(
              t('Attendees List'),
              style: TextStyle(
                color: AppColors.dark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Obx(() => Text(
                  controller.eventName.value.isNotEmpty 
                      ? controller.eventName.value 
                      : (widget.event.eventName ?? t('Event Name')),
                  style: const TextStyle(
                    color: Color(0xFF1C5941),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                )),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchAttendees(widget.event.id.toString(), isRefresh: true),
        child: Column(
          children: [
            _buildSummaryHeader(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.attendees.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (controller.attendees.isEmpty) {
                  return ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      Center(child: Text(t('No attendees found for this event'))),
                    ],
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.attendees.length + (controller.hasNextPage.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.attendees.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    final attendee = controller.attendees[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAttendeeCard(attendee),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(t('Total Buyers'), controller.totalBuyers.value.toString(), const Color(0xFF1C5941)),
          Container(height: 40, width: 1, color: Colors.grey[300]),
          _buildSummaryItem(t('Tickets Sold'), controller.totalTicketsSold.value.toString(), const Color(0xFFD4B896)),
        ],
      )),
    );
  }

  Widget _buildSummaryItem(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
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
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendeeCard(Attendee attendee) {
    final buyer = attendee.buyer;
    final name = buyer?.name ?? t('common.unknown');
    final email = buyer?.email ?? t('No email provided');
    final profilePic = buyer?.profilePicture;
    final tickets = attendee.ticketsPurchased;
    final receipt = attendee.receiptNumber;
    final idNumber = attendee.idNumber ?? t('N/A');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // User Profile Image or Initials Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFF3F8F4),
              backgroundImage: (profilePic != null && profilePic.isNotEmpty)
                  ? NetworkImage(profilePic)
                  : null,
              child: (profilePic == null || profilePic.isEmpty)
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Color(0xFF1C5941),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            
            // Attendee Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C5941).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "$tickets ${t('Ticket(s)')}",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C5941),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Email displayed here
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${t('Receipt')}: $receipt",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${t('ID')}: $idNumber",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[500],
                    ),
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
