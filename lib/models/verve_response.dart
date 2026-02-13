import 'verve_error_code.dart';

/// HTTP status code enum following standard HTTP convention
enum HttpStatusCode {
  /// 200 OK - Request succeeded
  ok(200),

  /// 201 Created - Resource created successfully
  created(201),

  /// 204 No Content - Request succeeded but no content to return
  noContent(204),

  /// 400 Bad Request - Invalid parameters
  badRequest(400),

  /// 401 Unauthorized - Missing or invalid authentication
  unauthorized(401),

  /// 403 Forbidden - Access denied
  forbidden(403),

  /// 404 Not Found - Resource not found
  notFound(404),

  /// 429 Too Many Requests - Rate limited
  tooManyRequests(429),

  /// 500 Internal Server Error - Server error
  internalServerError(500),

  /// 502 Bad Gateway - Invalid response from server
  badGateway(502),

  /// 503 Service Unavailable - Server temporarily unavailable
  serviceUnavailable(503),

  /// -1 Unknown Error - Error code not recognized
  unknown(-1);

  final int code;

  const HttpStatusCode(this.code);

  /// Get HttpStatusCode from status code number
  static HttpStatusCode fromCode(int code) {
    try {
      return HttpStatusCode.values.firstWhere((e) => e.code == code);
    } catch (e) {
      return HttpStatusCode.unknown;
    }
  }
}

/// Generic response wrapper for all Verve SDK operations
class VerveResponse<T> {
  /// HTTP status code of the response
  final HttpStatusCode statusCode;

  /// Indicates if operation was successful (statusCode in 200-299 range)
  final bool isSuccess;

  /// Response data payload
  final T? data;

  /// Error message if operation failed
  final String? errorMessage;

  /// Verve-specific numeric error code (see [VerveErrorCode]).
  /// Non-null only when [isSuccess] is false.
  /// Use [VerveErrorCode.nameOf] to get a human-readable label,
  /// or [VerveErrorCode.isRetryable] to decide retry strategy.
  final int? errorCode;

  /// Additional metadata about the request
  final Map<String, dynamic>? metadata;

  /// Raw response for debugging purposes
  final dynamic rawResponse;

  VerveResponse({
    required this.statusCode,
    this.isSuccess = true,
    this.data,
    this.errorMessage,
    this.errorCode,
    this.metadata,
    this.rawResponse,
  });

  /// Create successful response
  factory VerveResponse.success({
    T? data,
    HttpStatusCode statusCode = HttpStatusCode.ok,
    Map<String, dynamic>? metadata,
    dynamic rawResponse,
  }) {
    return VerveResponse(
      statusCode: statusCode,
      isSuccess: true,
      data: data,
      metadata: metadata,
      rawResponse: rawResponse,
    );
  }

  /// Create error response
  factory VerveResponse.error({
    required String errorMessage,
    int? errorCode,
    HttpStatusCode statusCode = HttpStatusCode.internalServerError,
    Map<String, dynamic>? metadata,
    dynamic rawResponse,
  }) {
    return VerveResponse(
      statusCode: statusCode,
      isSuccess: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
      metadata: metadata,
      rawResponse: rawResponse,
    );
  }

  /// Human-readable label for [errorCode], e.g. `NO_FILL`, `LOAD_TIMEOUT`.
  /// Returns `null` when there is no error code.
  String? get errorCodeName =>
      errorCode != null ? VerveErrorCode.nameOf(errorCode!) : null;

  /// Whether the error is retryable (no fill, timeout, network issues).
  /// Returns `false` when there is no error code.
  bool get isRetryableError =>
      errorCode != null ? VerveErrorCode.isRetryable(errorCode!) : false;

  /// Whether the error is permanent (bad config, missing params).
  /// Returns `false` when there is no error code.
  bool get isPermanentError =>
      errorCode != null ? VerveErrorCode.isPermanent(errorCode!) : false;

  @override
  String toString() =>
      'VerveResponse('
      'statusCode: ${statusCode.code}, '
      'isSuccess: $isSuccess, '
      'hasData: ${data != null}, '
      'error: ${errorMessage ?? "none"}, '
      'errorCode: ${errorCode != null ? "$errorCode ($errorCodeName)" : "none"}'
      ')';
}
