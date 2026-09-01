import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/theme/app_colors.dart';
import '../../data/demo_orders.dart';

class AddressBookPage extends StatefulWidget {
  const AddressBookPage({super.key});

  @override
  State<AddressBookPage> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
  late final List<_SavedAddress> _addresses;

  @override
  void initState() {
    super.initState();
    final unique = <String>{};
    _addresses = DemoOrders.orders
        .where((order) => unique.add(order.deliveryAddress))
        .map(
          (order) => _SavedAddress(
            id: order.id,
            label: 'Delivery address',
            fullName: 'DCX customer',
            mobile: '',
            address: order.deliveryAddress,
            isDefault: unique.length == 1,
          ),
        )
        .toList(growable: true);
  }

  Future<void> _addAddress() async {
    final result = await showModalBottomSheet<_SavedAddress>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddressEditorSheet(),
    );

    if (!mounted || result == null) return;
    setState(() => _addresses.add(result));
  }

  Future<void> _editAddress(_SavedAddress address) async {
    final result = await showModalBottomSheet<_SavedAddress>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressEditorSheet(initialValue: address),
    );

    if (!mounted || result == null) return;
    final index = _addresses.indexWhere((item) => item.id == address.id);
    if (index == -1) return;
    setState(() => _addresses[index] = result);
  }

  void _setDefault(_SavedAddress address) {
    setState(() {
      for (var index = 0; index < _addresses.length; index++) {
        final item = _addresses[index];
        _addresses[index] = item.copyWith(isDefault: item.id == address.id);
      }
    });
  }

  void _removeAddress(_SavedAddress address) {
    final index = _addresses.indexOf(address);
    if (index == -1) return;
    setState(() => _addresses.removeAt(index));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Address removed'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              if (!mounted) return;
              setState(() => _addresses.insert(index, address));
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Delivery addresses')),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth < 380 ? 16.0 : 20.0;
            return ListView(
              key: const PageStorageKey<String>('address-book-scroll'),
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
                        _AddressBookHero(addressCount: _addresses.length),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Saved addresses',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              key: const Key('add-address-button'),
                              onPressed: _addAddress,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add address'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_addresses.isEmpty)
                          const _EmptyAddressState()
                        else
                          ..._addresses.map(
                            (address) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _AddressCard(
                                address: address,
                                onEdit: () => _editAddress(address),
                                onDelete: () => _removeAddress(address),
                                onSetDefault: () => _setDefault(address),
                              ),
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

class _AddressBookHero extends StatelessWidget {
  final int addressCount;

  const _AddressBookHero({required this.addressCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Faster checkout',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$addressCount saved ${addressCount == 1 ? 'address' : 'addresses'} available for delivery.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    height: 1.4,
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

class _AddressCard extends StatelessWidget {
  final _SavedAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: address.isDefault
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border,
          width: address.isDefault ? 1.2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.home_work_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            address.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successSoft,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      address.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Address options',
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'default') onSetDefault();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (!address.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Text('Set as default'),
                    ),
                  const PopupMenuItem(value: 'delete', child: Text('Remove')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyAddressState extends StatelessWidget {
  const _EmptyAddressState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.location_off_outlined,
              color: AppColors.textTertiary, size: 36),
          SizedBox(height: 10),
          Text(
            'No saved addresses yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Add a delivery address to make checkout faster.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedAddress {
  final String id;
  final String label;
  final String fullName;
  final String mobile;
  final String address;
  final bool isDefault;

  const _SavedAddress({
    required this.id,
    required this.label,
    required this.fullName,
    required this.mobile,
    required this.address,
    this.isDefault = false,
  });

  _SavedAddress copyWith({bool? isDefault}) {
    return _SavedAddress(
      id: id,
      label: label,
      fullName: fullName,
      mobile: mobile,
      address: address,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class _AddressEditorSheet extends StatefulWidget {
  final _SavedAddress? initialValue;

  const _AddressEditorSheet({this.initialValue});

  @override
  State<_AddressEditorSheet> createState() => _AddressEditorSheetState();
}

class _AddressEditorSheetState extends State<_AddressEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _addressController;
  final _nameFocus = FocusNode();
  final _mobileFocus = FocusNode();
  final _addressFocus = FocusNode();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(
      text: widget.initialValue?.label ?? 'Home',
    );
    _nameController = TextEditingController(
      text: widget.initialValue?.fullName == 'DCX customer'
          ? ''
          : widget.initialValue?.fullName ?? '',
    );
    _mobileController =
        TextEditingController(text: widget.initialValue?.mobile ?? '');
    _addressController =
        TextEditingController(text: widget.initialValue?.address ?? '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _nameFocus.dispose();
    _mobileFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    FocusManager.instance.primaryFocus?.unfocus();
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    Navigator.of(context).pop(
      _SavedAddress(
        id: widget.initialValue?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        label: _labelController.text.trim(),
        fullName: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        address: _addressController.text.trim(),
        isDefault: widget.initialValue?.isDefault ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Material(
      color: Colors.transparent,
      child: Container(
        key: const Key('address-editor-sheet'),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(20, 12, 20, keyboard + 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceStrong,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.initialValue == null
                        ? 'Add delivery address'
                        : 'Edit delivery address',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Keep delivery details clear so checkout stays fast and accurate.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    key: const Key('address-label-field'),
                    controller: _labelController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Label',
                      hintText: 'Home, Office, Family',
                      prefixIcon: Icon(Icons.bookmark_border_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Add a short address label'
                        : null,
                    onFieldSubmitted: (_) => _nameFocus.requestFocus(),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: const Key('address-name-field'),
                    controller: _nameController,
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter the recipient name'
                        : null,
                    onFieldSubmitted: (_) => _mobileFocus.requestFocus(),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: const Key('address-mobile-field'),
                    controller: _mobileController,
                    focusNode: _mobileFocus,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Mobile number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) =>
                        value == null || value.trim().length < 7
                            ? 'Enter a valid mobile number'
                            : null,
                    onFieldSubmitted: (_) => _addressFocus.requestFocus(),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: const Key('address-location-field'),
                    controller: _addressController,
                    focusNode: _addressFocus,
                    minLines: 2,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Delivery address',
                      hintText: 'Area, street, building and zone',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (value) =>
                        value == null || value.trim().length < 4
                            ? 'Enter a complete delivery address'
                            : null,
                    onFieldSubmitted: (_) => _save(),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      key: const Key('save-address-button'),
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(_saving ? 'Saving...' : 'Save address'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
