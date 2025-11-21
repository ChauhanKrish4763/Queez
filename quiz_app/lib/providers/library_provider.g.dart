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

String _$quizLibraryHash() => r'777ca8c51b94b195ce8c4353404aa6f7d55142d5';

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
