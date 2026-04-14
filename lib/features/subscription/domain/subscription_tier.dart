enum SubscriptionTier { free, standard, premium, student }

extension SubscriptionTierExt on SubscriptionTier {
  String get name {
    switch (this) {
      case SubscriptionTier.free: return '무료';
      case SubscriptionTier.standard: return '스탠다드';
      case SubscriptionTier.premium: return '프리미엄';
      case SubscriptionTier.student: return '학생 할인';
    }
  }

  String get price {
    switch (this) {
      case SubscriptionTier.free: return '₩0 / 월';
      case SubscriptionTier.standard: return '₩9,900 / 월';
      case SubscriptionTier.premium: return '₩19,900 / 월';
      case SubscriptionTier.student: return '₩4,900 / 월';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionTier.free: return '시작하기';
      case SubscriptionTier.standard: return '가장 인기';
      case SubscriptionTier.premium: return '전문가용';
      case SubscriptionTier.student: return '학생 인증 필요';
    }
  }

  List<String> get features {
    switch (this) {
      case SubscriptionTier.free:
        return ['1개 악기', '기본 AI 피드백', '제한된 곡', '커뮤니티 접근', '광고 포함'];
      case SubscriptionTier.standard:
        return ['전체 악기', '전체 AI 기능', '모든 곡', '커뮤니티 접근', '광고 제거'];
      case SubscriptionTier.premium:
        return ['스탠다드 모든 기능', '창작 도구', '고급 리포트', '우선 지원', '광고 제거'];
      case SubscriptionTier.student:
        return ['프리미엄 모든 기능', '학생 인증 할인 (57%↓)', '광고 제거', '우선 지원'];
    }
  }
}
