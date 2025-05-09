class Challenge {
  final int cno;
  final String title;
  final String content;
  final String type;
  final int rewardPoints;
  final String status;

  Challenge({
    required this.cno,
    required this.title,
    required this.content,
    required this.type,
    required this.rewardPoints,
    required this.status,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      cno: json['cno'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      rewardPoints: json['rewardPoints'],
      status: json['status'],
    );
  }
}