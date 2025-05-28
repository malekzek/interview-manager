import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/models/user.dart';

class ProfileForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final User user;
  final File? selectedImage;
  final String? tempAvatarUrl;
  final VoidCallback onImageUpload;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onSignOut;

  const ProfileForm({
    required this.formKey,
    required this.user,
    required this.selectedImage,
    required this.tempAvatarUrl,
    required this.onImageUpload,
    required this.onSave,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final currentAvatarUrl = tempAvatarUrl ?? user.avatarUrl;
    
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onWillPop: () async {
        if (!formKey.currentState!.validate()) return false;
        formKey.currentState!.save();
        return true;
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: currentAvatarUrl != null
                    ? CachedNetworkImageProvider(currentAvatarUrl)
                    : null,
                child: currentAvatarUrl == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                onPressed: onImageUpload,
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: user.name,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: const Icon(Icons.person),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            onSaved: (value) => onSave({'name': value}),
          ),
          // const SizedBox(height: 20),
          // TextFormField(
          //   initialValue: user.email,
          //   decoration: InputDecoration(
          //     labelText: 'Email',
          //     prefixIcon: const Icon(Icons.email),
          //     border: const OutlineInputBorder(),
          //     enabled: false,
          //   ),
          //   readOnly: true,
          // ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: onSignOut,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}