import 'dart:math';

const double kHeaderHeight = 170.0;
const double kRowHeight = 150.0;
const double kSealSize = 90.0;
const int kTotalLevels = 100;

int getRowForLevel(int level) {
  int group = (level - 1) ~/ 3;
  int rem = (level - 1) % 3;
  return group * 2 + (rem == 0 ? 1 : 2);
}

int getTotalRows(int totalLevels) => getRowForLevel(totalLevels);

double getNodeX(int level, double screenWidth) {
  int rem = (level - 1) % 3;
  final double center = screenWidth * 0.5;
  final double amp = screenWidth * 0.28;
  if (rem == 0) return center;
  if (rem == 1) return center - amp;
  return center + amp;
}

double getNodeY(int level) {
  int row = getRowForLevel(level);
  return kHeaderHeight + (row - 0.5) * kRowHeight;
}