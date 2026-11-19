import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/detail_controller.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import '../widgets/news_image.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final article = controller.article;

    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderRose, height: 1),
        ),
        title: const Text(
          'Artikel',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.deepBerry,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.author != null)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softBlush,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  article.author!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: AppColors.primaryRose,
                  ),
                ),
              ),
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  DateFormatter.formatDate(article.publishedAt),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (article.urlToImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: NewsImage(url: article.urlToImage!, height: 230),
              ),
              const SizedBox(height: 20),
            ],
            if (article.description != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.softBlush,
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(
                    left: BorderSide(color: AppColors.primaryRose, width: 3.5),
                  ),
                ),
                child: Text(
                  article.description!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
            if (article.content != null)
              Text(
                article.content!,
                style: const TextStyle(
                  fontSize: 15.5,
                  color: AppColors.textSecondary,
                  height: 1.7,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
