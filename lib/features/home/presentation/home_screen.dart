import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sabel/core/di/injection_container.dart';
import 'package:flutter_sabel/features/catalog/data/models/catalog_model.dart';
import 'package:flutter_sabel/features/catalog/data/repositories/server_product_repository.dart';
import 'package:flutter_sabel/features/catalog/presentation/catalog_screen.dart';
import '../logic/home_bloc.dart';
import '../logic/home_event.dart';
import '../logic/home_state.dart';
import 'package:flutter_sabel/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> _countries = [
    'Беларусь',
    'Россия',
    'Казахстан',
    'Армения',
    'Грузия',
    'Узбекистан',
    'ОАЭ',
  ];

  void _showSuccessAlert(BuildContext context, String country) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)?.location_detect ?? ''),
        content: Text(
          AppLocalizations.of(context)?.countrySelected(country) ??
              '', // почему The method 'countrySelected' isn't defined for the type 'AppLocalizations'. Try correcting the name to the name of an existing method, or defining a method named 'countrySelected'.
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('ОК', style: TextStyle(color: Colors.black)),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }

  void _showErrorAlertAndPicker(BuildContext parentContext) {
    showCupertinoDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(
          AppLocalizations.of(parentContext)?.location_error ?? "",
        ), // Undefined name 'context'.Try correcting the name to one that is defined, or defining the name.dartundefined_identifier
        content: const Text(
          'Не удалось автоматически определить вашу страну. Пожалуйста, выберите её вручную из списка.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text(
              'Выбрать страну',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _showManualCountryPicker(parentContext);
            },
          ),
        ],
      ),
    );
  }

  void _showManualCountryPicker(BuildContext parentContext) {
    int selectedIndex = 0;

    showCupertinoModalPopup(
      context: parentContext,
      barrierDismissible: false,
      builder: (modalContext) => PopScope(
        canPop: false,
        child: Container(
          height: 280,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                color: const Color(0xFFF8F8F8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Выберите вашу страну',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text(
                        'Готово',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      onPressed: () {
                        final selectedCountry = _countries[selectedIndex];

                        Navigator.of(modalContext).pop();

                        parentContext.read<HomeBloc>().add(
                          SelectManualCountryEvent(country: selectedCountry),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    selectedIndex = index;
                  },
                  children: _countries
                      .map(
                        (country) => Center(
                          child: Text(
                            country,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeBloc(repository: sl<ServerProductRepository>())
            ..add(const LoadHomeDataEvent()),
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
              'LOOKBOOK',
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
            child: BlocListener<HomeBloc, HomeState>(
              listener: (context, state) {
                debugPrint('[UI_DEBUG] BlocListener получил state: $state');
                if (state is HomeLoadedState) {
                  debugPrint(
                    '[UI_DEBUG] HomeLoadedState -> locationStatus: ${state.locationStatus}, country: ${state.country}',
                  );
                  if (state.locationStatus == LocationStatus.success &&
                      state.country != null) {
                    debugPrint('[UI_DEBUG] Показываем _showSuccessAlert...');
                    _showSuccessAlert(context, state.country!);
                  } else if (state.locationStatus == LocationStatus.denied) {
                    debugPrint(
                      '[UI_DEBUG] Показываем _showErrorAlertAndPicker...',
                    );
                    _showErrorAlertAndPicker(context);
                  }
                }
              },
              child: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) =>
                    current is HomeLoadingState ||
                    current is HomeLoadedState ||
                    current is HomeErrorState,
                builder: (context, state) {
                  if (state is HomeLoadingState || state is HomeInitialState) {
                    return const Center(
                      child: CupertinoActivityIndicator(
                        radius: 12,
                        color: Colors.black,
                      ),
                    );
                  }

                  if (state is HomeErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.errorMessage,
                            style: const TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => context.read<HomeBloc>().add(
                              const LoadHomeDataEvent(),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              color: Colors.black,
                              child: const Text(
                                'ПОВТОРИТЬ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is HomeLoadedState) {
                    return RefreshIndicator.adaptive(
                      color: Colors.black,
                      backgroundColor: Colors.white,
                      onRefresh: () async {
                        final bloc = context.read<HomeBloc>();
                        bloc.add(const HomePullToRefreshEvent());

                        await bloc.stream.firstWhere(
                          (s) => s is HomeLoadedState || s is HomeErrorState,
                        );
                      },
                      child: PageView.builder(
                        scrollDirection: Axis.vertical,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return _ProductCard(product: product);
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final RemoteProducts product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => CatalogProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        color: Colors.white,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF2F2F2),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CupertinoActivityIndicator(
                            color: Colors.black,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              CupertinoIcons.photo,
                              color: Color(0xFFCCCCCC),
                              size: 36,
                            ),
                          ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)} BYN',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: -0.3,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.3,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF222222),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
