import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/remote.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';

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
    showBasicDialog(context, "Cannot resolve server address.");
  }

  _connectionRefused(BuildContext context) {
    showBasicDialog(context, "Connection refused.");
  }

  _handleAccessDenied(BuildContext context) {
    showBasicDialog(context, "You don't have access to the server.");
  }

  _handleUnauthorised(BuildContext context) {
    showBasicDialog(context, "Unauthorised");
  }

  _handleForbidden(BuildContext context) {
    showBasicDialog(context, "Forbidden");
  }

  _handleUnknown(BuildContext context) {
    showBasicDialog(context, "Unknown network error happended.");
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
