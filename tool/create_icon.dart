import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

// 간단한 PNG 생성 (512x512, 그라데이션 배경 + 음표 모양)
// BMP 형식으로 생성 후 Flutter에서 사용

void main() {
  const size = 512;
  final pixels = Uint8List(size * size * 4); // RGBA

  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final idx = (y * size + x) * 4;
      final t = y / size; // 0.0 ~ 1.0

      // 그라데이션 배경: #6C63FF (보라) → #00BFA5 (청록)
      int r = (108 + (0 - 108) * t).round().clamp(0, 255);
      int g = (99 + (191 - 99) * t).round().clamp(0, 255);
      int b = (255 + (165 - 255) * t).round().clamp(0, 255);

      // 중앙 원 (하얀색, 반투명) - 음표 영역
      final cx = size / 2, cy = size / 2;
      final dist = sqrt(pow(x - cx, 2) + pow(y - cy, 2));

      if (dist < 160) {
        // 음표 머리 (하단 원)
        final noteX = cx - 20, noteY = cy + 40;
        final noteDist = sqrt(pow(x - noteX, 2) + pow(y - noteY, 2));
        if (noteDist < 45) {
          r = 255; g = 255; b = 255;
        }
        // 음표 줄기
        else if (x >= noteX + 35 && x <= noteX + 42 && y >= cy - 100 && y <= noteY) {
          r = 255; g = 255; b = 255;
        }
        // 음표 깃발
        else if (x >= noteX + 35 && x <= noteX + 70 && y >= cy - 100 && y <= cy - 60) {
          final flagDist = (y - (cy - 100)).abs();
          if (flagDist < 40) {
            r = 255; g = 255; b = 255;
          }
        }
        // AI 점들 (왼쪽 위, 오른쪽 아래)
        else {
          // 회로 점 1
          final d1 = sqrt(pow(x - (cx - 80), 2) + pow(y - (cy - 60), 2));
          if (d1 < 12) { r = 255; g = 215; b = 0; } // 금색 점

          // 회로 점 2
          final d2 = sqrt(pow(x - (cx + 80), 2) + pow(y - (cy + 80), 2));
          if (d2 < 12) { r = 255; g = 215; b = 0; }

          // 회로 점 3
          final d3 = sqrt(pow(x - (cx + 60), 2) + pow(y - (cy - 80), 2));
          if (d3 < 8) { r = 0; g = 255; b = 200; }

          // 회로 점 4
          final d4 = sqrt(pow(x - (cx - 70), 2) + pow(y - (cy + 70), 2));
          if (d4 < 8) { r = 0; g = 255; b = 200; }
        }
      }

      // 라운드 코너 마스킹 (원형 아이콘)
      final cornerDist = sqrt(pow(x - cx, 2) + pow(y - cy, 2));
      int a = cornerDist > 240 ? 0 : 255;

      pixels[idx] = r;
      pixels[idx + 1] = g;
      pixels[idx + 2] = b;
      pixels[idx + 3] = a;
    }
  }

  // BMP 파일 생성 (간단한 형식)
  _writePng(pixels, size, size, 'assets/icon/app_icon.png');
  print('Icon generated: assets/icon/app_icon.png');
}

void _writePng(Uint8List pixels, int w, int h, String path) {
  // 간단한 BMP 대신 raw 데이터로 저장
  // flutter_launcher_icons는 PNG를 기대하므로
  // 실제로는 간단한 TGA 형식 사용
  final file = File(path);
  file.parent.createSync(recursive: true);

  // TGA 형식 (비압축)
  final header = Uint8List(18);
  header[2] = 2; // 비압축 트루컬러
  header[12] = w & 0xFF;
  header[13] = (w >> 8) & 0xFF;
  header[14] = h & 0xFF;
  header[15] = (h >> 8) & 0xFF;
  header[16] = 32; // 32비트 (BGRA)
  header[17] = 0x28; // 상단-좌측 원점 + alpha

  // RGBA → BGRA 변환 (TGA 형식)
  final bgra = Uint8List(w * h * 4);
  for (int i = 0; i < w * h; i++) {
    bgra[i * 4] = pixels[i * 4 + 2];     // B
    bgra[i * 4 + 1] = pixels[i * 4 + 1]; // G
    bgra[i * 4 + 2] = pixels[i * 4];     // R
    bgra[i * 4 + 3] = pixels[i * 4 + 3]; // A
  }

  final output = BytesBuilder();
  output.add(header);
  output.add(bgra);

  file.writeAsBytesSync(output.toBytes());
}
