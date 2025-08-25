import 'dart:math';

class CreateChannel {
  CreateChannel._privateConstructor();
  static final CreateChannel _instance = CreateChannel._privateConstructor();

  factory CreateChannel() {
    return _instance;
  }

  //ex 1000075343
  String createChannelId() {
    final now = DateTime.now(); // 현재 시간 가져오기
    final random = Random();
    final randomValue = random.nextInt(10); // 0~10 사이의 랜덤 값 생성

    // 현재 시간과 랜덤 값을 문자열로 결합
    final uniqueString =
        '${(now.hour).toString().padLeft(2, '0')}${(now.minute).toString().padLeft(2, '0')}${(now.second).toString().padLeft(2, '0')}${(now.millisecond).toString().padLeft(3, '0')}$randomValue';

    return uniqueString;
  }
}
