library fttq;

import 'dart:math';

import 'package:rxdart/rxdart.dart';

abstract class Event {}

abstract class Command {}

abstract class FunctionalCommand extends Command {
  final key = _appState.random.nextInt(999999);
}

abstract class CommandHandler<C extends Command> {
  Type handling = C;
  handle(C command);  
}

typedef Null FunctionalCommandHandler<C extends FunctionalCommand>(C command);

class AppState {
  List<Store> stores;
  BehaviorSubject events;

  Map<Type, CommandHandler> commandHandlers;
  Map<int, FunctionalCommandHandler> functionalCommandHandlers;

  bool isInitialized = false;

  final random = Random(77131);

  init() {
    stores = [];
    events = BehaviorSubject();
    commandHandlers = Map<Type, CommandHandler>();
    functionalCommandHandlers = Map<int, FunctionalCommandHandler>();
    isInitialized = true;
  }

  dispose() {
    if (stores != null && stores.length > 0) {
      stores.forEach((s) => s.dispose());
      stores = [];
    }

    events?.close();
    commandHandlers.clear();
    functionalCommandHandlers.clear();
  }

  static final String initializedError =
      "AppState should be initialized, make sure you call _appState.init()";
}

var _appState = AppState();

class AppStateConfig {}

initAppState({AppStateConfig config}) {
  _appState.init();
}

/// easy functions

Stream<E> listen<E extends Event>() {
  assert(_appState.isInitialized, AppState.initializedError);
  return _appState.events.whereType<E>();
}

fire<E extends Event>(E event) {
  assert(_appState.isInitialized, AppState.initializedError);
  _appState.events.add(event);
}

trigger<C extends Command>(C command) {
  assert(_appState.isInitialized, AppState.initializedError);
  // print("triggering command:: $C");
  if (_appState.commandHandlers.containsKey(C)) {
    _appState.commandHandlers[C].handle(command);
  } else if (command is FunctionalCommand) {
    if (_appState.functionalCommandHandlers.containsKey(command.key)) {
      _appState.functionalCommandHandlers[command.key](command);
    } else {
      throw _commandNotHandledException(command.runtimeType);
    }
  } else {
    throw _commandNotHandledException(C.runtimeType);
  }
}

registerHandler(CommandHandler handler) {
  assert(_appState.isInitialized, AppState.initializedError);
  Type C = handler.handling;
  // print("registered handler for command:: $C");
  if (_appState.commandHandlers.containsKey(C)) {
    throw _commandAlreadyHandledException(C);
  }
  _appState.commandHandlers[C] = handler;
}

Command createCommand([Object value]) {
  if (value == null) {
    return EmptyCommand();
  }

  if (value is String) {
    return StringCommand(value);
  }

  if (value is int) {
    return IntCommand(value);
  }
  throw _commandCannotBeCreatedException();
}

registerFunctionalHandler(
    FunctionalCommand forCommand, FunctionalCommandHandler handler) {
  assert(_appState.isInitialized, AppState.initializedError);
  final key = forCommand.key;
  // print("registered handler for command with key:: $key");
  if (_appState.functionalCommandHandlers.containsKey(key)) {
    throw _commandAlreadyHandledException(forCommand.runtimeType);
  }
  _appState.functionalCommandHandlers[key] = handler;
}

/// easy functional commands

class EmptyCommand extends FunctionalCommand {}

class StringCommand extends FunctionalCommand {
  final String value;

  StringCommand(this.value);
}

class IntCommand extends FunctionalCommand {
  final int value;

  IntCommand(this.value);
}

/// exceptions

_commandNotHandledException(Type commandType) => Exception(
    "Command ($commandType) is not being handled by any CommandHandler");

_commandAlreadyHandledException(Type commandType) => Exception(
    "Command ($commandType) is already being handled by a CommandHandler");

_commandCannotBeCreatedException() => Exception("Command cannot be created");

/// store

abstract class Store {
  dispose();
}

addStore(Store store) {
  assert(_appState.isInitialized, AppState.initializedError);
  _appState.stores.add(store);
}

S getStore<S extends Store>() {
    assert(_appState.isInitialized, AppState.initializedError);
    return _appState.stores.whereType<S>()?.first;
  }