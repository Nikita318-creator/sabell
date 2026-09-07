import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_sabel/core/di/injection_container.dart';
import 'package:flutter_sabel/features/catalog/data/models/catalog_model.dart';
import 'package:flutter_sabel/features/catalog/data/repositories/server_product_repository.dart';
import 'package:flutter_sabel/features/catalog/logic/catalog_bloc.dart';
import 'package:flutter_sabel/features/catalog/logic/catalog_event.dart';
import 'package:flutter_sabel/features/catalog/logic/catalog_state.dart';
import 'package:flutter_sabel/features/cart/presentation/cart_screen.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_bloc.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_event.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_state.dart';
import 'package:flutter_sabel/features/catalog/logic/bloc/catalog_details_bloc.dart';
import 'package:flutter_sabel/features/catalog/logic/bloc/catalog_details_event.dart';
import 'package:flutter_sabel/features/catalog/logic/bloc/catalog_details_state.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  void _openCart(BuildContext context) {
    context.read<CartBloc>().add(const LoadCartEvent());

    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (_) => const CartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CatalogBloc(repository: sl<ServerProductRepository>())
            ..add(const LoadCatalogDataEvent()),
      child: Material(
        color: Colors.white,
        child: CupertinoPageScaffold(
          backgroundColor: Colors.white,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: Colors.white,
            border: const Border(
              bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
            ),
            middle: const Text(
              'КАТАЛОГ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                decoration: TextDecoration.none,
              ),
            ),
            trailing: Builder(
              builder: (navContext) {
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _openCart(navContext),
                  child: const Icon(
                    CupertinoIcons.bag,
                    size: 20,
                    color: Colors.black,
                  ),
                );
              },
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<CatalogBloc, CatalogState>(
              builder: (context, state) {
                if (state is CatalogLoadingState ||
                    state is CatalogInitialState) {
                  return const Center(
                    child: CupertinoActivityIndicator(
                      radius: 12,
                      color: Colors.black,
                    ),
                  );
                }

                if (state is CatalogErrorState) {
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
                          onTap: () => context.read<CatalogBloc>().add(
                            const LoadCatalogDataEvent(),
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

                if (state is CatalogLoadedState) {
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      CupertinoSliverRefreshControl(
                        onRefresh: () async {
                          context.read<CatalogBloc>().add(
                            const CatalogPullToRefreshEvent(),
                          );
                          await context.read<CatalogBloc>().stream.firstWhere(
                            (state) =>
                                state is CatalogLoadedState ||
                                state is CatalogErrorState,
                          );
                        },
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(12),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.58,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 16,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = state.products[index];
                            return CatalogProductCard(product: product);
                          }, childCount: state.products.length),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CatalogProductCard extends StatelessWidget {
  final RemoteProducts product;

  const CatalogProductCard({super.key, required this.product});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                color: const Color(0xFFF2F2F2),
                child: Image.network(
                  product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CupertinoActivityIndicator(color: Colors.black),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      CupertinoIcons.photo,
                      color: Color(0xFFCCCCCC),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${product.price.toStringAsFixed(2)} BYN',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: -0.3,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w400,
                color: Color(0xFF444444),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CatalogProductDetailScreen extends StatelessWidget {
  final RemoteProducts product;

  const CatalogProductDetailScreen({super.key, required this.product});

  void _openCart(BuildContext context) {
    context.read<CartBloc>().add(const LoadCartEvent());

    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (_) => const CartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final images = product.allImages;

    return BlocProvider<CatalogDetailsBloc>(
      create: (_) => CatalogDetailsBloc(),
      child: Material(
        color: Colors.white,
        child: CupertinoPageScaffold(
          backgroundColor: Colors.white,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: Colors.white,
            border: const Border(
              bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _openCart(context),
              child: const Icon(
                CupertinoIcons.bag,
                size: 20,
                color: Colors.black,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Builder(
                                builder: (blocContext) {
                                  return PageView.builder(
                                    itemCount: images.length,
                                    onPageChanged: (index) {
                                      blocContext
                                          .read<CatalogDetailsBloc>()
                                          .add(
                                            CatalogDetailsImageChangedEvent(
                                              index,
                                            ),
                                          );
                                    },
                                    itemBuilder: (context, index) {
                                      return Container(
                                        color: const Color(0xFFF2F2F2),
                                        child: Image.network(
                                          images[index],
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return const Center(
                                                  child:
                                                      CupertinoActivityIndicator(
                                                        color: Colors.black,
                                                      ),
                                                );
                                              },
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Center(
                                                    child: Icon(
                                                      CupertinoIcons.photo,
                                                      color: Color(0xFFCCCCCC),
                                                      size: 32,
                                                    ),
                                                  ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              if (images.length > 1)
                                BlocBuilder<
                                  CatalogDetailsBloc,
                                  CatalogDetailsState
                                >(
                                  builder: (context, detailsState) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(images.length, (
                                          index,
                                        ) {
                                          final isSelected =
                                              detailsState.selectedImageIndex ==
                                              index;
                                          return AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 3,
                                            ),
                                            width: isSelected ? 8 : 6,
                                            height: isSelected ? 8 : 6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isSelected
                                                  ? Colors.black
                                                  : Colors.black.withOpacity(
                                                      0.25,
                                                    ),
                                            ),
                                          );
                                        }),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${product.price.toStringAsFixed(2)} BYN',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                  letterSpacing: -0.5,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.35,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                height: 0.5,
                                color: const Color(0xFFE5E5E5),
                                width: double.infinity,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'ОПИСАНИЕ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF888888),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Color(0xFF333333),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
                    ),
                  ),
                  child: BlocBuilder<CartBloc, CartState>(
                    builder: (context, state) {
                      // Проверяем наличие товара по списку productIds в CartLoadedState
                      final isInCart =
                          state is CartLoadedState &&
                          state.productIds.contains(product.id);

                      return GestureDetector(
                        onTap: () {
                          final cartBloc = context.read<CartBloc>();
                          if (isInCart) {
                            cartBloc.add(RemoveFromCartEvent(product.id));
                          } else {
                            cartBloc.add(AddToCartEvent(product.id));
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          color: Colors.black,
                          alignment: Alignment.center,
                          child: Text(
                            isInCart
                                ? 'УДАЛИТЬ ИЗ КОРЗИНЫ'
                                : 'ДОБАВИТЬ В КОРЗИНУ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
