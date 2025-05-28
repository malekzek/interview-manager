import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<User?>(
      builder: (context, user, _) {
        final name = user?.name ?? "User";
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'hello, $name! 👋',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              '"Success is where preparation and opportunity meet."',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        );
      },
    );
  }
}