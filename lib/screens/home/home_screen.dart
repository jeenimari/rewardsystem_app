import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../auth/login_screen.dart';
import '../product/product_detail_screen.dart';
import '../product/search_screen.dart';
import '../challenge/challenge_list_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 데이터 로드
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // 로그인 상태가 아니면 로그인 화면으로 이동
    if (!authProvider.isLoggedIn) {
      return const LoginScreen();
    }

    // 하단 탭 화면들
    final List<Widget> _screens = [
      const HomeContent(),
      const SearchScreen(),
      const ChallengeListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBar.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBar.item(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBar.item(
            icon: Icon(Icons.search),
            label: '검색',
          ),
          BottomNavigationBar.item(
            icon: Icon(Icons.star),
            label: '챌린지',
          ),
          BottomNavigationBar.item(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('리워드 게임 리뷰'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // 알림 화면으로 이동 (미구현)
            },
          ),
        ],
      ),
      body: productProvider.isLoading
          ? const LoadingIndicator()
          : RefreshIndicator(
        onRefresh: () => productProvider.loadInitialData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사용자 이름과 포인트 표시
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      authProvider.user?.uname.substring(0, 1) ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '안녕하세요, ${authProvider.user?.uname ?? '사용자'}님!',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '보유 포인트: ${authProvider.user?.pointBalance ?? 0}P',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 인기 제품 섹션
              Text(
                '인기 제품',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 280,
                child: productProvider.popularProducts.isEmpty
                    ? const Center(child: Text('인기 제품이 없습니다.'))
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productProvider.popularProducts.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.popularProducts[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SizedBox(
                        width: 180,
                        child: ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(productId: product.id),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 최근 제품 섹션
              Text(
                '최근 등록된 제품',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              productProvider.recentProducts.isEmpty
                  ? const Center(child: Text('최근 등록된 제품이 없습니다.'))
                  : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: productProvider.recentProducts.length,
                itemBuilder: (context, index) {
                  final product = productProvider.recentProducts[index];
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
            ],
          ),
        ),
      ),
    );
  }
}