import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/views/user/profile/event_details.dart';

class CustomEventCard extends StatelessWidget {
  final String title;
  final String eventName;
  final String eventImage;
  final String date;
  final String timeRange;
  final String location;
  final int attendingCount;
  final String eventId;

  const CustomEventCard({
    super.key,
    required this.title,
    required this.eventName,
    required this.date,
    required this.timeRange,
    required this.location,
    required this.attendingCount,
    required this.eventImage,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl = eventImage.trim();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => EventDetails(eventId: eventId));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: imageUrl.isEmpty
                      ? _buildImageFallback()
                      : Image.network(
                          imageUrl,
                          height: 155.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImageFallback(),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return _buildImageFallback();
                          },
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[700],
                    ),
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventName,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month, size: 18),
                          SizedBox(width: 2.w),
                          Text(
                            date,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 18),
                          SizedBox(width: 2.w),
                          Text(
                            timeRange,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 18),
                          SizedBox(width: 2.w),
                          Text(
                            location,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.people, size: 18),
                          SizedBox(width: 2.w),
                          Text(
                            '$attendingCount ${AppTranslations.translateValue("attending")}',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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

  Widget _buildImageFallback() {
    return Container(
      height: 155.h,
      width: double.infinity,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(Icons.event, color: Colors.grey.shade500, size: 30),
    );
  }
}
