import 'package:flutter/widgets.dart';

import 'parent_app_state.dart';

class ParentScope extends InheritedNotifier<ParentAppState> {
  const ParentScope({
    required ParentAppState state,
    required super.child,
    super.key,
  }) : super(notifier: state);

  static ParentAppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ParentScope>();
    assert(scope != null, 'ParentScope not found');
    return scope!.notifier!;
  }
}
