import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:simple_chat_app/core/helpers/cache_helper.dart';
import 'package:simple_chat_app/core/helpers/extensions.dart';
import 'package:simple_chat_app/core/helpers/spacing.dart';
import 'package:simple_chat_app/core/utils/app_assets.dart';
import 'package:simple_chat_app/core/widgets/primary_button.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';
import 'package:simple_chat_app/features/profile/presentation/cubit/profile_cubit.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final UserModel? userModel = CacheHelper.getUserModelData(userKey: "user");
  late final TextEditingController _nameController = TextEditingController(
    text: userModel?.name ?? '',
  );

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onProfileState(BuildContext context, ProfileState state) {
    if (state is ProfileUpdateSuccess) {
      context.showSnackBar('Profile updated successfully.');
      context.pop();
    } else if (state is ProfileUpdateError) {
      context.showSnackBar(state.message, isError: true);
    }
  }

  ImageProvider _avatarImage(ProfileCubit cubit) {
    if (cubit.selectedProfileImage != null) {
      return FileImage(cubit.selectedProfileImage!);
    }
    if (userModel?.image != null) {
      return NetworkImage(userModel!.image!);
    }
    return const AssetImage(AppAssets.avatar);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<ProfileCubit>();

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: _onProfileState,
      builder: (context, state) => ModalProgressHUD(
        inAsyncCall: state is ProfileUpdateLoading,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Update Your Profile Data',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                verticalSpace(10),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 67.r,
                      backgroundImage: _avatarImage(cubit),
                    ),
                    PositionedDirectional(
                      bottom: 0,
                      end: 0,
                      child: GestureDetector(
                        onTap: cubit.pickProfileImage,
                        child: CircleAvatar(
                          radius: 16.r,
                          backgroundColor: theme.colorScheme.primary,
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 18.r,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpace(30),
                TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                verticalSpace(30),
                PrimaryButton(
                  label: 'Update Profile',
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    cubit.updateProfile(
                      name: _nameController.text,
                      imageFile: cubit.selectedProfileImage,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
