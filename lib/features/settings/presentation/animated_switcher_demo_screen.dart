import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Event
abstract class ColorEvent {}

class ToggleColorEvent extends ColorEvent {}

// State
class ColorState extends Equatable {
  final Color color;
  final String title;

  const ColorState({required this.color, required this.title});

  @override
  List<Object?> get props => [color, title];
}

// Bloc
class ColorBloc extends Bloc<ColorEvent, ColorState> {
  ColorBloc()
    : super(const ColorState(color: Colors.blue, title: 'Синий блок')) {
    on<ToggleColorEvent>((event, emit) {
      if (state.color == Colors.blue) {
        emit(const ColorState(color: Colors.red, title: 'Красный блок'));
      } else {
        emit(const ColorState(color: Colors.blue, title: 'Синий блок'));
      }
    });
  }
}

// Модель координат кубика
class CubePosition {
  final double top;
  final double left;
  final Color color;
  final String label;

  CubePosition({
    required this.top,
    required this.left,
    required this.color,
    required this.label,
  });
}

class AnimatedSwitcherDemoScreen extends StatefulWidget {
  const AnimatedSwitcherDemoScreen({super.key});

  @override
  State<AnimatedSwitcherDemoScreen> createState() =>
      _AnimatedSwitcherDemoScreenState();
}

class _AnimatedSwitcherDemoScreenState
    extends State<AnimatedSwitcherDemoScreen> {
  final Random _random = Random();
  late List<CubePosition> _cubes;

  @override
  void initState() {
    super.initState();
    _generateRandomPositions();
  }

  void _generateRandomPositions() {
    _cubes = [
      CubePosition(
        top: _random.nextDouble() * 50,
        left: _random.nextDouble() * 50 + 10,
        color: Colors.amber,
        label: '1',
      ),
      CubePosition(
        top: _random.nextDouble() * 50,
        left: _random.nextDouble() * 50 + 110,
        color: Colors.purpleAccent,
        label: '2',
      ),
      CubePosition(
        top: _random.nextDouble() * 50,
        left: _random.nextDouble() * 50 + 210,
        color: Colors.tealAccent,
        label: '3',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ColorBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('AnimatedSwitcher & Key Demo')),
        body: SafeArea(
          child: _DemoContent(
            cubes: _cubes,
            onToggle: () {
              setState(() {
                _generateRandomPositions();
              });
            },
          ),
        ),
      ),
    );
  }
}

class _DemoContent extends StatelessWidget {
  final List<CubePosition> cubes;
  final VoidCallback onToggle;

  const _DemoContent({super.key, required this.cubes, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ColorBloc, ColorState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    onToggle();
                    context.read<ColorBloc>().add(ToggleColorEvent());
                  },
                  child: const Text(
                    'НАЖМИ МЕНЯ (Запустить анимацию)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==========================================
              // 1. БЕЗ КЛЮЧА НА ЦВЕТЕ (Резкая смена фона, кубики плывут)
              // ==========================================
              const Text(
                '❌ БЕЗ КЛЮЧА на фоне (Цвет мгновенный, кубики плывут)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                width: double.infinity,
                child: Stack(
                  children: [
                    // AnimatedSwitcher без ключа НЕ меняет плавно цвет
                    Positioned.fill(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        child: Container(
                          // ⚠️ НЕТ КЛЮЧА
                          color: state.color,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        state.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Кубики живут вне AnimatedSwitcher и красиво плывут
                    ...cubes.map((cube) {
                      return AnimatedPositioned(
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                        top: cube.top,
                        left: cube.left,
                        child: _CubeWidget(cube: cube),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==========================================
              // 2. С КЛЮЧОМ НА ЦВЕТЕ (Плавный Fade фона + полет кубиков!)
              // ==========================================
              const Text(
                '✅ С ValueKey ТОЛЬКО на фоне (Плавный Fade цвета + Полет кубиков)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                width: double.infinity,
                child: Stack(
                  children: [
                    // AnimatedSwitcher анимирует ТОЛЬКО плашку фона
                    Positioned.fill(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        child: Container(
                          // 💡 КЛЮЧ СТОИТ ТОЛЬКО НА ФОНЕ!
                          key: ValueKey<Color>(state.color),
                          color: state.color,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        state.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Кубики плывут без пересоздания и растворения
                    ...cubes.map((cube) {
                      return AnimatedPositioned(
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                        top: cube.top,
                        left: cube.left,
                        child: _CubeWidget(cube: cube),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CubeWidget extends StatelessWidget {
  final CubePosition cube;

  const _CubeWidget({super.key, required this.cube});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: cube.color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        cube.label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
