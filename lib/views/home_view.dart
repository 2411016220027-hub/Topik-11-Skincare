import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/article_model.dart';
import '../routes/app_routes.dart';
import '../services/news_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final NewsApiService _service = NewsApiService();

  static const Map<String, String> _topics = {
    '("skincare routine" OR "skin care") NOT acne NOT sunscreen':
        'Skincare Routine',
    '(sunscreen OR SPF) AND skin NOT acne': 'Sunscreen & SPF',
    '(acne OR breakout OR pimple) AND skincare': 'Acne Care',
    '(retinol OR niacinamide OR "hyaluronic acid" OR serum) AND skin':
        'Ingredients',
    '(dermatologist OR "K-beauty" OR "Korean skincare") AND skin':
        'K-Beauty & Tips',
  };

  late String _selectedQuery;
  final Map<String, Future<List<ArticleModel>>> _cache = {};
  late Future<List<ArticleModel>> _futureNews;

  @override
  void initState() {
    super.initState();
    _selectedQuery = _topics.keys.first;
    _futureNews = _ambilAtauDariCache(_selectedQuery);
  }

  Future<List<ArticleModel>> _ambilAtauDariCache(String query) {
    return _cache.putIfAbsent(query, () => _service.searchNews(query));
  }

  void _muatUlang() {
    setState(() {
      _cache[_selectedQuery] = _service.searchNews(_selectedQuery);
      _futureNews = _cache[_selectedQuery]!;
    });
  }

  void _gantiTopik(String query) {
    if (query == _selectedQuery) return;
    setState(() {
      _selectedQuery = query;
      _futureNews = _ambilAtauDariCache(_selectedQuery);
    });
  }

  Future<void> _onRefresh() async {
    _muatUlang();
    try {
      await _futureNews;
    } catch (_) {}
  }

  void _bukaDialogCari() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.spa_outlined, color: AppColors.primaryRose),
            SizedBox(width: 8),
            Text(
              'Cari Berita Skincare',
              style: TextStyle(color: AppColors.deepBerry, fontSize: 18),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Contoh: retinol, sunscreen, serum...',
            filled: true,
            fillColor: AppColors.softBlush,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            final keyword = value.trim();
            if (keyword.isEmpty) return;
            Navigator.pop(context);
            Get.toNamed(AppRoutes.search, arguments: keyword);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryRose,
              shape: const StadiumBorder(),
            ),
            onPressed: () {
              final keyword = controller.text.trim();
              if (keyword.isEmpty) return;
              Navigator.pop(context);
              Get.toNamed(AppRoutes.search, arguments: keyword);
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderRose, height: 1),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.spa_rounded, color: AppColors.primaryRose, size: 22),
            SizedBox(width: 8),
            Text(
              'GlowDaily',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.deepBerry,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.deepBerry),
            tooltip: 'Cari Berita Skincare',
            onPressed: _bukaDialogCari,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTopicChips(),
          Expanded(
            child: FutureBuilder<List<ArticleModel>>(
              future: _futureNews,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRose,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: _muatUlang,
                  );
                }

                final articles = snapshot.data ?? [];
                if (articles.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.spa_outlined,
                          size: 52,
                          color: AppColors.primaryRose,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Belum ada berita skincare untuk topik ini.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primaryRose,
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return ArticleCard(
                        article: article,
                        onTap: () =>
                            Get.toNamed(AppRoutes.detail, arguments: article),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicChips() {
    return Container(
      height: 58,
      color: AppColors.background,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        itemCount: _topics.length,
        itemBuilder: (context, index) {
          final query = _topics.keys.elementAt(index);
          final isSelected = query == _selectedQuery;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _gantiTopik(query),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.deepBerry : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.deepBerry
                        : AppColors.borderRose,
                  ),
                ),
                child: Text(
                  _topics[query]!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
