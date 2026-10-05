part of 'search_cubit.dart';

@immutable
sealed class SearchState {}

final class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<UserModel> users;
  final bool hasMore;
  final bool isLoadingMore;
  SearchSuccess({
    required this.users,
    required this.hasMore,
    this.isLoadingMore = false,
  });
}

class SearchEmpty extends SearchState {}

class SearchFailure extends SearchState {
  final String message;

  SearchFailure({required this.message});
}
