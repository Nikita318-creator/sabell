import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_sabel/core/di/injection_container.dart'; // DI
import 'package:flutter_sabel/features/catalog/data/repositories/server_product_repository.dart';
import '../../catalog/presentation/catalog_screen.dart';
import '../logic/bloc/search_bloc.dart';
import '../logic/bloc/search_event.dart';
import '../logic/bloc/search_state.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  void _showAlert(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('ПОИСК'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK', style: TextStyle(color: Colors.black)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // 👈 Передаем репозиторий в конструктор
      create: (context) =>
          SearchBloc(repository: sl<ServerProductRepository>()),
      child: Material(
        color: Colors.white,
        child: CupertinoPageScaffold(
          backgroundColor: Colors.white,
          navigationBar: const CupertinoNavigationBar(
            backgroundColor: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
            ),
            middle: Text(
              'ПОИСК',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          child: SafeArea(
            child: BlocListener<SearchBloc, SearchState>(
              listener: (context, state) {
                if (state is SearchValidationErrorState) {
                  _showAlert(context, state.message);
                }
              },
              child: Builder(
                builder: (context) {
                  return Column(
                    children: [
                      // Текстовое поле поиска
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: BlocBuilder<SearchBloc, SearchState>(
                          buildWhen: (previous, current) =>
                              previous.queryText != current.queryText,
                          builder: (context, state) {
                            return CupertinoSearchTextField(
                              placeholder: 'Поиск по названию или категории',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              placeholderStyle: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF888888),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              onChanged: (text) {
                                context.read<SearchBloc>().add(
                                  SearchTextChangedEvent(text),
                                );
                              },
                              onSubmitted: (query) {
                                context.read<SearchBloc>().add(
                                  SearchQuerySubmittedEvent(query),
                                );
                              },
                              onSuffixTap: () {
                                context.read<SearchBloc>().add(
                                  const SearchResetEvent(),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Контентная область
                      Expanded(
                        child: BlocBuilder<SearchBloc, SearchState>(
                          builder: (context, state) {
                            if (state is SearchLoadingState) {
                              return const Center(
                                child: CupertinoActivityIndicator(
                                  radius: 12,
                                  color: Colors.black,
                                ),
                              );
                            }

                            if (state is SearchEmptyState) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Text(
                                    'ПО ЗАПРОСУ «${state.query.toUpperCase()}» НИЧЕГО НЕ НАЙДЕНО',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                      color: Color(0xFF777777),
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (state is SearchSuccessState) {
                              return GridView.builder(
                                padding: const EdgeInsets.all(12),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.58,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 16,
                                    ),
                                itemCount: state.products.length,
                                itemBuilder: (context, index) {
                                  final product = state.products[index];
                                  return CatalogProductCard(product: product);
                                },
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
