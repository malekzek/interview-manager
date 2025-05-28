class Resource {
  final String id;
  final String title;
  final String type;
  final String? duration;
  final String contentUrl;


  Resource({
    required this.id,
    required this.title,
    required this.type,
    this.duration,
    required this.contentUrl,
  });

  factory Resource.fromMap(Map<String, dynamic> data) {
    return Resource(
      id: data['id'].toString(),
      title: data['title'] ?? 'Untitled Resource',
      type: data['type'] ?? 'article',
      duration: data['duration'],
      contentUrl: data['content_url'],
    );
  }
}