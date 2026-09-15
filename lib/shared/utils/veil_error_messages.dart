import 'dart:convert';

import 'package:veil_mobile/shared/constants/app_strings.dart';

/// Maps exceptions to user-facing, localization-ready messages.
abstract final class VeilErrorMessages {
  static String fromException(Object error) {
    if (error is FormatException) {
      final message = error.message.trim();
      if (message.isNotEmpty) {
        return message;
      }
      return AppStrings.importInvalidJson;
    }

    if (error is JsonUnsupportedObjectError || error is TypeError) {
      return AppStrings.importInvalidJson;
    }

    if (error is StateError) {
      return error.message;
    }

    return AppStrings.storageUnknownError;
  }
}
