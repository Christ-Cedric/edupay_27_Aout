class TransportVehicle {
  final String id;
  final String name;
  final String? description;
  final double price;
  final List<String> images;
  final bool isAvailable;
  final DateTime? createdAt;

  const TransportVehicle({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.images = const [],
    this.isAvailable = true,
    this.createdAt,
  });

  factory TransportVehicle.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        parsedImages = (json['images'] as List).map((e) => e.toString()).toList();
      }
    }

    return TransportVehicle(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images: parsedImages,
      isAvailable: json['is_available'] as bool? ?? json['isAvailable'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price.toInt(),
      'images': images,
      'is_available': isAvailable,
    };
  }

  TransportVehicle copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    List<String>? images,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return TransportVehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      images: images ?? this.images,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
