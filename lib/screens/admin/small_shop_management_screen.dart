// lib/screens/admin/small_shop_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/small_shop_provider.dart';
import '../../models/product.dart';
import '../../widgets/loading_indicator.dart';
import '../../helpers/url_helper.dart';

class SmallShopManagementScreen extends StatefulWidget {
  const SmallShopManagementScreen({super.key});

  @override
  State<SmallShopManagementScreen> createState() => _SmallShopManagementScreenState();
}

class _SmallShopManagementScreenState extends State<SmallShopManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _categoryControllers = {
    '6ki': TextEditingController(text: '72'),
    'benefood': TextEditingController(text: '24'),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final provider = Provider.of<SmallShopProvider>(context, listen: false);
        if (_tabController.index == 0) {
          provider.setShop('6ki');
          provider.setCategory(_categoryControllers['6ki']!.text);
        } else {
          provider.setShop('benefood');
          provider.setCategory(_categoryControllers['benefood']!.text);
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
    _categoryControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<SmallShopProvider>(context, listen: false);
    await provider.loadCurrentShopProducts();
  }

  Future<void> _searchProducts(String shopType) async {
    final provider = Provider.of<SmallShopProvider>(context, listen: false);
    final category = _categoryControllers[shopType]!.text;

    provider.setCategory(category);
    await provider.loadCurrentShopProducts();
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // 육식토끼 탭
          _buildShopTab(context, smallShopProvider, '6ki'),

          // 더베네푸드 탭
          _buildShopTab(context, smallShopProvider, 'benefood'),
        ],
      ),
    );
  }

  Widget _buildShopTab(
      BuildContext context,
      SmallShopProvider provider,
      String shopType
      ) {
    final products = shopType == '6ki' ? provider.sixkiProducts : provider.benefoodProducts;

    return Column(
        children: [
    // 카테고리 입력 및 검색 버튼
    Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
    children: [
    Expanded(
    child: TextField(
    controller: _categoryControllers[shopType],
    decoration: InputDecoration(
    labelText: '카테고리 ID',
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    hintText: shopType == '6ki' ? '예: 72 (닭가슴살)' : '예: 24 (닭가슴살)',
    ),
    keyboardType: TextInputType.number,
    ),
    ),
    const SizedBox(width: 16),
    ElevatedButton(
    onPressed: () => _searchProducts(shopType),
    child: const Text('검색'),
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
    '카테고리 ID를 입력하고 검색 버튼을 눌러 상품을 검색할 수 있습니다.',
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
      Text('판매처: ${shopType == '6ki' ? '육식토끼' : '더베네푸드'}'),
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
              final success = await provider.registerExternalProduct(product);
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
    );
  }
}