import 'package:flutter_riverpod/flutter_riverpod.dart';

// F25/F26 Mock Network State
final networkStatusProvider = NotifierProvider<NetworkStatusNotifier, bool>(() => NetworkStatusNotifier());

class NetworkStatusNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  
  void setOnline(bool online) => state = online;
}

// F24 Multi-Select State
final selectedTasksProvider = NotifierProvider<SelectedTasksNotifier, Set<String>>(() => SelectedTasksNotifier());

class SelectedTasksNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};
  
  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }
  
  void clear() => state = {};
}
