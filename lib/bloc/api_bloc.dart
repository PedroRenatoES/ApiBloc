import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_event.dart';
import 'api_state.dart';

// Cambiar la URL base en api_bloc.dart:
class ApiBloc extends Bloc<ApiEvent, ApiState> {
  final String baseUrl = 'https://674869495801f5153590c2a3.mockapi.io/api/v1/transaction';
  
  ApiBloc() : super(ApiInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(LoadTransactions event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        emit(ApiLoaded(transactions: data));
      } else {
        emit(ApiError(message: 'Failed to load transactions'));
      }
    } catch (e) {
      emit(ApiError(message: e.toString()));
    }
  }

  Future<void> _onAddTransaction(AddTransaction event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode(event.transaction),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 201) {
        add(LoadTransactions());
      } else {
        emit(ApiError(message: 'Failed to add transaction'));
      }
    } catch (e) {
      emit(ApiError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(UpdateTransaction event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${event.transaction['id']}'),
        body: json.encode(event.transaction),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        add(LoadTransactions());
      } else {
        emit(ApiError(message: 'Failed to update transaction'));
      }
    } catch (e) {
      emit(ApiError(message: e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(DeleteTransaction event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/${event.id}'),
      );
      if (response.statusCode == 200) {
        add(LoadTransactions());
      } else {
        emit(ApiError(message: 'Failed to delete transaction'));
      }
    } catch (e) {
      emit(ApiError(message: e.toString()));
    }
  }
}