import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/book.dart';
import '../../../providers/recommendations_provider.dart';
import '../../../widgets/skeleton_loader.dart';

class BooksScreen extends ConsumerStatefulWidget {
  const BooksScreen({super.key});

  @override
  ConsumerState<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends ConsumerState<BooksScreen> {
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Kitap ara...',
                  hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                  border: InputBorder.none,
                ),
                onChanged: (q) {
                  if (q.length > 2) {
                    ref.read(bookSearchProvider.notifier).search(q);
                  }
                },
              )
            : Text('Kitaplar',
                style: AppTypography.headlineLgMobile
                    .copyWith(color: AppColors.onSurface)),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: AppColors.onSurface,
            ),
            onPressed: () {
              setState(() => _isSearching = !_isSearching);
              if (!_isSearching) {
                _searchCtrl.clear();
                ref.read(bookSearchProvider.notifier).clear();
              }
            },
          ),
        ],
      ),
      body: _isSearching ? _buildSearch() : _buildList(),
    );
  }

  Widget _buildList() {
    final booksAsync = ref.watch(booksProvider);
    return booksAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.marginMobile),
        child: SkeletonList(count: 5, cardHeight: 120),
      ),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () => ref.refresh(booksProvider),
      ),
      data: (books) => GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: AppSpacing.stackMd,
          mainAxisSpacing: AppSpacing.stackMd,
        ),
        itemCount: books.length,
        itemBuilder: (_, i) => _BookCard(book: books[i]),
      ),
    );
  }

  Widget _buildSearch() {
    final searchAsync = ref.watch(bookSearchProvider);
    return searchAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.marginMobile),
        child: SkeletonList(count: 5, cardHeight: 100),
      ),
      error: (e, _) => ErrorStateWidget(message: e.toString()),
      data: (results) => results.isEmpty
          ? Center(
              child: Text('Sonuç bulunamadı',
                  style: AppTypography.bodyMd
                      .copyWith(color: AppColors.onSurfaceVariant)))
          : GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: AppSpacing.stackMd,
                mainAxisSpacing: AppSpacing.stackMd,
              ),
              itemCount: results.length,
              itemBuilder: (_, i) => _BookCard(book: results[i]),
            ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (book.infoLink != null) {
          launchUrl(Uri.parse(book.infoLink!),
              mode: LaunchMode.externalApplication);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
              child: book.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: book.thumbnailUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(
                          color: AppColors.surfaceContainerHigh),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(Icons.menu_book_rounded,
                            color: AppColors.tertiary),
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceContainerHigh,
                      child: const Center(
                        child: Icon(Icons.menu_book_rounded,
                            color: AppColors.tertiary, size: 48),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(book.title,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          if (book.authorsString.isNotEmpty)
            Text(book.authorsString,
                style: AppTypography.labelSm
                    .copyWith(color: AppColors.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          if (book.price != null)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.tertiaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(book.price!,
                  style: AppTypography.labelCaps
                      .copyWith(color: AppColors.tertiary, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}
