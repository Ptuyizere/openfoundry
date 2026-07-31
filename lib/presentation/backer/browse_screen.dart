import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/core/constants/industries.dart';
import 'package:openfoundry/core/theme/colors.dart';
import 'package:openfoundry/logic/pitch/browse_cubit.dart';
import 'package:openfoundry/presentation/common/widgets/empty_state.dart';
import 'package:openfoundry/presentation/common/widgets/pitch_card.dart';
import 'package:openfoundry/router.dart';


class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});


  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}


class _BrowseScreenState extends State<BrowseScreen> {
  final _search = TextEditingController();


  @override
  void initState() {
    super.initState();
    context.read<BrowseCubit>().load();
  }


  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse Pitches')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search pitches, industries, people',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textMuted),
                  onPressed: () {
                    _search.clear();
                    context.read<BrowseCubit>().setSearch('');
                  },
                ),
              ),
              onSubmitted: (v) => context.read<BrowseCubit>().setSearch(v),
            ),
          ),
          const _FilterRow(),
          const SizedBox(height: 4),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }


  Widget _buildList() {
    return BlocBuilder<BrowseCubit, BrowseState>(
      builder: (context, state) {
        if (state.isLoading && state.pitches.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          );
        }
        if (state.hasError) {
          return EmptyState(message: state.message ?? 'Failed to load pitches');
        }
        if (state.pitches.isEmpty) {
          return const EmptyState(
            message: 'No pitches match your search.',
            icon: Icons.search_off,
          );
        }
        return RefreshIndicator(
          color: AppColors.secondary,
          onRefresh: () => context.read<BrowseCubit>().load(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: state.pitches.length,
            itemBuilder: (context, index) {
              final pitch = state.pitches[index];
              return PitchCard(
                pitch: pitch,
                onTap: () => context.pushNamed(
                  AppRoute.pitchDetail.name,
                  pathParameters: {'id': pitch.id},
                ),
              );
            },
          ),
        );
      },
    );
  }
}


class _FilterRow extends StatelessWidget {
  const _FilterRow();


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowseCubit, BrowseState>(
      builder: (context, state) {
        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _FilterChip(
                label: state.fundingType?.label ?? 'All types',
                selected: state.fundingType != null,
                icon: Icons.account_balance_wallet_outlined,
                onTap: () => _showFundingTypeSheet(context, state),
              ),
              ...Industries.all.map((industry) {
                final selected = state.industry == industry;
                return _FilterChip(
                  label: industry,
                  selected: selected,
                  icon: Icons.business_outlined,
                  onTap: () {
                    context.read<BrowseCubit>().setIndustry(
                          selected ? null : industry,
                        );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }


  void _showFundingTypeSheet(BuildContext context, BrowseState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Funding type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('All types'),
                onTap: () {
                  context.read<BrowseCubit>().setFundingType(null);
                  Navigator.pop(context);
                },
              ),
              ...FundingType.values.map(
                (f) => ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: Text(f.label),
                  trailing: state.fundingType == f
                      ? const Icon(Icons.check, color: AppColors.accentGold)
                      : null,
                  onTap: () {
                    context
                        .read<BrowseCubit>()
                        .setFundingType(state.fundingType == f ? null : f);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}


class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });


  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.secondary : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: selected ? AppColors.primary : AppColors.secondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
