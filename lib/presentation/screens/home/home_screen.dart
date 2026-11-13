import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/home/widgets/home_filter_bar.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/home/widgets/home_hero.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/home/widgets/home_platos_grid.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/layout/page_container.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/home/home_cubit.dart';
import 'package:material_ui/material_ui.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<HomeCubit>()..load(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _navigate(Future<String?> destination) async {
    final location = await destination;
    if (location == null || !mounted) return;
    context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.searchTerm != current.searchTerm,
      listener: (_, state) {
        if (_search.text != state.searchTerm) _search.text = state.searchTerm;
      },
      child: PageContainer(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeHero(onOrder: () => _navigate(cubit.orderDestination())),
                AppSpacing.h32,
                HomeFilterBar(
                  categorias: state.categorias,
                  selectedCategoriaId: state.selectedCategoriaId,
                  searchController: _search,
                  onCategoriaSelected: cubit.filterByCategoria,
                  onSearchChanged: cubit.searchTermChanged,
                  onSearchSubmitted: cubit.search,
                ),
                AppSpacing.h32,
                HomePlatosGrid(
                  loading: state.loading,
                  platos: state.platos,
                  onAddToCart: (_) => _navigate(cubit.addToCartDestination()),
                  onShowAll: () => cubit.filterByCategoria(null),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
