import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// This is the entrypoint of our custom linter
PluginBase createPlugin() => _ExampleLinter();

/// A plugin class is used to list all the assists/lints defined by a plugin.
class _ExampleLinter extends PluginBase {
  /// We list all the custom warnings/infos/errors
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    return [
      PreferAbsoluteImportRule(),
    ];
  }
}

class PreferAbsoluteImportRule extends DartLintRule {
  PreferAbsoluteImportRule() : super(code: _code);

  static const _code = LintCode(
    name: 'prefer_absolute_import',
    problemMessage: 'Prefer absolute imports for local files.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final packageName = context.pubspec.name;

    context.registry.addImportDirective((node) {
      final uri = node.uri.stringValue;
      if (uri?.startsWith('package:$packageName/') == true) {
        reporter.reportErrorForNode(
          _code,
          // LintCode(name: 'fdafa', problemMessage: 'fds ${node.}'),
          node,
        );
      }
    });
  }

  @override
  List<Fix> getFixes() => [_MakeAbsoluteImportFix()];
}

class _MakeAbsoluteImportFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addImportDirective((node) {
      // We verify that the variable declaration is where our warning is located
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      // We define one edit, giving it a message which will show-up in the IDE.
      final changeBuilder = reporter.createChangeBuilder(
        message: 'Convert to absolute import',
        priority: 1,
      );

      changeBuilder.addDartFileEdit((builder) {
        final nodeKeyword = node.toSource();

        final p = 'package:${context.pubspec.name}';
        final i = nodeKeyword.indexOf(p);
        builder.addSimpleReplacement(
          SourceRange(i, p.length),
          '',
        );
      });
    });
  }
}
