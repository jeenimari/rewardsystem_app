// lib/screens/product/small_shop_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/small_shop_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product.dart';
import '../../widgets/loading_indicator.dart';
import '../../helpers/url_helper.dart';
import '../../widgets/product_card.dart';

class SmallShopScreen extends StatefulWidget {
  const SmallShopScreen({super.key});

  @override
  State<SmallShopScreen> createState() => _SmallShopScreenState();
}

class _SmallShopScreenState extends State<SmallShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final provider = Provider.of<SmallShopProvider>(context, listen: false);
        if (_tabController.index == 0) {
          provider.setShop('6ki');
        } else {
          provider.setShop('benefood');
        }
        provider.loadCurrentShopProducts();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<SmallShopProvider>(context, listen: false);
    await provider.loadCurrentShopProducts();
  }

  @override
  Widget build(BuildContext context) {
    final smallShopProvider = Provider.of<SmallShopProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.user?.role == 'ADMIN';

    // 6ki 카테고리 목록
    final List<Map<String, String>> sixkiCategories = [
      {'id': '72', 'name': '닭 가슴살'},
      {'id': '24', 'name': '소고기'},
      {'id': '25', 'name': '돼지고기'},
      {'id': '26', 'name': '과일/채소'},
    ];

    // 베네푸드 카테고리 목록
    final List<Map<String, String>> benefoodCategories = [
      {'id': '24', 'name': '닭 가슴살'},
      {'id': '25', 'name': '소고기'},
      {'id': '26', 'name': '돼지고기'},
      {'id': '27', 'name': '과일/채소'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('소규모 쇼핑몰'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '육식토끼'),
            Tab(text: '더베네푸드'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 육식토끼 탭
          _buildShopTab(
              context,
              smallShopProvider,
              sixkiCategories,
              isAdmin,
              '6ki'
          ),

          // 더베네푸드 탭
          _buildShopTab(
              context,
              smallShopProvider,
              benefoodCategories,
              isAdmin,
              'benefood'
          ),
        ],
      ),
    );
  }

  Widget _buildShopTab(
      BuildContext context,
      SmallShopProvider provider,
      List<Map<String, String>> categories,
      bool isAdmin,
      String shopType
      ) {
    final products = shopType == '6ki' ? provider.sixkiProducts : provider.benefoodProducts;

    return RefreshIndicator(
      onRefresh: () => provider.loadCurrentShopProducts(),
      child: Column(
        children: [
          // 카테고리 목록
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                      final category = categories[index];
                      final isSelected = provider.currentCategory == category['id'];

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          avatar: Icon(
                            Icons.category,
                            color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                          label: Text(
                            category['name']!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          onPressed: () {
                            provider.setCategory(category['id']!);
                            provider.loadCurrentShopProducts();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 상품 목록
          Expanded(
            child: provider.isLoading
                ? const LoadingIndicator()
                : products.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '상품이 없습니다.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildProductCard(context, product, provider, isAdmin),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
      BuildContext context,
      Product product,
      SmallShopProvider provider,
      bool isAdmin
      ) {
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
                      final success = await provider.registerExternalProduct(product);
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