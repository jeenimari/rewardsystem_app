import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingIndicator extends StatelessWidget {
  final bool useShimmer;
  final String? message;

  const LoadingIndicator({
    super.key,
    this.useShimmer = true,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!useShimmer) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return SingleChildScrollView( // 스크롤 가능하게 수정
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 로딩 효과
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 제목 로딩 효과
              Container(
                width: 180,
                height: 24,
                color: Colors.white,
              ),
              const SizedBox(height: 16),

              // 리스트 아이템 로딩 효과 1
              Container(
                width: double.infinity,
                height: 150,
                color: Colors.white,
              ),
              const SizedBox(height: 16),

              // 리스트 아이템 로딩 효과 2
              Container(
                width: double.infinity,
                height: 150,
                color: Colors.white,
              ),
              const SizedBox(height: 16),

              // 리스트 아이템 로딩 효과 3
              Container(
                width: double.infinity,
                height: 150,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}