import 'package:flutter/material.dart';
import 'package:maternal_infant_care/data/models/resource_article_model.dart';
import 'package:maternal_infant_care/presentation/pages/article_viewer_page.dart';

class ResourceCard extends StatelessWidget {
  final ResourceArticleModel article;

  const ResourceCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.6),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: article.color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => ArticleViewerPage(article: article)),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Changed to min specifically for Masonry
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: article.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(article.icon, color: article.color, size: 22),
                    ),
                    if (article.category != 'General')
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: article.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          article.category,
                          style: TextStyle(
                            color: article.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16), // Replaced Spacer to avoid unbound height issues
                Text(
                  article.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2D3142),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  article.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      article.readingTime,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
