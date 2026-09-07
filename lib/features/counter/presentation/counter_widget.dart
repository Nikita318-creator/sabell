import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sabel/features/counter/logic/counter_bloc.dart';
import 'package:flutter_sabel/features/counter/logic/counter_event.dart';
import 'package:flutter_sabel/features/counter/logic/counter_state.dart';
import 'second_screen.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Внедряем Bloc в дерево с помощью BlocProvider
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: const _CounterView(),
    );
  }
}

class _CounterView extends StatelessWidget {
  const _CounterView();

  void _navigateToNextScreen(BuildContext context) {
    // Читаем текущее состояние BLoC без подписки
    final currentValue = context.read<CounterBloc>().state.value;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecondScreen(counterValue: currentValue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter BLoC Sandbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // Отправляем событие в BLoC через context.read
            onPressed: () =>
                context.read<CounterBloc>().add(const CounterReset()),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 2. BlocBuilder слушаeт изменения состояния и перерисовывает UI
            BlocBuilder<CounterBloc, CounterState>(
              buildWhen: (previous, current) =>
                  previous.errorMessage != current.errorMessage,
              builder: (context, state) {
                if (state.errorMessage == null) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red.shade100,
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Rebuild только когда изменилось поле value
            BlocBuilder<CounterBloc, CounterState>(
              buildWhen: (previous, current) => previous.value != current.value,
              builder: (context, state) {
                return Text(
                  '${state.value}',
                  style: Theme.of(context).textTheme.headlineLarge,
                );
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _navigateToNextScreen(context),
              child: const Text('Go to next screen'),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'btn_decrement',
            onPressed: () =>
                context.read<CounterBloc>().add(const CounterDecremented()),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'btn_increment',
            onPressed: () =>
                context.read<CounterBloc>().add(const CounterIncremented()),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
