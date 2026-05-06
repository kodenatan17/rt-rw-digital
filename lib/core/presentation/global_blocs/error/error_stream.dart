import 'dart:async';

import 'package:pasconnect/core/presentation/global_blocs/error/error_enum.dart';

class ErrorEvent {
  final ErrorTypeEnum type;
  final String? message;
  
  ErrorEvent(this.type, this.message);
}

StreamController<ErrorEvent> globalErrorStreamController =
    StreamController<ErrorEvent>.broadcast();
