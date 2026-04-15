import 'dart:async';

import 'package:zocar/helpers/devlog.dart';
import 'package:flutter/material.dart';

Future<T?> safeRun<T>({
  required String name,
  required FutureOr<T> Function() tryBlock,
  T Function(Object e)? errorHandler,
  bool isEnabled = true,
  bool logEnabled = true,
}) async {
  if (!isEnabled) {
    if (logEnabled && GlobalConfig.showDevLog) {
      debugPrint('⏭️ Skipped execution of "$name" (disabled)');
    }
    // Return a default value or error result when disabled
    if (errorHandler == null) {
      return null;
    } else {
      return errorHandler(Exception('Function disabled: $name'));
    }
  }
  if (GlobalConfig.removeTryCatch) {
    if (logEnabled && GlobalConfig.showDevLog) {
      debugPrint('▶️ Executing "$name" without try-catch');
    }
    final stopwatch = Stopwatch()..start();
    final result = await tryBlock();
    stopwatch.stop();

    if (logEnabled && GlobalConfig.showDevLog) {
      debugPrint('✅ Completed "$name" in ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
    }

    return result;
  }

  try {
    if (logEnabled && GlobalConfig.showDevLog) {
      debugPrint('▶️ Starting "$name"');
    }

    final stopwatch = Stopwatch()..start();
    final result = await tryBlock();
    stopwatch.stop();

    if (logEnabled && GlobalConfig.showDevLog) {
      debugPrint('✅ Completed "$name" in ${(stopwatch.elapsedMilliseconds/1000).toStringAsFixed(2)}s');
    }

    return result;
  } catch (e) {
    if (logEnabled && GlobalConfig.showDevErrorLog) {
      debugPrint('❌ Error in "$name": $e');
    }

    if (errorHandler == null) {
      return null;
    } else {
      return errorHandler(e);
    }
  }
}