import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/resource.dart';
import '../../services/database_service.dart';

class AllResourcesScreen extends StatefulWidget {
  @override
  State<AllResourcesScreen> createState() => _AllResourcesScreenState();
}

class _AllResourcesScreenState extends State<AllResourcesScreen> {
  late Future<List<Resource>> _resourcesFuture;
  final DatabaseService _dbService = DatabaseService();

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

  void _showAddResourceDialog() {
    final _titleController = TextEditingController();
    final _typeController = TextEditingController();
    final _urlController = TextEditingController();
    final _durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Resource'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _typeController,
                  decoration: InputDecoration(labelText: 'Type (video/guide/article)'),
                ),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(labelText: 'Resource URL'),
                ),
                TextField(
                  controller: _durationController,
                  decoration: InputDecoration(labelText: 'Duration (optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () async {
                if (_titleController.text.isNotEmpty &&
                    _typeController.text.isNotEmpty &&
                    _urlController.text.isNotEmpty) {
                  await _dbService.insertResource(
                    Resource(
                      id: '', // id will be set by the database
                      title: _titleController.text,
                      type: _typeController.text,
                      contentUrl: _urlController.text,
                      duration: _durationController.text.isNotEmpty ? _durationController.text : null,
                    ),
                  );
                  Navigator.of(context).pop();
                  _loadResources();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteResource(String id) async {
    await _dbService.deleteResource(id);
    _loadResources();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Resources'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddResourceDialog,
            tooltip: 'Add Resource',
          ),
        ],
      ),
      body: FutureBuilder<List<Resource>>(
        future: _resourcesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final resources = snapshot.data ?? [];
          if (resources.isEmpty) {
            return Center(child: Text('No resources found.'));
          }
          return ListView.builder(
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(resource.title),
                  subtitle: Text(resource.type),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteResource(resource.id),
                  ),
                  onTap: () async {
                    final url = resource.contentUrl;
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open resource link')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}