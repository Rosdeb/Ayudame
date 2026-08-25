import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/controller/user/profile/my_tickets_controller.dart';
import 'package:middle_ware/models/user/home/ticket_purchase_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

String t(String value) => AppTranslations.translateValue(value);

class UserETicketScreen extends StatefulWidget {
  const UserETicketScreen({super.key});

  @override
  State<UserETicketScreen> createState() => _UserETicketScreenState();
}

class _UserETicketScreenState extends State<UserETicketScreen> {
  final MyTicketsController controller = Get.put(MyTicketsController());
  TicketPurchaseDetail? _initialPurchase;
  bool _isDownloadingPdf = false;

  @override
  void initState() {
    super.initState();
    final dynamic args = Get.arguments;
    if (args is TicketPurchaseDetail) {
      _initialPurchase = args;
    }
    controller.fetchMyTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08140F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D2018), Color(0xFF08140F), Color(0xFF050C09)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TicketAppBar(
                title: t('My Tickets'),
                onBack: () => Navigator.maybePop(context),
                onDownload: _handleDownloadAllTickets,
                isDownloading: _isDownloadingPdf,
              ),
              Expanded(
                child: Obx(() {
                  final List<TicketPurchaseDetail> tickets = _mergeTickets(
                    controller.purchases,
                  );

                  if (controller.isLoading.value && tickets.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (controller.errorMessage.isNotEmpty && tickets.isEmpty) {
                    return _ErrorState(
                      message: controller.errorMessage.value,
                      onRetry: controller.fetchMyTickets,
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF3FD2B8),
                    backgroundColor: const Color(0xFF10261D),
                    onRefresh: controller.fetchMyTickets,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                      children: [
                        _buildSummaryPanel(tickets),
                        if (_initialPurchase != null) ...[
                          const SizedBox(height: 10),
                          _buildLatestPurchaseHint(),
                        ],
                        const SizedBox(height: 18),
                        if (tickets.isEmpty)
                          const _EmptyState()
                        else
                          ...List.generate(tickets.length, (index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == tickets.length - 1 ? 0 : 20,
                              ),
                              child: TicketCard(ticket: tickets[index]),
                            );
                          }),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPanel(List<TicketPurchaseDetail> tickets) {
    final int totalOrders = tickets.length;
    final int totalPersons = tickets.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final double totalSpent = tickets.fold<double>(
      0,
      (sum, item) => sum + item.totalAmount,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E8A75), Color(0xFF0E4E3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF21A086).withValues(alpha: 0.26),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('Ticket Wallet'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            t('All purchased tickets in one place'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryTile(
                  icon: Icons.receipt_long_rounded,
                  label: t('Orders'),
                  value: totalOrders.toString().padLeft(2, '0'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _summaryTile(
                  icon: Icons.groups_2_outlined,
                  label: t('People'),
                  value: totalPersons.toString().padLeft(2, '0'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _summaryTile(
                  icon: Icons.attach_money_rounded,
                  label: t('Spent'),
                  value: '\$${totalSpent.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestPurchaseHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF17392D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A6150)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.flash_on_rounded,
            color: Color(0xFF3FD2B8),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t('Latest purchased ticket is shown first.'),
              style: const TextStyle(
                color: Color(0xFFD7F6EC),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDownloadAllTickets() async {
    final List<TicketPurchaseDetail> tickets = _mergeTickets(
      controller.purchases,
    );

    if (tickets.isEmpty) {
      Get.snackbar(
        t('Error'),
        t('No purchased tickets found yet.'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_isDownloadingPdf) return;
    setState(() => _isDownloadingPdf = true);

    try {
      final pw.Document pdf = pw.Document();

      for (final ticket in tickets) {
        final TicketEventInfo? event = ticket.event;

        pdf.addPage(
          pw.MultiPage(
            pageTheme: pw.PageTheme(
              margin: const pw.EdgeInsets.all(24),
              theme: pw.ThemeData(
                defaultTextStyle: const pw.TextStyle(fontSize: 11),
              ),
            ),
            build: (context) => [
              pw.Text(
                t('E-Ticket'),
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal800,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                event?.eventName.trim().isNotEmpty == true
                    ? event!.eventName
                    : t('Event'),
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 14),
              _pdfInfoRow(
                t('Receipt number'),
                _receiptNumber(ticket.purchaseId),
              ),
              _pdfInfoRow(
                t('common.date'),
                _formatDate(event?.eventStartDateTime),
              ),
              _pdfInfoRow(
                t('common.time'),
                _formatTimeRange(
                  event?.eventStartDateTime,
                  event?.eventEndDateTime,
                ),
              ),
              _pdfInfoRow(
                t('Location'),
                event?.eventLocation.isNotEmpty == true
                    ? event!.eventLocation
                    : t('N/A'),
              ),
              _pdfInfoRow(
                t('Number of person'),
                ticket.quantity.toString().padLeft(2, '0'),
              ),
              _pdfInfoRow(
                t('Amount'),
                '\$${ticket.totalAmount.toStringAsFixed(2)}',
              ),
              _pdfInfoRow(
                t('common.status'),
                ticket.paymentStatus.toUpperCase(),
              ),
              pw.SizedBox(height: 14),
              pw.Text(
                t('Ticket Owners'),
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal900,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _pdfTableCell(t('Name'), isHeader: true),
                      _pdfTableCell(t('ID Type'), isHeader: true),
                      _pdfTableCell(t('Identification number'), isHeader: true),
                    ],
                  ),
                  ...ticket.ticketOwners.map(
                    (owner) => pw.TableRow(
                      children: [
                        _pdfTableCell(owner.name),
                        _pdfTableCell(owner.identificationType),
                        _pdfTableCell(owner.identificationNumber),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      final bytes = await pdf.save();
      final filename =
          'all_tickets_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: filename,
      );
    } catch (e) {
      Get.snackbar(
        t('Error'),
        '${t('Failed to generate tickets PDF')}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloadingPdf = false);
      }
    }
  }

  String _receiptNumber(String rawId) {
    final String cleaned = rawId.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (cleaned.isEmpty) return t('N/A');
    if (cleaned.length <= 16) return cleaned.toUpperCase();
    return cleaned.substring(cleaned.length - 16).toUpperCase();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return t('N/A');
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTimeRange(DateTime? start, DateTime? end) {
    if (start == null) return t('N/A');
    final String startText = _formatTime(start);
    if (end == null) return startText;
    return '$startText ${t('to')} ${_formatTime(end)}';
  }

  String _formatTime(DateTime time) {
    final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute $period';
  }

  pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  pw.Widget _pdfTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text.isEmpty ? t('N/A') : text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  List<TicketPurchaseDetail> _mergeTickets(List<TicketPurchaseDetail> fetched) {
    final List<TicketPurchaseDetail> merged = List<TicketPurchaseDetail>.from(
      fetched,
    );

    if (_initialPurchase != null) {
      final bool alreadyExists = merged.any(
        (item) => item.id == _initialPurchase!.id,
      );
      if (!alreadyExists) {
        merged.insert(0, _initialPurchase!);
      }
    }

    merged.sort((a, b) {
      final DateTime aTime =
          a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bTime =
          b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return merged;
  }
}

class _TicketAppBar extends StatelessWidget {
  const _TicketAppBar({
    required this.title,
    required this.onBack,
    this.onDownload,
    this.isDownloading = false,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback? onDownload;
  final bool isDownloading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          _CircleBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          if (onDownload == null)
            const SizedBox(width: 38)
          else if (isDownloading)
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            _CircleBtn(icon: Icons.download_rounded, onTap: onDownload!),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});

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

class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.ticket});

  final TicketPurchaseDetail ticket;

  static const _teal = Color(0xFF22C5A8);
  static const _cardBg = Color(0xFF1B8C78);
  static const _accentYellow = Color(0xFFFFD84D);

  @override
  Widget build(BuildContext context) {
    final TicketEventInfo? event = ticket.event;
    final TicketOwnerInfo? firstOwner = ticket.ticketOwners.isNotEmpty
        ? ticket.ticketOwners.first
        : null;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _teal.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ImageBanner(imageUrl: event?.eventImage ?? ''),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoChip(
                  label: t('Event'),
                  value: _eventName(event),
                  valueStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        label: t('common.date'),
                        value: _formatDate(event?.eventStartDateTime),
                      ),
                    ),
                    Expanded(
                      child: _InfoChip(
                        label: t('common.time'),
                        value: _formatTimeRange(
                          event?.eventStartDateTime,
                          event?.eventEndDateTime,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _InfoChip(
                  label: t('Person name'),
                  value: firstOwner?.name ?? t('N/A'),
                ),
                const SizedBox(height: 14),
                _InfoChip(
                  label: t('Identification number'),
                  value: firstOwner?.identificationNumber ?? t('N/A'),
                ),
                const SizedBox(height: 14),
                _InfoChip(
                  label: t('Receipt number'),
                  value: _receiptNumber(ticket.purchaseId),
                ),
                const SizedBox(height: 14),
                _InfoChip(
                  label: t('Number of person'),
                  value: ticket.quantity.toString().padLeft(2, '0'),
                  valueStyle: const TextStyle(
                    color: _accentYellow,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        label: t('common.status'),
                        value: ticket.paymentStatus.toUpperCase(),
                      ),
                    ),
                    Expanded(
                      child: _InfoChip(
                        label: t('Amount'),
                        value: '\$${ticket.totalAmount.toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const _TearLine(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: _BarcodeRow(seed: ticket.purchaseId.hashCode),
          ),
        ],
      ),
    );
  }

  String _eventName(TicketEventInfo? event) {
    final String name = event?.eventName ?? '';
    return name.trim().isNotEmpty ? name : t('Event');
  }

  String _receiptNumber(String rawId) {
    final String cleaned = rawId.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (cleaned.isEmpty) return t('N/A');
    if (cleaned.length <= 16) return cleaned.toUpperCase();
    return cleaned.substring(cleaned.length - 16).toUpperCase();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return t('N/A');
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTimeRange(DateTime? start, DateTime? end) {
    if (start == null) return t('N/A');
    final String startText = _formatTime(start);
    if (end == null) return startText;
    return '$startText ${t('to')} ${_formatTime(end)}';
  }

  String _formatTime(DateTime time) {
    final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute $period';
  }
}

class _ImageBanner extends StatelessWidget {
  const _ImageBanner({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.trim().isNotEmpty && imageUrl.startsWith('http'))
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              )
            else
              _buildPlaceholder(),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF1B8C78).withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5CC9A0), Color(0xFF1A7A5E), Color(0xFF0C4433)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(top: -40, right: -30, child: _GlassCircle(size: 170)),
        Positioned(bottom: -30, left: 20, child: _GlassCircle(size: 110)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.festival_rounded,
                color: Colors.white.withValues(alpha: 0.45),
                size: 48,
              ),
              const SizedBox(height: 6),
              Text(
                t('Event Image'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.07),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style:
              valueStyle ??
              const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
        ),
      ],
    );
  }
}

class _TearLine extends StatelessWidget {
  const _TearLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          Transform.translate(
            offset: const Offset(-14, 0),
            child: const _Notch(),
          ),
          Expanded(child: CustomPaint(painter: _DashPainter())),
          Transform.translate(
            offset: const Offset(14, 0),
            child: const _Notch(),
          ),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  const _Notch();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFF0F2318),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const dashWidth = 7.0;
    const dashGap = 5.0;
    double x = 0;
    final y = size.height / 2;

    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarcodeRow extends StatelessWidget {
  const _BarcodeRow({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    final rng = Random(seed.abs());
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(55, (i) {
              final w = rng.nextDouble();
              final isBlank = w < 0.18;
              return Expanded(
                flex: w > 0.75 ? 2 : 1,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: isBlank ? 1.2 : 0.4),
                  decoration: isBlank
                      ? null
                      : BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(1),
                        ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _barcodeNumber(seed),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  String _barcodeNumber(int rawSeed) {
    final int positive = rawSeed.abs();
    final String number = positive.toString().padLeft(24, '0');
    return '${number.substring(0, 4)} ${number.substring(4, 8)} ${number.substring(8, 12)} ${number.substring(12, 16)}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          t('No purchased tickets found yet.'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B8C78),
              ),
              child: Text(t('common.retry')),
            ),
          ],
        ),
      ),
    );
  }
}
