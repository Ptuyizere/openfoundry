import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/data/models/pitch.dart';
import 'package:openfoundry/data/repositories/pitch_repository.dart';


enum BrowseStatus { initial, loading, loaded, error }


class BrowseState extends Equatable {
  const BrowseState._({
    required this.status,
    this.pitches = const [],
    this.search = '',
    this.industry,
    this.fundingType,
    this.message,
  });


  const BrowseState.initial() : this._(status: BrowseStatus.initial);
  const BrowseState.loading() : this._(status: BrowseStatus.loading);
  const BrowseState.loaded({
    required List<Pitch> pitches,
    required String search,
    String? industry,
    FundingType? fundingType,
  }) : this._(
          status: BrowseStatus.loaded,
          pitches: pitches,
          search: search,
          industry: industry,
          fundingType: fundingType,
        );
  const BrowseState.error(String message)
      : this._(status: BrowseStatus.error, message: message);


  final BrowseStatus status;
  final List<Pitch> pitches;
  final String search;
  final String? industry;
  final FundingType? fundingType;
  final String? message;


  bool get isLoading => status == BrowseStatus.loading;
  bool get hasError => status == BrowseStatus.error;
  bool get hasActiveFilters =>
      search.trim().isNotEmpty || industry != null || fundingType != null;


  @override
  List<Object?> get props => [status, pitches, search, industry, fundingType, message];
}


class BrowseCubit extends Cubit<BrowseState> {
  BrowseCubit({required this.pitchRepository})
      : super(const BrowseState.initial());


  final PitchRepository pitchRepository;


  String _search = '';
  String? _industry;
  FundingType? _fundingType;


  Future<void> load() async {
    emit(const BrowseState.loading());
    try {
      final pitches = await pitchRepository.fetchFiltered(
        search: _search,
        industry: _industry,
        fundingType: _fundingType,
      );
      emit(BrowseState.loaded(
        pitches: pitches,
        search: _search,
        industry: _industry,
        fundingType: _fundingType,
      ));
    } catch (e) {
      emit(BrowseState.error(e.toString()));
    }
  }


  void setSearch(String value) {
    _search = value;
    load();
  }


  void setIndustry(String? value) {
    _industry = value;
    load();
  }


  void setFundingType(FundingType? value) {
    _fundingType = value;
    load();
  }


  void clearFilters() {
    _search = '';
    _industry = null;
    _fundingType = null;
    load();
  }
}
