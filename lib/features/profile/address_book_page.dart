import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_theme_context.dart';
import '../../models/saved_address.dart';
import 'address/address_book_controller.dart';
import 'address/map_location_picker_page.dart';

class AddressBookPage extends StatefulWidget {
  const AddressBookPage({super.key});

  @override
  State<AddressBookPage> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
  final AddressBookController _controller = AddressBookController.instance;

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  Future<void> _addAddress() async {
    final result = await showModalBottomSheet<AddressEditorResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddressEditorSheet(),
    );
    if (!mounted || result == null) return;
    await _controller.save(result.address);
  }

  Future<void> _editAddress(SavedAddress address) async {
    final result = await showModalBottomSheet<AddressEditorResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddressEditorSheet(initialValue: address),
    );
    if (!mounted || result == null) return;
    await _controller.save(result.address);
  }

  Future<void> _removeAddress(SavedAddress address) async {
    final snapshot = address;
    await _controller.remove(address.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Address removed'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => _controller.save(snapshot),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery addresses')),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return LayoutBuilder(
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
                            const _AddressBookHero(),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              key: const Key('add-address-button'),
                              onPressed: _addAddress,
                              icon: const Icon(Icons.add_location_alt_outlined),
                              label: const Text('Add new address'),
                            ),
                            const SizedBox(height: 18),
                            if (_controller.addresses.isEmpty)
                              const _EmptyAddressState()
                            else
                              ..._controller.addresses.map(
                                (address) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _AddressCard(
                                    address: address,
                                    onEdit: () => _editAddress(address),
                                    onDefault: () => _controller.setDefault(address.id),
                                    onDelete: () => _removeAddress(address),
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
            );
          },
        ),
      ),
    );
  }
}

class _AddressBookHero extends StatelessWidget {
  const _AddressBookHero();

  @override
  Widget build(BuildContext context) {
    final scheme = context.dcxScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? [scheme.primaryContainer.withValues(alpha: .36), context.dcxSurface]
              : [const Color(0xFFF2EEFF), const Color(0xFFFBFAFF)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: scheme.primary.withValues(alpha: .14)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.home_work_outlined, color: scheme.primary, size: 25),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved addresses',
                  style: TextStyle(
                    color: context.dcxTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Save Home, Work or another location once and reuse it instantly at checkout.',
                  style: TextStyle(
                    color: context.dcxTextSecondary,
                    fontSize: 10.8,
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
  final SavedAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDefault;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDefault,
    required this.onDelete,
  });

  IconData get _icon {
    switch (address.type) {
      case SavedAddressType.home:
        return Icons.home_outlined;
      case SavedAddressType.work:
        return Icons.business_center_outlined;
      case SavedAddressType.other:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.dcxScheme;
    return Material(
      key: ValueKey<String>('saved-address-${address.id}'),
      color: context.dcxSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: address.isDefault
              ? scheme.primary.withValues(alpha: .42)
              : context.dcxBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: context.isDarkMode ? .42 : .72),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  alignment: Alignment.center,
                  child: Icon(_icon, color: scheme.primary, size: 21),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 7,
                        runSpacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            address.label,
                            style: TextStyle(
                              color: context.dcxTextPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (address.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                'Default',
                                style: TextStyle(
                                  color: scheme.onPrimaryContainer,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${address.fullName} • ${address.mobile}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.dcxTextSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Address options',
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'default') onDefault();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    if (!address.isDefault)
                      const PopupMenuItem(value: 'default', child: Text('Set as default')),
                    const PopupMenuItem(value: 'delete', child: Text('Remove')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address.addressLine,
              style: TextStyle(
                color: context.dcxTextPrimary,
                fontSize: 11.5,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (address.mapLocation != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: context.dcxSurfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(Icons.map_outlined, color: scheme.primary, size: 17),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Map pin • ${address.mapLocation!.displayLabel}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.dcxTextSecondary,
                          fontSize: 9.5,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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
        color: context.dcxSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.dcxBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.location_off_outlined, color: context.dcxTextTertiary, size: 36),
          const SizedBox(height: 10),
          Text(
            'No saved addresses yet',
            style: TextStyle(
              color: context.dcxTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Add an address now to make your next checkout almost instant.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.dcxTextSecondary,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class AddressEditorSheet extends StatefulWidget {
  final SavedAddress? initialValue;
  final bool showSaveForFuture;
  final bool initiallySaveForFuture;

  const AddressEditorSheet({
    super.key,
    this.initialValue,
    this.showSaveForFuture = false,
    this.initiallySaveForFuture = true,
  });

  @override
  State<AddressEditorSheet> createState() => _AddressEditorSheetState();
}

class _AddressEditorSheetState extends State<AddressEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _customLabelController;
  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _addressController;
  final _nameFocus = FocusNode();
  final _mobileFocus = FocusNode();
  final _addressFocus = FocusNode();
  late SavedAddressType _type;
  MapLocationData? _mapLocation;
  late bool _saveForFuture;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialValue?.type ?? SavedAddressType.home;
    _customLabelController = TextEditingController(text: widget.initialValue?.customLabel ?? '');
    _nameController = TextEditingController(text: widget.initialValue?.fullName ?? '');
    _mobileController = TextEditingController(text: widget.initialValue?.mobile ?? '');
    _addressController = TextEditingController(text: widget.initialValue?.addressLine ?? '');
    _mapLocation = widget.initialValue?.mapLocation;
    _saveForFuture = widget.initiallySaveForFuture;
  }

  @override
  void dispose() {
    _customLabelController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _nameFocus.dispose();
    _mobileFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  Future<void> _pickMapLocation() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await Navigator.of(context).push<MapLocationData>(
      AppPageRoute(
        page: MapLocationPickerPage(initialLocation: _mapLocation),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _mapLocation = result);
    if (_addressController.text.trim().isEmpty &&
        (result.resolvedAddress?.trim().isNotEmpty ?? false)) {
      _addressController.text = result.resolvedAddress!.trim();
    }
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    FocusManager.instance.primaryFocus?.unfocus();
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    final address = SavedAddress(
      id: widget.initialValue?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      type: _type,
      customLabel: _type == SavedAddressType.other ? _customLabelController.text.trim() : '',
      fullName: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      addressLine: _addressController.text.trim(),
      mapLocation: _mapLocation,
      isDefault: widget.initialValue?.isDefault ?? false,
      createdAt: widget.initialValue?.createdAt ?? DateTime.now(),
    );

    Navigator.of(context).pop(
      AddressEditorResult(
        address: address,
        saveForFuture: widget.showSaveForFuture ? _saveForFuture : true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final scheme = context.dcxScheme;
    return Material(
      key: const Key('address-editor-sheet'),
      color: context.dcxSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
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
                        color: context.dcxSurfaceStrong,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.showSaveForFuture
                        ? 'Delivery address'
                        : widget.initialValue == null
                            ? 'Add delivery address'
                            : 'Edit delivery address',
                    style: TextStyle(
                      color: context.dcxTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Use a saved type and optional map pin to keep delivery details fast and precise.',
                    style: TextStyle(
                      color: context.dcxTextSecondary,
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Address type',
                    style: TextStyle(
                      color: context.dcxTextPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: SavedAddressType.values.map((type) {
                      final selected = _type == type;
                      return ChoiceChip(
                        key: ValueKey<String>('address-type-${type.name}'),
                        selected: selected,
                        onSelected: (_) => setState(() => _type = type),
                        avatar: Icon(
                          type == SavedAddressType.home
                              ? Icons.home_outlined
                              : type == SavedAddressType.work
                                  ? Icons.business_center_outlined
                                  : Icons.location_on_outlined,
                          size: 16,
                          color: selected ? scheme.onSecondaryContainer : context.dcxTextSecondary,
                        ),
                        label: Text(type.label),
                      );
                    }).toList(),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _type == SavedAddressType.other
                        ? Padding(
                            key: const ValueKey<String>('custom-address-label'),
                            padding: const EdgeInsets.only(top: 12),
                            child: TextFormField(
                              key: const Key('address-label-field'),
                              controller: _customLabelController,
                              decoration: const InputDecoration(
                                labelText: 'Custom label',
                                hintText: 'Parents, Warehouse, Apartment',
                                prefixIcon: Icon(Icons.bookmark_border_rounded),
                              ),
                              validator: (value) => value == null || value.trim().isEmpty
                                  ? 'Add a short label for Other'
                                  : null,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: Key(widget.showSaveForFuture ? 'checkout-address-name' : 'address-name-field'),
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
                    key: Key(widget.showSaveForFuture ? 'checkout-address-mobile' : 'address-mobile-field'),
                    controller: _mobileController,
                    focusNode: _mobileFocus,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Mobile number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) => value == null || value.trim().length < 7
                        ? 'Enter a valid mobile number'
                        : null,
                    onFieldSubmitted: (_) => _addressFocus.requestFocus(),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: Key(widget.showSaveForFuture ? 'checkout-address-line' : 'address-location-field'),
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
                    validator: (value) => value == null || value.trim().length < 4
                        ? 'Enter a complete delivery address'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _MapLocationField(
                    mapLocation: _mapLocation,
                    onSelect: _pickMapLocation,
                    onClear: _mapLocation == null ? null : () => setState(() => _mapLocation = null),
                  ),
                  if (widget.showSaveForFuture) ...[
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      key: const Key('save-address-for-future'),
                      value: _saveForFuture,
                      onChanged: (value) => setState(() => _saveForFuture = value ?? true),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        'Save this address for future use',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                      subtitle: const Text(
                        'You can select it instantly on your next order.',
                        style: TextStyle(fontSize: 10.5, height: 1.35),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      key: Key(widget.showSaveForFuture ? 'checkout-save-address' : 'save-address-button'),
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(widget.showSaveForFuture ? 'Use this address' : 'Save address'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

class AddressEditorResult {
  final SavedAddress address;
  final bool saveForFuture;

  const AddressEditorResult({
    required this.address,
    required this.saveForFuture,
  });
}

class _MapLocationField extends StatelessWidget {
  final MapLocationData? mapLocation;
  final VoidCallback onSelect;
  final VoidCallback? onClear;

  const _MapLocationField({
    required this.mapLocation,
    required this.onSelect,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.dcxScheme;
    return Material(
      key: const Key('optional-map-location-field'),
      color: context.dcxSurfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: context.dcxBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.map_outlined, color: scheme.onPrimaryContainer, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Map Location (optional)',
                      style: TextStyle(
                        color: context.dcxTextPrimary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      mapLocation == null
                          ? 'Search or drop a Google Maps pin for extra delivery precision.'
                          : mapLocation!.displayLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.dcxTextSecondary,
                        fontSize: 9.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                IconButton(
                  tooltip: 'Remove map pin',
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 18),
                )
              else
                Icon(Icons.chevron_right_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
