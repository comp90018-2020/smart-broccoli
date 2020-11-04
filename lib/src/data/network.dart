import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/remote.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';

class NetworkExceptionsHandler {
  void handle(e, BuildContext context) {
    print(e);
    if (e is CannotResolveServerAddressException)
      _cannotResolveServerAddress(context);
    else if (e is ConnetionRefusedException)
      _connectionRefused(context);
    else if (e is AccessDeniedException)
      _handleAccessDenied(context);
    else if (e is UnauthorisedRequestException)
      _handleUnauthorised(context);
    else if (e is ForbiddenRequestException)
      _handleForbidden(context);
    else
      _handleUnknown(context);
  }

  _cannotResolveServerAddress(BuildContext context) {
    showErrSnackBar(context, "Cannot resolve server address.");
  }

  _connectionRefused(BuildContext context) {
    showErrSnackBar(context, "Connection refused.");
  }

  _handleAccessDenied(BuildContext context) {
    showErrSnackBar(context, "You don't have access to the server.");
  }

  _handleUnauthorised(BuildContext context) {
    showErrSnackBar(context, "Unauthorised");
  }

  _handleForbidden(BuildContext context) {
    showErrSnackBar(context, "Forbidden");
  }

  _handleUnknown(BuildContext context) {
    showErrSnackBar(context, "Unknown network error happended.");
  }
}

/// Network exception
class NetworkException implements Exception {}

/// Exception thrown when server cannot by connected by any network issue
class ConnetionRefusedException implements NetworkException {}

/// Exception thrown when server cannot by connected by any network issue
class CannotResolveServerAddressException implements NetworkException {}

/// Exception thrown when request is invalid
class AccessDeniedException implements NetworkException {}

/// Other exceptions that will not be handled
class UnknowException implements NetworkException {}
