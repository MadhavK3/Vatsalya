import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:maternal_infant_care/data/models/resource_article_model.dart';

class ArticleViewerPage extends StatelessWidget {
  final ResourceArticleModel article;

  const ArticleViewerPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              article.title,
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                shadows: [
                    Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black26),
                ]
              ),
            ),
            backgroundColor: article.color,
            foregroundColor: Colors.white,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      article.color,
                      article.color.withOpacity(0.6),
                      isDark ? const Color(0xFF0F172A) : Colors.white,
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Icon(
                        article.icon,
                        size: 200,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta Data Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: article.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            article.category,
                            style: TextStyle(
                              color: article.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          article.readingTime,
                          style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Markdown Content
                    MarkdownBody(
                      data: article.content,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                        p: TextStyle(
                            fontSize: 16, 
                            height: 1.6, 
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                            fontFamily: 'Roboto', // Or default
                        ),
                        h1: TextStyle(
                            fontSize: 28, 
                            fontWeight: FontWeight.bold, 
                            color: article.color,
                            height: 1.5,
                        ),
                        h2: TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.w600, 
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.5,
                        ),
                        listBullet: TextStyle(
                            color: article.color,
                            fontSize: 16,
                        ),
                        strong: TextStyle(
                           fontWeight: FontWeight.bold,
                           color: isDark ? Colors.white : Colors.black,
                        ),
                        blockSpacing: 16,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
