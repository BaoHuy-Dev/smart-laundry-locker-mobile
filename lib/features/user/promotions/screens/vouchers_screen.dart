import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../../core/services/loyalty_service.dart';
import '../../../../core/services/promotion_service.dart';

enum VoucherTab { vouchers, rewards }

class VouchersScreen extends ConsumerStatefulWidget {
  const VouchersScreen({super.key, this.initialTab = VoucherTab.vouchers});

  final VoucherTab initialTab;

  @override
  ConsumerState<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends ConsumerState<VouchersScreen> {
  late VoucherTab _tab = widget.initialTab;
  bool _isLoading = true;
  int? _redeemingRewardId;

  RewardsResponse? _rewards;
  List<StampCard> _stampCards = [];
  List<PromotionValidateResponse> _promotions = [];
  List<PointTransaction> _history = [];
  ExpiringPoints? _expiringPoints;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      RewardsResponse? rewards;
      var stampCards = <StampCard>[];
      var promotions = <PromotionValidateResponse>[];
      var history = <PointTransaction>[];
      ExpiringPoints? expiringPoints;

      try {
        rewards = (await LoyaltyService.getAvailableRewards()).data;
      } catch (_) {
        // Loyalty data can be unavailable for a new account.
      }
      try {
        stampCards = (await LoyaltyService.getStampCards()).data;
      } catch (_) {
        // Stamp cards are optional.
      }
      try {
        promotions = (await PromotionService.getActivePromotions()).data;
      } catch (_) {
        // System promotions are optional.
      }
      try {
        history = (await LoyaltyService.getPointsHistory(
          page: 0,
          size: 10,
        )).data.content;
      } catch (_) {
        // Point history is optional.
      }
      try {
        expiringPoints = (await LoyaltyService.getExpiringPoints()).data;
      } catch (_) {
        // Expiring-points banner is optional.
      }

      if (!mounted) return;
      setState(() {
        _rewards = rewards;
        _stampCards = stampCards;
        _promotions = promotions;
        _history = history;
        _expiringPoints = expiringPoints;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _redeem(RewardItem reward) async {
    setState(() => _redeemingRewardId = reward.id);
    try {
      final response = await LoyaltyService.redeemReward(reward.id);
      final code = response.data.code;
      _showMessage(
        code == null || code.isEmpty
            ? 'Đổi voucher thành công'
            : 'Đổi voucher thành công: $code',
      );
      await _load();
    } catch (_) {
      _showMessage('Không thể đổi voucher lúc này');
    } finally {
      if (mounted) setState(() => _redeemingRewardId = null);
    }
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    _showMessage('Đã sao chép mã $code');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final rewards = _rewards;
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(title: const Text('Kho voucher')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _PointsSummary(
                    currentPoints: rewards?.currentPoints ?? 0,
                    membershipTier: rewards?.membershipTier ?? '',
                    expiringPoints: _expiringPoints,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<VoucherTab>(
                    segments: const [
                      ButtonSegment(
                        value: VoucherTab.vouchers,
                        icon: Icon(Icons.card_giftcard),
                        label: Text('Voucher'),
                      ),
                      ButtonSegment(
                        value: VoucherTab.rewards,
                        icon: Icon(Icons.loyalty),
                        label: Text('Tích điểm'),
                      ),
                    ],
                    selected: {_tab},
                    onSelectionChanged: (value) =>
                        setState(() => _tab = value.first),
                  ),
                  const SizedBox(height: 16),
                  if (_tab == VoucherTab.vouchers)
                    _buildVouchersTab()
                  else
                    _buildRewardsTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildVouchersTab() {
    final redeemed = _rewards?.redeemedRewards ?? [];
    final activeRedeemed = redeemed
        .where((reward) => reward.status == 'ACTIVE')
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Voucher đã đổi (${activeRedeemed.length})'),
        if (activeRedeemed.isEmpty)
          const _EmptyPanel(message: 'Chưa có voucher đã đổi')
        else
          ...activeRedeemed.map(
            (reward) => _RedeemedRewardCard(
              reward: reward,
              onCopy: reward.code == null
                  ? null
                  : () => _copyCode(reward.code!),
              onUse: reward.code == null
                  ? null
                  : () => context.go('/user/lockers'),
            ),
          ),
        const SizedBox(height: 16),
        _sectionTitle('Ưu đãi hệ thống (${_promotions.length})'),
        if (_promotions.isEmpty)
          const _EmptyPanel(message: 'Chưa có ưu đãi khả dụng')
        else
          ..._promotions.map(
            (promo) => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.local_offer,
                  color: AppColors.primary,
                ),
                title: Text(promo.title),
                subtitle: Text(promo.code),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyCode(promo.code),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRewardsTab() {
    final rewards = _rewards?.availableRewards ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Voucher khả dụng (${rewards.length})'),
        if (rewards.isEmpty)
          const _EmptyPanel(message: 'Hãy tích thêm điểm để đổi voucher')
        else
          ...rewards.map(
            (reward) => _RewardCard(
              reward: reward,
              isRedeeming: _redeemingRewardId == reward.id,
              onRedeem: reward.canRedeem ? () => _redeem(reward) : null,
            ),
          ),
        if (_stampCards.isNotEmpty) ...[
          const SizedBox(height: 16),
          _sectionTitle('Thẻ tích dấu (${_stampCards.length})'),
          ..._stampCards.map(
            (card) => Card(
              child: ListTile(
                leading: const Icon(Icons.workspace_premium),
                title: Text(
                  card.serviceName.isEmpty ? card.stampType : card.serviceName,
                ),
                subtitle: LinearProgressIndicator(
                  value: (card.progressPercentage / 100)
                      .clamp(0.0, 1.0)
                      .toDouble(),
                ),
                trailing: Text('${card.currentStamps}/${card.stampsRequired}'),
              ),
            ),
          ),
        ],
        if (_history.isNotEmpty) ...[
          const SizedBox(height: 16),
          _sectionTitle('Lịch sử điểm'),
          ..._history.map(
            (tx) => Card(
              child: ListTile(
                leading: Icon(
                  tx.points >= 0 ? Icons.add_circle : Icons.remove_circle,
                  color: tx.points >= 0
                      ? AppColors.successColor
                      : AppColors.errorColor,
                ),
                title: Text(tx.description),
                subtitle: Text(formatDateTimeText(tx.createdAt)),
                trailing: Text(
                  '${tx.points >= 0 ? '+' : ''}${tx.points}',
                  style: TextStyle(
                    color: tx.points >= 0
                        ? AppColors.successColor
                        : AppColors.errorColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTypography.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PointsSummary extends StatelessWidget {
  const _PointsSummary({
    required this.currentPoints,
    required this.membershipTier,
    this.expiringPoints,
  });

  final int currentPoints;
  final String membershipTier;
  final ExpiringPoints? expiringPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: Colors.amber, size: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentPoints điểm',
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  membershipTier.isEmpty ? 'Thành viên' : membershipTier,
                  style: const TextStyle(color: AppColors.accent),
                ),
                if ((expiringPoints?.expiringPoints ?? 0) > 0)
                  Text(
                    '${expiringPoints!.expiringPoints} điểm sắp hết hạn',
                    style: const TextStyle(color: Colors.white70),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.isRedeeming,
    required this.onRedeem,
  });

  final RewardItem reward;
  final bool isRedeeming;
  final VoidCallback? onRedeem;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.card_giftcard, color: AppColors.primary),
        title: Text(reward.name),
        subtitle: Text('${reward.pointsRequired} điểm - ${reward.description}'),
        trailing: FilledButton(
          onPressed: isRedeeming ? null : onRedeem,
          child: isRedeeming
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(reward.canRedeem ? 'Đổi' : 'Chưa đủ'),
        ),
      ),
    );
  }
}

class _RedeemedRewardCard extends StatelessWidget {
  const _RedeemedRewardCard({required this.reward, this.onCopy, this.onUse});

  final RedeemedReward reward;
  final VoidCallback? onCopy;
  final VoidCallback? onUse;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.confirmation_number,
          color: AppColors.primary,
        ),
        title: Text(reward.rewardName),
        subtitle: Text(
          [
            if (reward.code?.isNotEmpty == true) 'Mã: ${reward.code}',
            if (reward.expiresAt != null)
              'HSD: ${formatDateText(reward.expiresAt)}',
          ].join('\n'),
        ),
        isThreeLine: reward.expiresAt != null,
        trailing: Wrap(
          children: [
            IconButton(onPressed: onCopy, icon: const Icon(Icons.copy)),
            IconButton(onPressed: onUse, icon: const Icon(Icons.arrow_forward)),
          ],
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.card_giftcard, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
