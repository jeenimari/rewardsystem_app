class UserChallenge {
  final int id;
  final int userId;
  final int challengeId;
  final bool completed;
  final bool rewarded;
  final String status;
  final String? userName;
  final String? challengeTitle;
  final String? challengeType;
  final int? rewardPoints;

  UserChallenge({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.completed,
    required this.rewarded,
    required this.status,
    this.userName,
    this.challengeTitle,
    this.challengeType,
    this.rewardPoints,
  });

  factory UserChallenge.fromJson(Map<String, dynamic> json) {
    return UserChallenge(
      id: json['id'],
      userId: json['userId'],
      challengeId: json['challengeId'],
      completed: json['completed'],
      rewarded: json['rewarded'],
      status: json['status'],
      userName: json['userName'],
      challengeTitle: json['challengeTitle'],
      challengeType: json['challengeType'],
      rewardPoints: json['rewardPoints'],
    );
  }
}