import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/theme/app_colors.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    const faqs = <_FaqItem>[
      _FaqItem(
        question: 'Where can I track my order?',
        answer: 'Open My orders, select the order, and use the integrated tracking timeline for the latest delivery progress.',
      ),
      _FaqItem(
        question: 'How do I change a delivery address?',
        answer: 'Use Delivery addresses in your account to add, edit, remove, or choose a default address.',
      ),
      _FaqItem(
        question: 'How do I reorder an item?',
        answer: 'Open a previous order and use Buy again to place the products back into your cart.',
      ),
      _FaqItem(
        question: 'Where are my saved products?',
        answer: 'Your Wishlist keeps the products you saved from Home, Product listings, and Product details.',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Help & support')),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth < 380 ? 16.0 : 20.0;
            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                10,
                horizontal,
                MediaQuery.paddingOf(context).bottom + 28,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _SupportHero(),
                        const SizedBox(height: 18),
                        const Text(
                          'Frequently asked questions',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.border),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: List.generate(faqs.length, (index) {
                              final faq = faqs[index];
                              return Column(
                                children: [
                                  ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                                    childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                    title: Text(
                                      faq.question,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          faq.answer,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11.5,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (index != faqs.length - 1)
                                    const Divider(height: 1),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SupportHero extends StatelessWidget {
  const _SupportHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primarySoft,
            child: Icon(
              Icons.support_agent_rounded,
              color: AppColors.primary,
              size: 25,
            ),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How can we help?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Find quick answers for orders, delivery, saved products, and account settings.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
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

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}
