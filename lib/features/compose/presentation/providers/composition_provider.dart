import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../lesson/domain/models/lesson.dart';

class CompositionNotifier extends StateNotifier<List<Lesson>> {
  CompositionNotifier() : super([]);

  void addComposition(Lesson lesson) {
    state = [lesson, ...state];
  }

  void removeComposition(String id) {
    state = state.where((l) => l.id != id).toList();
  }
}

final userCompositionsProvider =
    StateNotifierProvider<CompositionNotifier, List<Lesson>>(
  (ref) => CompositionNotifier(),
);
