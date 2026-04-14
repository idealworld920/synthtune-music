sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = '네트워크 연결을 확인해주세요.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = '인증에 실패했습니다.']);
}

class AudioFailure extends Failure {
  const AudioFailure([super.message = '오디오 처리 중 오류가 발생했습니다.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = '마이크 권한이 필요합니다.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = '서버 오류가 발생했습니다.']);
}
