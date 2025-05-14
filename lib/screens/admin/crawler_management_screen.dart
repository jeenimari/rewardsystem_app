// lib/screens/admin/crawler_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crawler_provider.dart';
import '../../models/product.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../helpers/url_helper.dart';

class CrawlerManagementScreen extends StatefulWidget {
  const CrawlerManagementScreen({super.key});

  @override
  State<CrawlerManagementScreen> createState() => _CrawlerManagementScreenState();
}

class _CrawlerManagementScreenState extends State<CrawlerManagementScreen> {
  final _searchController = TextEditingController();
  final _platformController = TextEditingController(text: 'all');
  final List<String> _platforms = ['all', 'coupang', 'naver', 'gmarket'];

  @override
  void dispose() {
    _searchController.dispose();
    _platformController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    final platform = _platformController.text;
    final crawlerProvider = Provider.of<CrawlerProvider>(context, listen: false);
    crawlerProvider.setPlatform(platform);
    await crawlerProvider.searchProducts(keyword);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final crawlerProvider = Provider.of<CrawlerProvider>(context);

    // 관리자 권한 확인
    if (authProvider.user?.role != 'ADMIN') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('권한 오류'),
        ),
        body: const Center(
          child: Text('관리자만 접근할 수 있는 화면입니다.'),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
        title: const Text('크롤링 관리'),
    ),
    body: Column(
    children: [
    // 검색 영역
    Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    '외부 사이트 제품 검색',
    style: Theme.of(context).textTheme.titleLarge,
    ),
    const SizedBox(height: 16),

    // 검색어 입력
    TextField(
    controller: _searchController,
    decoration: InputDecoration(
    labelText: '검색어',
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    ),
    ),
    const SizedBox(height: 16),

    // 플랫폼 선택 드롭다운
    DropdownButtonFormField<String>(
    value: _platformController.text,
    decoration: InputDecoration(
    labelText: '플랫폼',
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    ),
    items: _platforms.map((platform) {
    String displayName;
    switch (platform) {
    case 'coupang':
    displayName = '쿠팡';
    break;
    case 'naver':
    displayName = '네이버';
    break;
    case 'gmarket':
    displayName = 'G마켓';
    break;
    default:
    displayName = '전체';
    }
    return DropdownMenuItem<String>(
    value: platform,
    child: Text(displayName),
    );
    }).toList(),
      // lib/screens/admin/crawler_management_screen.dart (계속)
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _platformController.text = value;
          });
        }
      },
    ),
      const SizedBox(height: 16),

      // 검색 버튼
      CustomButton(
        text: '검색하기',
        icon: Icons.search,
        onPressed: _search,
        isLoading: crawlerProvider.isLoading,
      ),
    ],
    ),
    ),

      // 검색 결과
      Expanded(
        child: crawlerProvider.isLoading
            ? const LoadingIndicator()
            : crawlerProvider.searchedProducts.isEmpty
            ? const Center(
          child: Text('검색 결과가 없습니다.'),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: crawlerProvider.searchedProducts.length,
          itemBuilder: (context, index) {
            final product = crawlerProvider.searchedProducts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제품 이미지
                    if (product.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          product.imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, e, _) => Container(
                            height: 180,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported, size: 50),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),

                    // 제품명
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 가격
                    Text(
                      '가격: ${product.price}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 판매처
                    Text('판매처: ${product.vendor}'),
                    const SizedBox(height: 16),

                    // 액션 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 원본 보기 버튼
                        OutlinedButton.icon(
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('원본 보기'),
                          onPressed: () {
                            UrlHelper.openUrl(context, product.productUrl);
                            // URL 실행 기능 (url_launcher 패키지 사용)
                            // launchUrl(Uri.parse(product.productUrl));
                          },
                        ),
                        const SizedBox(width: 8),

                        // 등록 버튼
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('등록하기'),
                          onPressed: () async {
                            final success = await crawlerProvider.registerExternalProduct(product);
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('제품이 성공적으로 등록되었습니다.')),
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('제품 등록에 실패했습니다.'),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          },
                        ),
                      ],
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
    );
  }
}