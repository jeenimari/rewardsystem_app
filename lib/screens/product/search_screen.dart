// lib/screens/product/search_screen.dart 수정
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewardsystem/providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/crawler_provider.dart'; // 추가
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_indicator.dart';
import 'product_detail_screen.dart';
import '../../helpers/url_helper.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    if (_currentTabIndex == 0) {
      // 일반 검색
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      await productProvider.searchProducts(query);
    } else {
      // 외부 사이트 크롤링 검색
      final crawlerProvider = Provider.of<CrawlerProvider>(context, listen: false);
      await crawlerProvider.searchProducts(query);
    }
  }

  Future<void> _searchByCategory(String category) async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.searchByCategory(category);
  }

  Future<void> _searchByVendor(String vendor) async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.searchByVendor(vendor);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final crawlerProvider = Provider.of<CrawlerProvider>(context);

    // 카테고리 목록
    final List<String> _categories = [
      '전자제품', '의류', '식품', '가구', '도서', '뷰티', '스포츠', '장난감', '기타'
    ];

    // 벤더 목록
    final List<String> _vendors = [
      '쿠팡', '네이버', '11번가', 'G마켓', '옥션', '인터파크', '위메프', '티몬'
    ];

    // 플랫폼 목록 (크롤링용)
    final List<Map<String, String>> _platforms = [
      {'name': '전체', 'value': 'all'},
      {'name': '쿠팡', 'value': 'coupang'},
      {'name': '네이버', 'value': 'naver'},
      {'name': 'G마켓', 'value': 'gmarket'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('검색'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '자체 상품'),
            Tab(text: '외부 사이트'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 첫 번째 탭: 기존 검색 기능
          _buildRegularSearchTab(
              productProvider,
              _categories,
              _vendors
          ),

          // 두 번째 탭: 크롤링 검색 기능
          _buildCrawlerSearchTab(
              crawlerProvider,
              _platforms
          ),
        ],
      ),
    );
  }

  // 일반 검색 탭 UI
  Widget _buildRegularSearchTab(
      ProductProvider productProvider,
      List<String> categories,
      List<String> vendors,
      ) {
    return Column(
      children: [
        // 검색 바
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '제품 검색',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _search(),
          ),
        ),

        // 카테고리 목록
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '카테고리',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        avatar: Icon(
                          Icons.category,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                        label: Text(categories[index]),
                        onPressed: () => _searchByCategory(categories[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 벤더 목록
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '판매처',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vendors.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        avatar: Icon(
                          Icons.store,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 16,
                        ),
                        label: Text(vendors[index]),
                        onPressed: () => _searchByVendor(vendors[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 검색 결과
        Expanded(
          child: productProvider.isLoading
              ? const LoadingIndicator(
            useShimmer: false,
            message: '외부 사이트 제품을 검색 중입니다...\n잠시만 기다려주세요.',
          )
              : productProvider.allProducts.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  '검색 결과가 없습니다',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: productProvider.allProducts.length,
            itemBuilder: (context, index) {
              final product = productProvider.allProducts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ProductCard(
                  product: product,
                  isHorizontal: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(productId: product.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 크롤링 검색 탭 UI
  Widget _buildCrawlerSearchTab(
      CrawlerProvider crawlerProvider,
      List<Map<String, String>> platforms,
      ) {
    return Column(
      children: [
        // 검색 바
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '외부 사이트 제품 검색',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _search(),
          ),
        ),

        // 플랫폼 선택
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '검색 플랫폼',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: platforms.length,
                  itemBuilder: (context, index) {
                    final platform = platforms[index];
                    final isSelected = crawlerProvider.currentPlatform == platform['value'];

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        avatar: Icon(
                          Icons.public,
                          color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                        label: Text(
                          platform['name']!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () {
                          crawlerProvider.setPlatform(platform['value']!);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

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
                    '외부 사이트 검색은 실시간 크롤링으로 진행되며, 시간이 다소 걸릴 수 있습니다.',
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

        // 검색 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('검색하기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _search(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 검색 결과
        Expanded(
          child: crawlerProvider.isLoading
              ? const LoadingIndicator()
              : crawlerProvider.searchedProducts.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  '검색어를 입력하여 외부 사이트 제품을 검색해보세요',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: crawlerProvider.searchedProducts.length,
            itemBuilder: (context, index) {
              final product = crawlerProvider.searchedProducts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildExternalProductCard(context, product, crawlerProvider),
              );
            },
          ),
        ),
      ],
    );
  }

  // 외부 제품 카드 (등록 기능 포함)
  Widget _buildExternalProductCard(BuildContext context, Product product, CrawlerProvider crawlerProvider) {
    final isAdmin = Provider.of<AuthProvider>(context).user?.role == 'ADMIN';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 제품 카드
          ProductCard(
            product: product,
            isHorizontal: true,
            onTap: () {
              UrlHelper.openUrl(context, product.productUrl);
              // 외부 링크로 이동하는 기능 구현 필요
              // url_launcher 패키지 사용 권장
            },
          ),

          // 관리자인 경우 등록 버튼 표시
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('자체 상품으로 등록'),
                    onPressed: () async {
                      final success = await crawlerProvider.registerExternalProduct(product);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('상품이 성공적으로 등록되었습니다.')),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('상품 등록에 실패했습니다.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}