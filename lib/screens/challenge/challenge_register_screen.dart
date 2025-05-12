import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/challenge_provider.dart';
import '../../models/challenge.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ChallengeRegisterScreen extends StatefulWidget {
  const ChallengeRegisterScreen({super.key});

  @override
  State<ChallengeRegisterScreen> createState() => _ChallengeRegisterScreenState();
}

class _ChallengeRegisterScreenState extends State<ChallengeRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _rewardPointsController = TextEditingController();
  String _selectedType = 'REVIEW'; // 기본값
  String _selectedStatus = 'ACTIVE'; // 기본값
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _rewardPointsController.dispose();
    super.dispose();
  }

  Future<void> _registerChallenge() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);

        // 챌린지 객체 생성
        final challenge = Challenge(
          cno: 0, // 백엔드에서 자동 생성
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          type: _selectedType,
          rewardPoints: int.parse(_rewardPointsController.text.trim()),
          status: _selectedStatus,
        );

        // 챌린지 등록 API 호출
        final success = await challengeProvider.registerChallenge(challenge);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('챌린지가 성공적으로 등록되었습니다.')),
          );

          // 이 부분 추가: 챌린지 목록 새로고침
          await challengeProvider.loadChallenges();

          Navigator.of(context).pop();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('챌린지 등록에 실패했습니다.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('챌린지 등록'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 입력
              const Text(
                '챌린지 제목',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _titleController,
                hintText: '챌린지 제목을 입력하세요',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 내용 입력
              const Text(
                '챌린지 내용',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _contentController,
                hintText: '챌린지 내용을 입력하세요',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '내용을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 챌린지 유형 선택
              const Text(
                '챌린지 유형',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'REVIEW',
                    child: Text('리뷰 챌린지'),
                  ),
                  DropdownMenuItem(
                    value: 'GAME',
                    child: Text('게임 챌린지'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 리워드 포인트 입력
              const Text(
                '리워드 포인트',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _rewardPointsController,
                hintText: '지급할 포인트를 입력하세요',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '포인트를 입력해주세요';
                  }
                  if (int.tryParse(value) == null) {
                    return '숫자만 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 상태 선택
              const Text(
                '챌린지 상태',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'ACTIVE',
                    child: Text('활성화'),
                  ),
                  DropdownMenuItem(
                    value: 'INACTIVE',
                    child: Text('비활성화'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),

              // 등록 버튼
              CustomButton(
                text: '챌린지 등록하기',
                icon: Icons.add_circle,
                onPressed: _isLoading ? null : _registerChallenge,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}