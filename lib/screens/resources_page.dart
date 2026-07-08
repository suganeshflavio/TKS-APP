import 'package:flutter/material.dart';

import '../models/dashboard_content.dart';
import 'resource_detail_page.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key, required this.resources});

  final List<ResourceItem> resources;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EE),
        foregroundColor: const Color(0xFF3A1E0B),
        elevation: 0,
        title: const Text('Resources'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resources',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Color(0xFF203047),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select a resource to explore',
              style: TextStyle(fontSize: 15, color: Colors.blueGrey.shade400),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                itemCount: resources.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = resources[index];
                  final accent = _hexColor(item.accent);
                  return InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ResourceDetailPage(resource: item),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFFFDDBF)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              _resourceIcon(item.icon),
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF3A1E0B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.subtitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.brown.shade300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFFAA7751),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _resourceIcon(String key) {
  switch (key) {
    case 'notes':
      return Icons.sticky_note_2_rounded;
    case 'clipboard':
      return Icons.assignment_rounded;
    case 'book':
      return Icons.menu_book_rounded;
    case 'book-open':
      return Icons.auto_stories_rounded;
    case 'shield':
      return Icons.verified_user_rounded;
    case 'spark':
      return Icons.local_fire_department_rounded;
    default:
      return Icons.folder_open_rounded;
  }
}

Color _hexColor(String value) {
  final buffer = StringBuffer();
  if (value.length == 7) {
    buffer.write('ff');
  }
  buffer.write(value.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
