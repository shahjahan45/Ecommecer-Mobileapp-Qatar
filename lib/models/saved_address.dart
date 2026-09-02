enum SavedAddressType { home, work, other }

extension SavedAddressTypeX on SavedAddressType {
  String get label {
    switch (this) {
      case SavedAddressType.home:
        return 'Home';
      case SavedAddressType.work:
        return 'Work';
      case SavedAddressType.other:
        return 'Other';
    }
  }
}

class MapLocationData {
  final double latitude;
  final double longitude;
  final String? resolvedAddress;
  final String? placeName;

  const MapLocationData({
    required this.latitude,
    required this.longitude,
    this.resolvedAddress,
    this.placeName,
  });

  String get coordinateLabel =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  String get displayLabel {
    final place = placeName?.trim();
    if (place != null && place.isNotEmpty) return place;
    final address = resolvedAddress?.trim();
    if (address != null && address.isNotEmpty) return address;
    return coordinateLabel;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'resolvedAddress': resolvedAddress,
        'placeName': placeName,
      };

  factory MapLocationData.fromJson(Map<String, dynamic> json) {
    return MapLocationData(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      resolvedAddress: json['resolvedAddress'] as String?,
      placeName: json['placeName'] as String?,
    );
  }
}

class SavedAddress {
  final String id;
  final SavedAddressType type;
  final String customLabel;
  final String fullName;
  final String mobile;
  final String addressLine;
  final MapLocationData? mapLocation;
  final bool isDefault;
  final DateTime createdAt;

  const SavedAddress({
    required this.id,
    required this.type,
    required this.fullName,
    required this.mobile,
    required this.addressLine,
    this.customLabel = '',
    this.mapLocation,
    this.isDefault = false,
    required this.createdAt,
  });

  String get label {
    if (type != SavedAddressType.other) return type.label;
    final value = customLabel.trim();
    return value.isEmpty ? 'Other' : value;
  }

  String get checkoutSummary => '$fullName • $mobile • $addressLine';

  SavedAddress copyWith({
    SavedAddressType? type,
    String? customLabel,
    String? fullName,
    String? mobile,
    String? addressLine,
    MapLocationData? mapLocation,
    bool clearMapLocation = false,
    bool? isDefault,
  }) {
    return SavedAddress(
      id: id,
      type: type ?? this.type,
      customLabel: customLabel ?? this.customLabel,
      fullName: fullName ?? this.fullName,
      mobile: mobile ?? this.mobile,
      addressLine: addressLine ?? this.addressLine,
      mapLocation: clearMapLocation ? null : mapLocation ?? this.mapLocation,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type.name,
        'customLabel': customLabel,
        'fullName': fullName,
        'mobile': mobile,
        'addressLine': addressLine,
        'mapLocation': mapLocation?.toJson(),
        'isDefault': isDefault,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;
    return SavedAddress(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      type: SavedAddressType.values.firstWhere(
        (item) => item.name == typeName,
        orElse: () => SavedAddressType.other,
      ),
      customLabel: json['customLabel'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      addressLine: json['addressLine'] as String? ?? '',
      mapLocation: json['mapLocation'] is Map
          ? MapLocationData.fromJson(
              Map<String, dynamic>.from(json['mapLocation'] as Map),
            )
          : null,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
