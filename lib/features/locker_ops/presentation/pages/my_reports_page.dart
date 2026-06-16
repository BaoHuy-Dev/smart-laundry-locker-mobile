import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';
import 'package:smart_laundry_locker/features/locker_ops/presentation/widgets/ops_widgets.dart';
import 'package:smart_laundry_locker/shared/widgets/user_ui_kit.dart';

/// Read-only view of the customer's own locker fault reports
/// (`GET /api/lockers/my-reports`), so they can see claim/resolve progress
/// without having to ask maintenance directly.
class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  final _service = LockerOpsService();
  List<Map<String, dynamic>> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final reports = await _service.myReports();
      if (!mounted) return;
      setState(() => _reports = reports);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(LockerOpsService.errorMessage(e))),
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          BrandHeroHeader(
            title: 'Báo cáo của tôi',
            subtitle: 'Theo dõi các báo lỗi ô tủ bạn đã gửi',
            trailing: BrandCircleIconButton(
              icon: LucideIcons.refreshCw,
              onTap: _load,
              iconSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AislBrand.navy),
                  )
                : _reports.isEmpty
                ? const OpsEmptyState(
                    icon: LucideIcons.clipboardCheck,
                    title: 'Chưa có báo cáo nào',
                    subtitle: 'Báo lỗi ô tủ từ chi tiết đơn sẽ hiện ở đây.',
                  )
                : RefreshIndicator(
                    color: AislBrand.navy,
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: _reports.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) => _ReportCard(report: _reports[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});
  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    final status = report['status'] as String?;
    final description = report['description'] as String?;
    final lockerLabel =
        report['lockerName'] ?? report['lockerCode'] ?? report['lockerId'];

    return OpsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  report['title']?.toString() ?? 'Báo cáo ô tủ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: opsDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(status),
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(fontSize: 13, color: opsMutedText),
            ),
          ],
          const SizedBox(height: 12),
          OpsInfoRow(
            icon: LucideIcons.warehouse,
            label: 'Tủ',
            value: '${lockerLabel ?? '-'}',
          ),
          if (report['boxNumber'] != null)
            OpsInfoRow(
              icon: LucideIcons.grid3x3,
              label: 'Ô',
              value: '${report['boxNumber']}',
            ),
          OpsInfoRow(
            icon: LucideIcons.calendar,
            label: 'Gửi lúc',
            value: fmtDateTime(report['createdAt']),
          ),
          if (status == 'IN_PROGRESS')
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: OpsBanner(
                tone: OpsBannerTone.info,
                icon: LucideIcons.userCheck,
                text: 'Đội bảo trì đang xử lý báo cáo này.',
              ),
            )
          else if (status == 'RESOLVED')
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: OpsBanner(
                tone: OpsBannerTone.success,
                icon: LucideIcons.circleCheck,
                text: 'Báo cáo đã được xử lý xong.',
              ),
            ),
        ],
      ),
    );
  }
}
