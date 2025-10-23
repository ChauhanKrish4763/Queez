// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for bottom navbar selected index

@ProviderFor(BottomNavIndex)
const bottomNavIndexProvider = BottomNavIndexProvider._();

/// Provider for bottom navbar selected index
final class BottomNavIndexProvider
    extends $NotifierProvider<BottomNavIndex, int> {
  /// Provider for bottom navbar selected index
  const BottomNavIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bottomNavIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bottomNavIndexHash();

  @$internal
  @override
  BottomNavIndex create() => BottomNavIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$bottomNavIndexHash() => r'0b05161dbc35d80a1fcb8889b37f8963ef23441e';

/// Provider for bottom navbar selected index

abstract class _$BottomNavIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for tracking previous navigation index

@ProviderFor(PreviousNavIndex)
const previousNavIndexProvider = PreviousNavIndexProvider._();

/// Provider for tracking previous navigation index
final class PreviousNavIndexProvider
    extends $NotifierProvider<PreviousNavIndex, int> {
  /// Provider for tracking previous navigation index
  const PreviousNavIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'previousNavIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$previousNavIndexHash();

  @$internal
  @override
  PreviousNavIndex create() => PreviousNavIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$previousNavIndexHash() => r'3e8ad52d4c43b3d4d6879b991d1ed44f0d4a9acb';

/// Provider for tracking previous navigation index

abstract class _$PreviousNavIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
