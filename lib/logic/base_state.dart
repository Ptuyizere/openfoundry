import 'package:equatable/equatable.dart';

abstract class AsyncState extends Equatable {
  const AsyncState();

  bool get isLoading => false;
  bool get hasError => false;
  bool get isDone => false;
}

class Initial extends AsyncState {
  const Initial();
  @override
  List<Object?> get props => [];
}

class Loading extends AsyncState {
  const Loading();
  @override
  bool get isLoading => true;
  @override
  List<Object?> get props => [];
}

class Error<T extends Object> extends AsyncState {
  const Error(this.message);
  final T message;
  @override
  bool get hasError => true;
  @override
  List<Object?> get props => [message];
}

class Done<T extends Object?> extends AsyncState {
  const Done([this.result]);
  final T? result;
  @override
  bool get isDone => true;
  @override
  List<Object?> get props => [result];
}


