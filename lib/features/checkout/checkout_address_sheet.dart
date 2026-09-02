import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/theme/app_theme_context.dart';
import '../../models/saved_address.dart';
import '../profile/address/address_book_controller.dart';
import '../profile/address_book_page.dart';

class CheckoutAddressSheet extends StatefulWidget {
  final SavedAddress? selectedAddress;

  const CheckoutAddressSheet({
    super.key,
    this.selectedAddress,
  });

  @override
  State<CheckoutAddressSheet> createState() => _CheckoutAddressSheetState();
}

class _CheckoutAddressSheetState extends State<CheckoutAddressSheet> {
  final AddressBookController _controller = AddressBookController.instance;
  SavedAddress? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedAddress;
    _controller.load().then((_) {
      if (!mounted) return;
      setState(() => _selected ??= _controller.defaultAddress);
    });
  }

  Future<void> _addNew() async {
    final result = await showModalBottomSheet<AddressEditorResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddressEditorSheet(
        showSaveForFuture: true,
        initiallySaveForFuture: true,
      ),
    );
    if (!mounted || result == null) return;
    Navigator.of(context).pop(result);
  }

  void _useSelected() {
    final selected = _selected;
    if (selected == null) return;
    Navigator.of(context).pop(
      AddressEditorResult(address: selected, saveForFuture: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.addresses.isEmpty) {
          return const AddressEditorSheet(
            showSaveForFuture: true,
            initiallySaveForFuture: true,
          );
        }

        final horizontal = MediaQuery.sizeOf(context).width < 360 ? 16.0 : 20.0;
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(horizontal, 4, horizontal, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose delivery address',
                  style: TextStyle(
                    color: context.dcxTextPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Select a saved address or add a new one for this order.',
                  style: TextStyle(
                    color: context.dcxTextSecondary,
                    fontSize: 11.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * .42,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final address in _controller.addresses)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 9),
                            child: _CheckoutSavedAddressTile(
                              address: address,
                              selected: _selected?.id == address.id,
                              onTap: () => setState(() => _selected = address),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  key: const Key('checkout-add-new-address'),
                  onPressed: _addNew,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Add new address'),
                ),
                const SizedBox(height: 9),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    key: const Key('checkout-use-saved-address'),
                    onPressed: _selected == null ? null : _useSelected,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Use selected address'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CheckoutSavedAddressTile extends StatelessWidget {
  final SavedAddress address;
  final bool selected;
  final VoidCallback onTap;

  const _CheckoutSavedAddressTile({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.dcxScheme;
    final icon = address.type == SavedAddressType.home
        ? Icons.home_outlined
        : address.type == SavedAddressType.work
            ? Icons.business_center_outlined
            : Icons.location_on_outlined;

    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: context.isDarkMode ? .32 : .58)
          : context.dcxSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: selected ? scheme.primary : context.dcxBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey<String>('checkout-saved-address-${address.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: scheme.primary, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            address.label,
                            style: TextStyle(
                              color: context.dcxTextPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (address.isDefault)
                          Text(
                            'DEFAULT',
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.addressLine,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.dcxTextSecondary,
                        fontSize: 10,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (address.mapLocation != null) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.map_outlined, size: 13, color: scheme.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address.mapLocation!.displayLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.dcxTextTertiary,
                                fontSize: 8.7,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? scheme.primary : context.dcxTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
