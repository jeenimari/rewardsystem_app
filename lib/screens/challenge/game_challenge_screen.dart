import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

class GameChallengeScreen extends StatefulWidget {
  final int challengeId;
  final int rewardPoints;

  const GameChallengeScreen({
    super.key,
    required this.challengeId,
    required this.rewardPoints,
  });

  @override
  State<GameChallengeScreen> createState() => _GameChallengeScreenState();
}

class _GameChallengeScreenState extends State<GameChallengeScreen> {
  bool _gameStarted = false;
  bool _gameOver = false;
  bool _gameCompleted = false;
  int _score = 0;
  int _targetScore = 5; // 목표 점수
  int _remainingTime = 30; // 초 단위
  Timer? _timer;

  final List<int> _targetPositions = [];
  final Random _random = Random();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _gameOver = false;
      _gameCompleted = false;
      _score = 0;
      _remainingTime = 30;
      _targetPositions.clear();
      _addTarget();
    });

    // 타이머 시작
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _gameOver = true;
      _gameCompleted = _score >= _targetScore;
    });

    // 게임 완료 시, 백엔드에 챌린지 완료 알림 (백엔드 API 구현 필요)
    if (_gameCompleted) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('축하합니다!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('게임 챌린지를 성공적으로 완료했습니다!'),
            const SizedBox(height: 16),
            Text(
              '+${widget.rewardPoints}P',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _addTarget() {
    // 화면에 랜덤한 위치에 타겟 추가
    if (_targetPositions.length < 3) {
      setState(() {
        _targetPositions.add(_random.nextInt(9)); // 0-8 사이의 숫자로 그리드 위치 표현
      });
    }
  }

  void _tapTarget(int index) {
    if (_targetPositions.contains(index)) {
      setState(() {
        _targetPositions.remove(index);
        _score++;

        if (_score >= _targetScore) {
          _endGame();
        } else {
          _addTarget();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.uname ?? '사용자';

    return Scaffold(
      appBar: AppBar(
        title: const Text('게임 챌린지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 게임 상태 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 점수
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star),
                      const SizedBox(width: 8),
                      Text(
                        '점수: $_score/$_targetScore',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // 시간
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _remainingTime > 10
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: _remainingTime > 10 ? Colors.blue : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '시간: $_remainingTime초',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _remainingTime > 10 ? Colors.blue : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 게임 화면
            if (!_gameStarted)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.games,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '안녕하세요, $userName님!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '이 게임에서는 화면에 나타나는 파란색 버튼을 빠르게 터치해야 합니다.\n'
                          '30초 안에 5개의 버튼을 성공적으로 터치하면 게임이 완료됩니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: '게임 시작하기',
                      icon: Icons.play_arrow,
                      onPressed: _startGame,
                    ),
                  ],
                ),
              )
            else if (_gameOver)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _gameCompleted ? Icons.check_circle : Icons.cancel,
                      size: 80,
                      color: _gameCompleted
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _gameCompleted ? '게임 완료!' : '게임 오버!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _gameCompleted
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _gameCompleted
                          ? '축하합니다! $_score점을 획득했습니다.'
                          : '아쉽네요! 다시 도전해보세요. $_score점을 획득했습니다.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: '다시 시작하기',
                      icon: Icons.refresh,
                      onPressed: _startGame,
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final isTarget = _targetPositions.contains(index);

                    return GestureDetector(
                      onTap: () => _tapTarget(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isTarget
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: isTarget
                            ? const Icon(
                          Icons.touch_app,
                          color: Colors.white,
                          size: 40,
                        )
                            : null,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}