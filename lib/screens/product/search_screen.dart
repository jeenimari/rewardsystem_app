// lib/screens/product/search_screen.dart 수정
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewardsystem/providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_indicator.dart';
import 'product_detail_screen.dart';
import '../product/small_shop_screen.dart';

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

    // 제품 검색 (일반 검색)
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.searchProducts(query);
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

    // 카테고리 목록
    final List<String> _categories = [
      '닭가슴살', '소고기', '유제품', '기타'
    ];

    // 벤더 목록
    final List<String> _vendors = [
      '육식토끼', '더베네푸드'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('검색'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '자체 상품'),
            Tab(text: '소규모 쇼핑몰'),
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

          // 두 번째 탭: 소규모 쇼핑몰 화면
          SmallShopScreen(),
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
            message: '제품을 검색 중입니다...\n잠시만 기다려주세요.',
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
}