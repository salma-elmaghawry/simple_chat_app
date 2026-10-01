import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/core/helpers/cache_helper.dart';
import 'package:simple_chat_app/core/helpers/extensions.dart';
import 'package:simple_chat_app/core/helpers/spacing.dart';
import 'package:simple_chat_app/core/routes/routes.dart';
import 'package:simple_chat_app/core/utils/app_assets.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';
import 'package:simple_chat_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:simple_chat_app/features/profile/presentation/widgets/container_setting_option_widget.dart';
import 'package:simple_chat_app/features/profile/presentation/widgets/user_info_column_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? userModel;
  void getMyUserModel() {
    userModel = CacheHelper.getUserModelData(userKey: "user");
  }

  @override
  void initState() {
    getMyUserModel();
    super.initState();
  }

  Future<void> _openUpdateProfile() async {
    await context.pushNamed(Routes.updateProfile);
    // Read the cache again so the new name and image show up.
    setState(getMyUserModel);
  }

  @override
  Widget build(BuildContext context) {
    final String? image = userModel?.image;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w).copyWith(top: 17.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircleAvatar(
                radius: 67.r,
                backgroundImage: image == null
                    ? const AssetImage(AppAssets.avatar)
                    : NetworkImage(image),
              ),
              UserInfoColumnWidget(
                name: userModel?.name ?? '',
                email: userModel?.email ?? '',
              ),
            ],
          ),
          verticalSpace(44),
          ContainerSettingOptionWidget(
            text: "Edit Your Profile",
            icon: Icons.edit_road,
            onTap: _openUpdateProfile,
          ),
          verticalSpace(44),
          ContainerSettingOptionWidget(
            text: "Change Your Password",
            icon: Icons.password,
            onTap: () {},
          ),
          verticalSpace(44),
          ContainerSettingOptionWidget(
            text: "Theme Mode",
            icon: Icons.dark_mode_outlined,
            onTap: () {},
          ),
          verticalSpace(44),
          ContainerSettingOptionWidget(
            text: "Log Out",
            icon: Icons.logout_rounded,
            onTap: () {
              BlocProvider.of<AuthCubit>(context).signOut();
              context.pushReplacementNamed(Routes.login);
            },
          ),
        ],
      ),
    );
  }
}
