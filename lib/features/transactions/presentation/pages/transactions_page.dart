import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_laundry_locker/core/routing/app_router.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:smart_laundry_locker/features/transactions/presentation/providers/transaction_injection.dart';
import 'package:smart_laundry_locker/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:smart_laundry_locker/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:smart_laundry_locker/core/utils/currency_formatter.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late final TransactionProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = TransactionInjection.provideTransactionProvider(ApiClient());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.fetchTransactions(refresh: true).then((_) {
        if (!mounted) return;
        context.read<WalletProvider>().getWalletBalance();
      });
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;

    // Header navy cố định ~80, nhưng vẫn tương đối theo chiều cao màn
    final expandedHeaderHeight = (screenH * 0.10).clamp(72.0, 80.0);

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Consumer2<TransactionProvider, WalletProvider>(
          builder: (context, provider, walletProvider, child) {
            return RefreshIndicator(
              onRefresh: () async {
                await provider.fetchTransactions(refresh: true);
                if (!context.mounted) return;
                await context.read<WalletProvider>().getWalletBalance();
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: expandedHeaderHeight,
                    backgroundColor: AISLShadcnTheme.navyPrimary,
                    elevation: 0,
                    centerTitle: true,
                    title: const Text(
                      'LỊCH SỬ GIAO DỊCH',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 0.5,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () async {
                          await provider.fetchTransactions(refresh: true);
                          await walletProvider.getWalletBalance();
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AISLShadcnTheme.navyPrimary,
                              AISLShadcnTheme.navyAccent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(height: screenH * 0.015),
                        Card(
                          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          elevation: 0,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AISLShadcnTheme.navySurface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: AISLShadcnTheme.navyPrimary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Số dư ví',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        CurrencyFormatter.formatVnd(
                                          walletProvider.balance,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                TextButton(
                                  onPressed: () async {
                                    final ok = await context.push<bool>(
                                      AppRouter.topUp,
                                    );
                                    if (!mounted) return;
                                    if (ok == true) {
                                      await _provider.fetchTransactions(
                                        refresh: true,
                                      );
                                      await walletProvider.getWalletBalance();
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    backgroundColor:
                                        AISLShadcnTheme.navyPrimary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Nạp tiền',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenH * 0.015),
                      ],
                    ),
                  ),
                  const _TransactionsSliverList(),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TransactionsSliverList extends StatelessWidget {
  const _TransactionsSliverList();

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final transactions = provider.transactions;

        debugPrint(
          '[TX][list] build() total=${transactions.length} loading=${provider.isLoading}',
        );

        if (provider.isLoading && transactions.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null && transactions.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Lỗi: ${provider.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        if (transactions.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'Chưa có giao dịch nào',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final tx = transactions[index];
              final isIncome = tx.type == 'TOP_UP' || tx.type == 'DEPOSIT';
              final amountColor = isIncome
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFD32F2F);
              final icon = isIncome
                  ? Icons.south_west_rounded
                  : Icons.north_east_rounded;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AISLShadcnTheme.navySurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: amountColor, size: 22),
                    ),
                    title: Text(
                      tx.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isIncome ? '+' : '-'}${NumberFormat.decimalPattern('vi_VN').format(tx.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: amountColor,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormat.decimalPattern(
                            'vi_VN',
                          ).format(tx.balanceAfter),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }, childCount: transactions.length),
          ),
        );
      },
    );
  }
}
