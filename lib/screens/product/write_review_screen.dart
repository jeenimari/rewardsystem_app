import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../providers/product_provider.dart';
import '../../providers/review_provider.dart';
import '../../models/review.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

class WriteReviewScreen extends StatefulWidget {
  final int productId;
  final Review? existingReview; // 수정 시 사용

  const WriteReviewScreen({
    super.key,
    required this.productId,
    this.existingReview,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  double _rating = 5.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.existingReview != null) {
      _contentController.text = widget.existingReview!.rcontent;
      _rating = widget.existingReview!.rating.toDouble();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        bool success;

        if (widget.existingReview != null) {
          // 리뷰 수정
          final updatedReview = Review(
            id: widget.existingReview!.id,
            userId: authProvider.user!.email,
            productId: widget.productId,
            rcontent: _contentController.text.trim(),
            rating: _rating.toInt(),
            rewarded: widget.existingReview!.rewarded,
          );

          success = await reviewProvider.updateReview(updatedReview);
        } else {
          // 새 리뷰 작성
          final newReview = Review(
            id: 0, // 백엔드에서 자동 생성
            userId: authProvider.user!.email,
            productId: widget.productId,
            rcontent: _contentController.text.trim(),
            rating: _rating.toInt(),
            rewarded: false,
          );

          success = await reviewProvider.createReview(newReview);
        }

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.existingReview != null ? '리뷰가 수정되었습니다.' : '리뷰가 등록되었습니다.'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
          Navigator.of(context).pop();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.existingReview != null ? '리뷰 수정에 실패했습니다.' : '리뷰 등록에 실패했습니다.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('오류가 발생했습니다: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final product = productProvider.selectedProduct;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingReview != null ? '리뷰 수정' : '리뷰 작성'),
      ),
      body: _isLoading
          ? const LoadingIndicator(useShimmer: false)
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제품 정보
              if (product != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        if (product.imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.price,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // 별점 입력
              Text(
                '평점',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 리뷰 내용 입력
              Text(
                '리뷰 내용',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _contentController,
                hintText: '제품에 대한 솔직한 리뷰를 작성해주세요.',
                maxLines: 5,
                maxLength: 500,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '리뷰 내용을 입력해주세요.';
                  }
                  if (value.length < 10) {
                    return '리뷰 내용은 최소 10자 이상 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 리워드 안내
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '리워드 포인트 안내',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '작성한 리뷰는 관리자 검토 후 포인트가 지급됩니다.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 제출 버튼
              CustomButton(
                text: widget.existingReview != null ? '리뷰 수정하기' : '리뷰 등록하기',
                icon: widget.existingReview != null ? Icons.edit : Icons.check,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                onPressed: _submitReview,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}