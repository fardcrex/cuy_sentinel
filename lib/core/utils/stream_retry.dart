import 'dart:async';

/// Estado que retryStream reporta al caller cuando cambia la conectividad.
sealed class RetryState {}

/// El stream falló y se está esperando [backoff] antes de reintentar.
class Retrying extends RetryState {
  Retrying(this.backoff);
  final Duration backoff;
}

/// El stream volvió a emitir datos tras un periodo de [Retrying].
class Reconnected extends RetryState {}

/// Wraps a stream factory with automatic retry and exponential backoff.
///
/// When the stream emits an error or closes unexpectedly, it waits [initial]
/// and re-subscribes, doubling the delay on each failure up to [max].
/// The delay resets to [initial] after any successful emission.
///
/// [onRetry] recibe un [RetryState]:
/// - [Retrying] con el backoff actual cuando el stream falla
/// - [Reconnected] cuando vuelve a emitir tras un fallo
///
/// This makes Supabase Realtime streams resilient to the WebSocket drop that
/// happens when the OS suspends the app (background, lock screen, etc.).
Stream<T> retryStream<T>(
  Stream<T> Function() factory, {
  Duration initial = const Duration(seconds: 2),
  Duration max = const Duration(seconds: 30),
  void Function(RetryState)? onRetry,
}) async* {
  var backoff = initial;
  var wasRetrying = false;
  while (true) {
    try {
      await for (final value in factory()) {
        if (wasRetrying) {
          wasRetrying = false;
          onRetry?.call(Reconnected());
        }
        backoff = initial;
        yield value;
      }
    } catch (_) {
      if (!wasRetrying) {
        wasRetrying = true;
      }
      onRetry?.call(Retrying(backoff));
      await Future.delayed(backoff);
      backoff = backoff * 2 > max ? max : backoff * 2;
    }
  }
}
