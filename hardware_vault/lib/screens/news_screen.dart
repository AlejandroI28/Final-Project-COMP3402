import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _filter = 'All';
  final _categories = ['All', 'GPU', 'CPU', 'Memory', 'Event'];

  List<NewsArticle> get _filtered {
    if (_filter == 'All') return mockNews;
    return mockNews.where((n) => n.category == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final featured = _filtered.isNotEmpty ? _filtered.first : null;
    final rest = _filtered.length > 1 ? _filtered.sublist(1) : <NewsArticle>[];

    return CustomScrollView(
      slivers: [
        // ── Header ─────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 56, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.rss_feed_rounded,
                      color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Noticias',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary)),
                    Text('Hardware & Tecnología',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ),
        // ── Category Filter ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                final sel = cat == _filter;
                return GestureDetector(
                  onTap: () => setState(() => _filter = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppTheme.primary.withOpacity(0.15)
                          : AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              sel ? AppTheme.primary : AppTheme.border),
                    ),
                    child: Text(cat,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: sel
                                ? AppTheme.primary
                                : AppTheme.textSecondary)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // ── Featured ───────────────────────────────────────────────────────
        if (featured != null)
          SliverToBoxAdapter(
            child: _FeaturedCard(article: featured),
          ),
        // ── Rest ───────────────────────────────────────────────────────────
        if (rest.isEmpty && featured == null)
          const SliverFillRemaining(
            child: Center(
              child: Text('No hay noticias en esta categoría',
                  style:
                      TextStyle(color: AppTheme.textMuted, fontSize: 14)),
            ),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _NewsCard(article: rest[i]),
            childCount: rest.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

// ─── Featured Card ────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final NewsArticle article;

  const _FeaturedCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryDeep,
            AppTheme.surfaceCard,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (article.isBreaking)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bolt_rounded,
                            size: 12, color: Colors.white),
                        SizedBox(width: 2),
                        Text('BREAKING',
                            style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                if (article.isBreaking) const SizedBox(width: 8),
                _CategoryChip(category: article.category),
                const Spacer(),
                Text(
                  timeago.format(article.publishedAt, locale: 'es'),
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Center(
                child: Icon(Icons.newspaper_rounded,
                    size: 50, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 14),
            Text(article.title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    height: 1.3)),
            const SizedBox(height: 8),
            Text(article.summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.source_rounded,
                    size: 12, color: AppTheme.primary),
                const SizedBox(width: 4),
                Text(article.source,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── News Card ────────────────────────────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  final NewsArticle article;

  const _NewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Icon(Icons.article_rounded,
                color: AppTheme.primary, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CategoryChip(category: article.category),
                    const Spacer(),
                    Text(
                      timeago.format(article.publishedAt, locale: 'es'),
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.3)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.source_rounded,
                        size: 10, color: AppTheme.primary),
                    const SizedBox(width: 3),
                    Text(article.source,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Chip ────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  Color get _color {
    switch (category) {
      case 'GPU':
        return AppTheme.nvidiaGreen;
      case 'CPU':
        return AppTheme.intelBlue;
      case 'Memory':
        return Colors.purple;
      case 'Event':
        return Colors.orange;
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(category,
          style: TextStyle(
              color: _color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5)),
    );
  }
}
