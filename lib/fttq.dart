library fttq;

import 'package:rxdart/rxdart.dart';

abstract class Event {}

abstract class Command {}

abstract class Handler<T> {
  Type handling = T;
}

abstract class CommandHandler<C extends Command> extends Handler<C> {
  handle(C command);
}

abstract class EventHandler<E extends Event> extends Handler<E> {
  handle(E event);
}

class AppState {
  List<Store> stores;
  BehaviorSubject events;
  Map<Type, CommandHandler> commandHandlers;
  Map<Type, EventHandler> eventHandlers;

  bool isInitialized = false;

  init() {
    stores = [];
    events = BehaviorSubject();
    commandHandlers = Map<Type, CommandHandler>();
    eventHandlers = Map<Type, EventHandler>();
    isInitialized = true;
  }

  dispose() {
    if (stores != null && stores.length > 0) {
      stores.forEach((s) => s.dispose());
      stores = [];
    }

    events?.close();
    commandHandlers?.clear();
  }

  AppState registerHandler(Handler handler) {
    assert(isInitialized, initializedError);
    Type key = handler.handling;
    // print("registered handler for command:: $C");

    if (handler is CommandHandler) {
      if (commandHandlers.containsKey(key)) {
        throw CommandAlreadyHandledException(key, handledBy: commandHandlers[key].runtimeType);
      }
      commandHandlers[key] = handler;
    } else if (handler is EventHandler) {
      eventHandlers[key] = handler;
    }

    return this;
  }

  AppState registerStore(Store store) {
    assert(isInitialized, initializedError);
    stores.add(store);
    return this;
  }

  static final String initializedError =
      "AppState should be initialized, make sure you call initAppState() once";
  static final String storesNotRegisteredError =
      "Store must be registered, make sure you call addStore(Store)";
}

var _appState = AppState();

class AppStateConfig {}

AppState initAppState({AppStateConfig config}) {
  _appState.init();
  return _appState;
}

/// easy functions

Stream<E> listen<E extends Event>() {
  assert(_appState.isInitialized, AppState.initializedError);
  return _appState.events.whereType<E>();
}

fire<E extends Event>(E event) {
  assert(_appState.isInitialized, AppState.initializedError);
  _appState.events.add(event);
  if (_appState.eventHandlers.containsKey(E)) {
    _appState.eventHandlers[E].handle(event);
  }
}

trigger<C extends Command>(C command) {
  assert(_appState.isInitialized, AppState.initializedError);
  // print("triggering command:: $C");
  if (_appState.commandHandlers.containsKey(C)) {
    _appState.commandHandlers[C].handle(command);
  } else {
    throw CommandNotHandledException(C.runtimeType);
  }
}

/// exceptions

class CommandNotHandledException implements Exception {
  final Type commandType;
  const CommandNotHandledException(this.commandType);
  String toString() => "Command '$commandType' is not being handled by any CommandHandler";
}

class CommandAlreadyHandledException implements Exception {
  final Type commandType;
  final Type handledBy;
  const CommandAlreadyHandledException(this.commandType, {this.handledBy});
  String toString() => "Command '$commandType' is already being handled. CommandHandler is '$handledBy'";
}

/// store

abstract class Store {
  dispose() {}
}

S getStore<S extends Store>() {
  assert(_appState.isInitialized, AppState.initializedError);
  final stores = _appState.stores.whereType<S>();
  assert(stores.isNotEmpty, AppState.storesNotRegisteredError);
  return stores.first;
}
