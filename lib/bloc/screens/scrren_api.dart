import 'package:flutter/material.dart';
import 'package:flutter_api_bloc/bloc/api_bloc.dart';
import 'package:flutter_api_bloc/bloc/api_event.dart';
import 'package:flutter_api_bloc/bloc/api_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenApi extends StatelessWidget {
  const ScreenApi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions CRUD'),
      ),
      body: BlocBuilder<ApiBloc, ApiState>(
        builder: (context, state) {
          if (state is ApiInitial) {
            context.read<ApiBloc>().add(LoadTransactions());
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ApiLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ApiError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          
          if (state is ApiLoaded) {
            return ListView.builder(
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final transaction = state.transactions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(transaction['avatar']),
                  ),
                  title: Text(transaction['name']),
                  subtitle: Text('Amount: \$${transaction['amount']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showTransactionDialog(
                          context,
                          transaction: transaction,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          context.read<ApiBloc>().add(
                            DeleteTransaction(id: transaction['id']),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
          
          return const Center(child: Text('Unknown state'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTransactionDialog(BuildContext contextOuter, {Map<String, dynamic>? transaction}) {
    final nameController = TextEditingController(text: transaction?['name']);
    final amountController = TextEditingController(
      text: transaction?['amount']?.toString(),
    );

    showDialog(
      context: contextOuter,
      builder: (BuildContext context) => AlertDialog(
        title: Text(transaction == null ? 'Add Transaction' : 'Edit Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newTransaction = {
                if (transaction != null) 'id': transaction['id'],
                'name': nameController.text,
                'amount': int.parse(amountController.text),
                'avatar': transaction?['avatar'] ?? 'https://cloudflare-ipfs.com/ipfs/Qmd3W5DuhgHirLHGVixi6V76LhCkZUz6pnFt5AJBiyvHye/avatar/1.jpg',
                'payment_method': transaction?['payment_method'] ?? 'payment_method 1',
                'transaction_date': DateTime.now().millisecondsSinceEpoch,
                'status': transaction?['status'] ?? false,
              };

              if (transaction == null) {
                contextOuter.read<ApiBloc>().add(AddTransaction(transaction: newTransaction));
              } else {
                contextOuter.read<ApiBloc>().add(UpdateTransaction(transaction: newTransaction));
              }

              Navigator.pop(context);
            },
            child: Text(transaction == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }
}