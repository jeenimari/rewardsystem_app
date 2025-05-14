import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final int challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChallengeDetail();
    });
  }

  Future<void> _loadChallengeDetail() async {
    final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);
    await challengeProvider.loadChallengeDetail(widget.challengeId);
    await challengeProvider.loadMyChallenges(); // 내 챌린지 목록도 함께 로드
  }

  // 챌린지 참여 여부 확인
  bool _isParticipating() {
    final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);
    return challengeProvider.myChallenges.any((c) => c.cno == widget.challengeId);
  }

  // 챌린지 참여하기
  Future<void> _participateChallenge() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);
      final success = await challengeProvider.participateChallenge(widget.challengeId);

      if (success && mounted) {
        // 성공적으로 참여한 경우
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('챌린지에 참여했습니다!'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );

        // 챌린지 및 내 챌린지 정보 새로고침
        await _loadChallengeDetail();
      } else if (mounted) {
        // 참여 실패한 경우
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('챌린지 참여에 실패했습니다.'),
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

  @override
  Widget build(BuildContext context) {
    final challengeProvider = Provider.of<ChallengeProvider>(context);
    final challenge = challengeProvider.selectedChallenge;
    final isParticipating = _isParticipating();

    return Scaffold(
      appBar: AppBar(
        title: const Text('챌린지 상세'),
      ),
      body: challengeProvider.isLoading || challenge == null
          ? const LoadingIndicator()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 챌린지 타입 배지
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: challenge.type == 'REVIEW'
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  challenge.type == 'REVIEW' ? '리뷰 챌린지' : '게임 챌린지',
                  style: TextStyle(
                    color: challenge.type == 'REVIEW' ? Colors.blue : Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 챌린지 제목
            Text(
              challenge.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 리워드 포인트
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '리워드 포인트',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${challenge.rewardPoints}P',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 챌린지 상태
            Row(
              children: [
                Icon(
                  challenge.status == 'ACTIVE' ? Icons.play_circle_filled : Icons.pause_circle_filled,
                  color: challenge.status == 'ACTIVE' ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  '상태: ${challenge.status == 'ACTIVE' ? '진행중' : '종료됨'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: challenge.status == 'ACTIVE' ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 챌린지 내용
            Text(
              '챌린지 내용',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                challenge.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 챌린지 참여 버튼
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : isParticipating
                ? Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '이미 참여중인 챌린지입니다',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 챌린지 유형에 따라 다른 안내 제공
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '참여 방법',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (challenge.type == 'REVIEW')
                        const Text(
                          '제품에 리뷰를 작성하면 챌린지가 완료됩니다. 리뷰 작성 후 포인트를 받아보세요!',
                          style: TextStyle(height: 1.5),
                        )
                      else
                        const Text(
                          '게임에 참여하고 미션을 완료하면 챌린지가 완료됩니다. 미션 완료 후 포인트를 받아보세요!',
                          style: TextStyle(height: 1.5),
                        ),
                    ],
                  ),
                ),
              ],
            )
            : CustomButton(
              text: '챌린지 참여하기',
              icon: Icons.star,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: challenge.status == 'ACTIVE'
                  ? () {
                _participateChallenge();
              }
                  : null,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}