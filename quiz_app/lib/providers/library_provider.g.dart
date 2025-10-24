// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for quiz library items

@ProviderFor(QuizLibrary)
const quizLibraryProvider = QuizLibraryProvider._();

/// Provider for quiz library items
final class QuizLibraryProvider
    extends $AsyncNotifierProvider<QuizLibrary, List<QuizLibraryItem>> {
  /// Provider for quiz library items
  const QuizLibraryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quizLibraryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quizLibraryHash();

  @$internal
  @override
  QuizLibrary create() => QuizLibrary();
}

String _$quizLibraryHash() => r'f9ea5d4f12bb382dcefc3e85ac49addb16dde72f';

/// Provider for quiz library items

abstract class _$QuizLibrary extends $AsyncNotifier<List<QuizLibraryItem>> {
  FutureOr<List<QuizLibraryItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<QuizLibraryItem>>, List<QuizLibraryItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<QuizLibraryItem>>,
                List<QuizLibraryItem>
              >,
              AsyncValue<List<QuizLibraryItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
