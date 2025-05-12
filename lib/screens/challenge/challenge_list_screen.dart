import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewardsystem/providers/auth_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../models/challenge.dart';
import '../../widgets/loading_indicator.dart';
import 'challenge_detail_screen.dart';
import 'challenge_register_screen.dart'; // 챌린지 등록 화면 import (아직 생성하지 않은 파일)

class ChallengeListScreen extends StatefulWidget {
  const ChallengeListScreen({super.key});

  @override
  State<ChallengeListScreen> createState() => _ChallengeListScreenState();
}

class _ChallengeListScreenState extends State<ChallengeListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 지연 추가하여 화면이 완전히 로드된 후 데이터 로드
    Future.delayed(Duration.zero, () {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);
    await challengeProvider.loadChallenges();
    await challengeProvider.loadMyChallenges();
  }

  @override
  Widget build(BuildContext context) {
    final challengeProvider = Provider.of<ChallengeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context); // AuthProvider 추가

    // 사용자가 관리자인지 확인 (role 필드 사용)
    final isAdmin = authProvider.user?.role == 'ADMIN';

    return Scaffold(
        appBar: AppBar(
          title: const Text('챌린지'),
           actions: [
          //관리자인 경우에만 챌린지 등록 버튼 표시
           if (isAdmin)
             IconButton(
               icon: const Icon(Icons.add),
               tooltip: '챌린지 등록',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ChallengeRegisterScreen(),
                     ),
                   ).then((_) => _loadData()); // 등록 후 데이터 새로고침
                 },
               ),
           ],

          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '전체 챌린지'),
              Tab(text: '내 챌린지'),
            ],
          ),
        ),
        body: TabBarView(
            controller: _tabController,
            children: [
            // 전체 챌린지 탭
            RefreshIndicator(
            onRefresh: () => challengeProvider.loadChallenges(),
    child: challengeProvider.isLoading
    ? const LoadingIndicator()
        : challengeProvider.allChallenges.isEmpty
    ? Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    Icons.celebration_outlined,
    size: 80,
    color: Colors.grey.shade300,
    ),
    const SizedBox(height: 16),
    Text(
    '현재 진행 중인 챌린지가 없습니다.',
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
    itemCount: challengeProvider.allChallenges.length,
    itemBuilder: (context, index) {
    final challenge = challengeProvider.allChallenges[index];
    return ChallengeCard(
    challenge: challenge,
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChallengeDetailScreen(challengeId: challenge.cno),
        ),
      ).then((_) => _loadData());
    },
    );
    },
    ),
            ),

              // 내 챌린지 탭
              RefreshIndicator(
                onRefresh: () => challengeProvider.loadMyChallenges(),
                child: challengeProvider.isLoading
                    ? const LoadingIndicator()
                    : challengeProvider.myChallenges.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_border,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '참여중인 챌린지가 없습니다.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '챌린지에 참여하여 리워드를 받아보세요!',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: challengeProvider.myChallenges.length,
                  itemBuilder: (context, index) {
                    final challenge = challengeProvider.myChallenges[index];
                    return ChallengeCard(
                      challenge: challenge,
                      isParticipating: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChallengeDetailScreen(challengeId: challenge.cno),
                          ),
                        ).then((_) => _loadData());
                      },
                    );
                  },
                ),
              ),
            ],
        ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onTap;
  final bool isParticipating;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onTap,
    this.isParticipating = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = challenge.status == 'ACTIVE';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 챌린지 타입 및 상태
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: challenge.type == 'REVIEW'
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      challenge.type == 'REVIEW' ? '리뷰 챌린지' : '게임 챌린지',
                      style: TextStyle(
                        color: challenge.type == 'REVIEW' ? Colors.blue : Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isActive ? '진행중' : '종료',
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${challenge.rewardPoints}P',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 챌린지 제목
              Text(
                challenge.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),

              // 챌린지 설명
              Text(
                challenge.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // 참여 상태 또는 참여 버튼
              if (isParticipating)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '참여중',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '자세히 보기',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}