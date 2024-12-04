abstract class ApiEvent {}

class LoadTransactions extends ApiEvent {}

class AddTransaction extends ApiEvent {
  final Map<String, dynamic> transaction;
  AddTransaction({required this.transaction});
}

class UpdateTransaction extends ApiEvent {
  final Map<String, dynamic> transaction;
  UpdateTransaction({required this.transaction});
}

class DeleteTransaction extends ApiEvent {
  final String id;
  DeleteTransaction({required this.id});
}