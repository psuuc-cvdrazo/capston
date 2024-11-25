class CollectionPoint {
  final String cpName;
  final String cpAddress;
  final double cpLat;
  final double cpLong;
  final String imageUrl;

  CollectionPoint({
    required this.cpName,
    required this.cpAddress,
    required this.cpLat,
    required this.cpLong,
    required this.imageUrl,
  });

  factory CollectionPoint.fromJson(Map<String, dynamic> json) {
    return CollectionPoint(
      cpName: json['cp_name'],
      cpAddress: json['cp_address'],
      cpLat: json['cp_lat'].toDouble(),
      cpLong: json['cp_long'].toDouble(),
      imageUrl: json['image_url'],
    );
  }
}