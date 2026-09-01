import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/design_system/app_tokens.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../models/payment.dart';
import '../cart/cart_controller.dart';
import '../cart/widgets/cart_summary_card.dart';
import '../cart/widgets/promotion_code_card.dart';
import 'checkout_order_service.dart';
import 'order_confirmation_page.dart';
import 'payment_flow_controller.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartController _cart = CartController.instance;
  final PaymentFlowController _paymentFlow = PaymentFlowController();
  String _delivery = 'Standard delivery';
  _DeliveryAddressData? _deliveryAddress;

  @override
  void dispose() {
    _paymentFlow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _cart,
          builder: (context, child) {
            if (_cart.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Your cart is empty.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth < 380 ? 16.0 : 20.0;

                return CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding:
                          EdgeInsets.fromLTRB(horizontal, 12, horizontal, 28),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 760),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _SecureCheckoutBanner(),
                                const SizedBox(height: 14),
                                _CheckoutOptionCard(
                                  key: const Key('checkout-address-option'),
                                  icon: Icons.location_on_outlined,
                                  title: 'Delivery address',
                                  subtitle: _deliveryAddress == null
                                      ? 'Add or confirm your delivery address'
                                      : '${_deliveryAddress!.fullName} • ${_deliveryAddress!.address}',
                                  actionLabel: _deliveryAddress == null
                                      ? 'Add address'
                                      : 'Edit',
                                  onTap: _showAddressSheet,
                                ),
                                const SizedBox(height: 12),
                                _CheckoutOptionCard(
                                  key: const Key('checkout-delivery-option'),
                                  icon: Icons.local_shipping_outlined,
                                  title: 'Delivery method',
                                  subtitle: _delivery,
                                  actionLabel: 'Change',
                                  onTap: _showDeliverySheet,
                                ),
                                const SizedBox(height: 12),
                                _CheckoutOptionCard(
                                  key: const Key('checkout-payment-option'),
                                  icon: Icons.payments_outlined,
                                  title: 'Payment method',
                                  subtitle: _paymentFlow.selectedMethod.label,
                                  actionLabel: 'Change',
                                  onTap: _showPaymentSheet,
                                ),
                                const SizedBox(height: 18),
                                PromotionCodeCard(cart: _cart),
                                const SizedBox(height: 12),
                                CartSummaryCard(cart: _cart),
                                const SizedBox(height: 14),
                                const _CheckoutTrustCard(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_cart, _paymentFlow]),
        builder: (context, child) {
          if (_cart.isEmpty) return const SizedBox.shrink();
          return _CheckoutBottomBar(
            total: _cart.total,
            isProcessing: _paymentFlow.isProcessing,
            onPressed: _paymentFlow.isProcessing ? null : _reviewOrder,
          );
        },
      ),
    );
  }

  Future<void> _showAddressSheet() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final result = await showModalBottomSheet<_DeliveryAddressData>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => _DeliveryAddressSheet(
        initialValue: _deliveryAddress,
      ),
    );

    if (!mounted || result == null) return;
    setState(() => _deliveryAddress = result);
  }

  Future<void> _showDeliverySheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Delivery method',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _SelectionTile(
                  title: 'Standard delivery',
                  subtitle: _cart.deliveryFee == 0
                      ? 'Free delivery unlocked'
                      : '${AppConstants.currency} ${_cart.deliveryFee.toStringAsFixed(0)} delivery fee',
                  selected: _delivery == 'Standard delivery',
                  onTap: () => Navigator.pop(context, 'Standard delivery'),
                ),
                const SizedBox(height: 8),
                _SelectionTile(
                  title: 'Priority delivery',
                  subtitle: 'Fast delivery option',
                  selected: _delivery == 'Priority delivery',
                  onTap: () => Navigator.pop(context, 'Priority delivery'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _delivery = selected);
    }
  }

  Future<void> _showPaymentSheet() async {
    final selected = await showModalBottomSheet<CheckoutPaymentMethod>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Payment method',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose how you want to complete this order.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...CheckoutPaymentMethod.values.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SelectionTile(
                      key: ValueKey<String>('checkout-payment-${option.name}'),
                      title: option.label,
                      subtitle: option.subtitle,
                      selected: _paymentFlow.selectedMethod == option,
                      onTap: () => Navigator.pop(context, option),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Row(
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 14, color: AppColors.textTertiary),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Payment orchestration is gateway-ready; raw card data is never stored in this app layer.',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 9.5,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      _paymentFlow.selectMethod(selected);
      setState(() {});
    }
  }

  Future<void> _reviewOrder() async {
    if (_deliveryAddress == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Add a delivery address before placing your order.'),
          ),
        );
      return;
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.success,
                  size: 34,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Review and confirm',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_cart.totalQuantity} items • $_delivery • ${_paymentFlow.selectedMethod.label}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    children: [
                      _ReviewRow(
                          label: 'Deliver to',
                          value: _deliveryAddress!.fullName),
                      const SizedBox(height: 8),
                      _ReviewRow(
                          label: 'Payment',
                          value: _paymentFlow.selectedMethod.label),
                      if (_cart.appliedPromotion != null) ...[
                        const SizedBox(height: 8),
                        _ReviewRow(
                            label: 'Promo',
                            value: _cart.appliedPromotion!.code),
                      ],
                      const Divider(height: 22),
                      _ReviewRow(
                        label: 'Order total',
                        value:
                            '${AppConstants.currency} ${_cart.total.toStringAsFixed(0)}',
                        strong: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    key: const Key('checkout-confirm-order'),
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.lock_rounded, size: 18),
                    label: Text(
                      'Place order • ${AppConstants.currency} ${_cart.total.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      await _placeOrder();
    }
  }

  Future<void> _placeOrder() async {
    final address = _deliveryAddress;
    if (address == null || _cart.isEmpty || _paymentFlow.isProcessing) return;

    final payment = await _paymentFlow.authorize(amount: _cart.total);
    if (!mounted) return;

    if (!payment.succeeded) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(payment.message)));
      return;
    }

    final order = CheckoutOrderService.placeOrder(
      cart: _cart,
      deliveryAddress:
          '${address.fullName} • ${address.mobile} • ${address.address}',
      deliveryMethod: _delivery,
      payment: payment,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      AppPageRoute(page: OrderConfirmationPage(order: order)),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _ReviewRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: TextStyle(
              color: strong ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: strong ? 12.5 : 10.5,
              height: 1.35,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SecureCheckoutBanner extends StatelessWidget {
  const _SecureCheckoutBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.14)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_rounded, color: AppColors.success, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure checkout',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your order details are protected throughout checkout.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    height: 1.35,
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

class _CheckoutOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  const _CheckoutOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                actionLabel,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryAddressData {
  final String fullName;
  final String mobile;
  final String address;

  const _DeliveryAddressData({
    required this.fullName,
    required this.mobile,
    required this.address,
  });
}

class _DeliveryAddressSheet extends StatefulWidget {
  final _DeliveryAddressData? initialValue;

  const _DeliveryAddressSheet({this.initialValue});

  @override
  State<_DeliveryAddressSheet> createState() => _DeliveryAddressSheetState();
}

class _DeliveryAddressSheetState extends State<_DeliveryAddressSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _addressController;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _mobileFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialValue?.fullName ?? '');
    _mobileController =
        TextEditingController(text: widget.initialValue?.mobile ?? '');
    _addressController =
        TextEditingController(text: widget.initialValue?.address ?? '');
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _mobileFocus.dispose();
    _addressFocus.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_saving) return;
    setState(() => _saving = true);

    FocusManager.instance.primaryFocus?.unfocus();
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    final result = _DeliveryAddressData(
      fullName: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      address: _addressController.text.trim(),
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final horizontal = MediaQuery.sizeOf(context).width < 360 ? 16.0 : 20.0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(horizontal, 4, horizontal, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Delivery address',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter the details for this order.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('checkout-address-name'),
                controller: _nameController,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _mobileFocus.requestFocus(),
                scrollPadding: const EdgeInsets.only(bottom: 140),
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('checkout-address-mobile'),
                controller: _mobileController,
                focusNode: _mobileFocus,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _addressFocus.requestFocus(),
                scrollPadding: const EdgeInsets.only(bottom: 140),
                decoration: const InputDecoration(
                  labelText: 'Mobile number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('checkout-address-line'),
                controller: _addressController,
                focusNode: _addressFocus,
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                scrollPadding: const EdgeInsets.only(bottom: 180),
                decoration: const InputDecoration(
                  labelText: 'Delivery address',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: FilledButton(
                  key: const Key('checkout-save-address'),
                  onPressed: _saving ? null : _saveAddress,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      tileColor: selected ? AppColors.primarySoft : AppColors.surface,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
      ),
      trailing: Icon(
        selected ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: selected ? AppColors.primary : AppColors.textTertiary,
      ),
    );
  }
}

class _CheckoutTrustCard extends StatelessWidget {
  const _CheckoutTrustCard();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline_rounded,
            size: 15, color: AppColors.textTertiary),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            'Encrypted and secure checkout',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  final double total;
  final bool isProcessing;
  final VoidCallback? onPressed;

  const _CheckoutBottomBar({
    required this.total,
    required this.isProcessing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppConstants.currency} ${total.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: onPressed,
                    iconAlignment: IconAlignment.end,
                    icon: isProcessing
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.1,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(
                      isProcessing ? 'Processing securely…' : 'Review order',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
