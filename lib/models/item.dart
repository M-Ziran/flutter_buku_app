class Item {
  final String title;
  final String subtitle;
  final double rating;
  final String description;
  final String image;
  final String link;

  Item({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.description,
    required this.image,
    required this.link,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      title: json['title'],
      subtitle: json['subtitle'],
      rating: (json['rating'] as num).toDouble(),
      description: json['description'],
      image: json['image'],
      link: json['link'] ?? '',
    );
  }
}
