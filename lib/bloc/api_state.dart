abstract class ApiState {}

class ApiInitial extends ApiState {}

class ApiLoading extends ApiState {}

class ApiLoaded extends ApiState {
  final List<dynamic> transactions;
  ApiLoaded({required this.transactions});
}

class ApiError extends ApiState {
  final String message;
  ApiError({required this.message});
}