import 'package:flutter/foundation.dart';

/// User our server endpoint on release, otherwise just assume hosted on local machine.
const kServerEndpoint = kReleaseMode
    ? "https://jqphu.dev/mindless/api"
    : "http://192.168.0.178/mindless/api";

/// Endpoint for the user APIs.
const kUserEndpoint = kServerEndpoint + "/user";

/// Errors returned by the server.
enum RequestError { AlreadyExists, NotFound, Unknown }

RequestError requestErrorFromString(String error) {
  print(error);
  if (error == "AlreadyExists") {
    return RequestError.AlreadyExists;
  } else if (error == "NotFound") {
    return RequestError.NotFound;
  } else {
    return RequestError.Unknown;
  }
}

class RequestException implements Exception {
  RequestError error;

  RequestException(this.error);
}
