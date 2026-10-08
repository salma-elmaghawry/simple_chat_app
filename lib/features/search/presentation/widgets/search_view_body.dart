import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/core/helpers/spacing.dart';
import 'package:simple_chat_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:simple_chat_app/features/search/presentation/widgets/search_user_item.dart';

class SearchViewBody extends StatefulWidget {
  const SearchViewBody({super.key});

  @override
  State<SearchViewBody> createState() => _SearchViewBodyState();
}

// AutomaticKeepAliveClientMixin keeps the text and results when the
// user switches to another tab and comes back.
class _SearchViewBodyState extends State<SearchViewBody>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController controller = TextEditingController();

  final ScrollController scrollController = ScrollController();

  Timer? debounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(_onScroll);
  }

  // Load the next page when the user is 200px away from the bottom.
  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<SearchCubit>().loadMoreUsers();
    }
  }

  void _onSearchChanged(String value) {
    debounce?.cancel();

    // If the user cleared the text, the results right away.
    if (value.trim().isEmpty) {
      context.read<SearchCubit>().searchUsers(value: value);
      return;
    }

    // Wait until the user stops typing before hitting Firestore.
    debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      context.read<SearchCubit>().searchUsers(value: value);
    });
  }

  void _onSearchSubmitted(String value) {
    debounce?.cancel();

    context.read<SearchCubit>().searchUsers(value: value);
  }

  @override
  void dispose() {
    debounce?.cancel();
    scrollController.dispose();
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmitted,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by name',
              prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
              enabledBorder: InputBorder.none,
            ),
          ),
          verticalSpace(10),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                return switch (state) {
                  SearchInitial() => const Center(
                    child: Text('Search for users'),
                  ),
                  SearchLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  SearchEmpty() => const Center(child: Text('No users found')),
                  SearchFailure(:final message) => Center(
                    child: Text(message, textAlign: TextAlign.center),
                  ),
                  SearchSuccess(:final users, :final isLoadingMore) =>
                    ListView.builder(
                      controller: scrollController,
                      itemCount: users.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == users.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return SearchUserItem(user: users[index]);
                      },
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
