import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/resource.dart';
import '../../services/database_service.dart';
import 'all_resources_screen.dart';

class ResourcesSection extends StatefulWidget {
  const ResourcesSection({Key? key}) : super(key: key);

  @override
  State<ResourcesSection> createState() => _ResourcesSectionState();
}

class _ResourcesSectionState extends State<ResourcesSection> {
  late Future<List<Resource>> _resourcesFuture;
  final DatabaseService _dbService = DatabaseService();
  final ScrollController _scrollController = ScrollController(); // Add this line

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  void _loadResources() {
    setState(() {
      _resourcesFuture = _dbService.getFeaturedResources();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Resource>>(
      future: _resourcesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final resources = snapshot.data ?? [];
        return Column(
          children: [
            _buildSectionHeader(context, 'Featured Resources', 'See All'),
            const SizedBox(height: 10),
            if (resources.isEmpty)
              const _EmptyState(message: 'No featured resources available')
            else
              _buildResourcesList(resources),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () async {
            // After returning from AllResourcesScreen, reload resources
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllResourcesScreen()),
            );
            _loadResources();
          },
          child: Text(actionText),
        ),
      ],
    );
  }

  Widget _buildResourcesList(List<Resource> resources) {
    return SizedBox(
      height: 280,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 8,
        radius: const Radius.circular(16),
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: resources.length,
          itemBuilder: (context, index) => _buildResourceCard(context, resources[index]),
          separatorBuilder: (context, index) => const SizedBox(width: 16), // Adds space between cards
        ),
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, Resource resource) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResourceThumbnail(resource),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResourceType(resource),
                  const SizedBox(height: 8),
                  Text(
                    resource.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (resource.duration != null) ...[
                    const SizedBox(height: 8),
                    _buildDurationBadge(resource.duration!),
                  ],
                  const Spacer(), // This pushes the button to the bottom
                  _buildActionButton(context, resource),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceThumbnail(Resource resource) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: _getResourceColor(resource.type),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Center(
        child: Icon(
          _getResourceIcon(resource.type),
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildResourceType(Resource resource) {
    return Row(
      children: [
        Icon(
          _getResourceIcon(resource.type),
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          resource.type.toUpperCase(),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDurationBadge(String duration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        duration,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, Resource resource) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          final url = resource.contentUrl; // Make sure your Resource model has a 'link' field
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open resource link')),
            );
          }
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('View Resource'),
      ),
    );
  }

  IconData _getResourceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_circle_filled;
      case 'guide':
        return Icons.article;
      case 'article':
      default:
        return Icons.description;
    }
  }

  Color _getResourceColor(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Colors.blueAccent;
      case 'guide':
        return Colors.greenAccent;
      case 'article':
      default:
        return Colors.purpleAccent;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}