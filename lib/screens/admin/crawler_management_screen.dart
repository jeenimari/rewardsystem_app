// lib/screens/admin/crawler_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/small_shop_provider.dart'; // small_shop_provider만 사용
import '../../models/product.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../helpers/url_helper.dart';

class CrawlerManagementScreen extends StatefulWidget {
  const CrawlerManagementScreen({super.key});

  @override
  State<CrawlerManagementScreen> createState() => _CrawlerManagementScreenState();
}

class _CrawlerManagementScreenState extends State<CrawlerManagementScreen> with SingleTickerProviderStateMixin {
  // 카테고리 컨트롤러
  final _categoryController = TextEditingController(text: '72');

  // 탭 컨트롤러
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final provider = Provider.of<SmallShopProvider>(context, listen: false);
        provider.setShop(_tabController.index == 0 ? '6ki' : 'benefood');
        _searchSmallShop();
      }
    });

    // 화면 로드 후 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchSmallShop();
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _searchSmallShop() async {
    final smallShopProvider = Provider.of<SmallShopProvider>(context, listen: false);
    final category = _categoryController.text;

    // 현재 선택된 탭에 따라 쇼핑몰 설정
    smallShopProvider.setCategory(category);
    await smallShopProvider.loadCurrentShopProducts();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final smallShopProvider = Provider.of<SmallShopProvider>(context);

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
        title: const Text('소규모 쇼핑몰 관리'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '육식토끼'),
            Tab(text: '더베네푸드'),
          ],
        ),
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
                  '카테고리로 검색',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // 카테고리 입력
                TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: '카테고리 ID',
                    hintText: _tabController.index == 0
                        ? '예: 72 (닭가슴살)'
                        : '예: 24 (닭가슴살)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // 검색 버튼
                CustomButton(
                  text: '검색하기',
                  icon: Icons.search,
                  onPressed: _searchSmallShop,
                  isLoading: smallShopProvider.isLoading,
                ),
              ],
            ),
          ),

          // 안내 메시지
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
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
                    child: Text(
                      '카테고리 ID를 입력하고 검색 버튼을 눌러 소규모 쇼핑몰의 상품을 크롤링할 수 있습니다.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 검색 결과
          Expanded(
            child: smallShopProvider.isLoading
                ? const LoadingIndicator()
                : smallShopProvider.currentProducts.isEmpty
                ? const Center(
              child: Text('검색 결과가 없습니다.'),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: smallShopProvider.currentProducts.length,
              itemBuilder: (context, index) {
                final product = smallShopProvider.currentProducts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제품 이미지
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
                        Text('판매처: ${smallShopProvider.currentShop == '6ki' ? '육식토끼' : '더베네푸드'}'),
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
                              },
                            ),
                            const SizedBox(width: 8),

                            // 등록 버튼
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('등록하기'),
                              onPressed: () async {
                                final success = await smallShopProvider.registerExternalProduct(product);
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