import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lavie/data_layer/bloc/profileCubit/profile_cubit.dart';
import 'package:lavie/data_layer/bloc/profileCubit/profile_states.dart';
import 'package:lavie/presentation_layer/shared/component/default_button.dart';
import 'package:lavie/presentation_layer/shared/component/default_text_form_field.dart';
import 'package:lavie/presentation_layer/shared/component/shimmer.dart';
import 'package:lavie/presentation_layer/shared/resources/color_manager.dart';
import 'package:lavie/presentation_layer/shared/resources/controllers.dart';
import 'package:lavie/presentation_layer/shared/widget/post_item.dart';
import 'package:lavie/presentation_layer/shared/widget/search_bar.dart';
import '../../../application_layer/routes_manager.dart';
import '../../shared/component/default_navigation.dart';
import '../../shared/widget/notification_item.dart';

class DiscussionForums extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var postSearchController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.zero,
          splashRadius: 30,
          onPressed: () {
            Navigation.navigatorBack(context: context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          "DiscussionForums",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 10,
        onPressed: () {
          Navigation.navigatorTo(
              context: context, navigatorTo: Routes.createPost);
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: BlocConsumer<ProfileCubit, ProfileStates>(
          listener: (context, state) {},
          builder: (context, state) {
            var cubit = ProfileCubit.get(context);
            return Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 65,
                    width: double.infinity,
                    child: searchBar(
                      context: context,
                      onTap: () {
                        Navigation.navigatorTo(
                          context: context,
                          navigatorTo: Routes.postsSearchScreen,
                        );
                      },
                      enabled: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 10),
                    child: Row(
                      children: [
                        DefaultButton(
                          height: 35,
                          width: 100,
                          label: "All Forums",
                          labelStyle:
                              Theme.of(context).textTheme.subtitle2!.copyWith(
                                    color: cubit.toggleBetweenAllForumAndMyForum
                                        ? ColorManager.white
                                        : ColorManager.black,
                                  ),
                          borderRadius: 7,
                          borderColor: ColorManager.greyAccent,
                          buttonColor: cubit.toggleBetweenAllForumAndMyForum
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).backgroundColor,
                          onTap: () {
                            cubit.toggleBetweenAllForumAndMyForumButton(
                                isALlForum: true);
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        DefaultButton(
                          height: 35,
                          width: 100,
                          label: "My forums",
                          labelStyle:
                              Theme.of(context).textTheme.subtitle2!.copyWith(
                                    color: cubit.toggleBetweenAllForumAndMyForum
                                        ? ColorManager.black
                                        : ColorManager.white,
                                  ),
                          borderRadius: 7,
                          borderColor: ColorManager.greyAccent,
                          buttonColor: cubit.toggleBetweenAllForumAndMyForum
                              ? Theme.of(context).backgroundColor
                              : Theme.of(context).primaryColor,
                          onTap: () {
                            cubit.toggleBetweenAllForumAndMyForumButton(
                                isALlForum: false);
                            cubit.getMyPosts();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: state is GetMyPostLoadingState
                        ? const ShimmerLoadingScreen()
                        : cubit.toggleBetweenAllForumAndMyForum
                            ? const SizedBox(
                                child: Center(child: Text("all forums")),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) => postItem(
                                  context: context,
                                  userImage: cubit
                                      .myPostsModel!.data![index].user!.imageUrl
                                      .toString(),
                                  firstName: cubit.myPostsModel!.data![index]
                                      .user!.firstName
                                      .toString(),
                                  lastName: cubit
                                      .myPostsModel!.data![index].user!.lastName
                                      .toString(),
                                  postDate: "yesterday",
                                  postTitle: cubit
                                      .myPostsModel!.data![index].title
                                      .toString(),
                                  postContaining: cubit
                                      .myPostsModel!.data![index].description
                                      .toString(),
                                  postImage: cubit
                                      .myPostsModel!.data![index].imageUrl
                                      .toString(),
                                  likes: cubit.myPostsModel!.data![index]
                                      .forumLikes!.length,
                                  replies: cubit.myPostsModel!.data![index]
                                      .forumComments!.length,
                                  onTapUserImage: () {},
                                  onTapReplies: () {
                                    onTapOnComments(
                                        context: context, index: index);
                                  },
                                  onTapLike: () {
                                    cubit.toggleLikeButton();
                                    cubit.addLike(
                                      postId: cubit
                                          .myPostsModel!.data![index].forumId
                                          .toString(),
                                    );
                                  },
                                  onTapUserName: () {},
                                ),
                                itemCount: cubit.myPostsModel!.data!.length,
                              ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

void onTapOnComments({
  required BuildContext context,
  required int index,
}) {
  var cubit = ProfileCubit.get(context);
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(10),
                topEnd: Radius.circular(10),
              )),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.08,
              ),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) => notificationItem(
                    context: context,
                    imageURL: cubit
                        .userModel!.data!.userNotification![index].imageUrl
                        .toString(),
                    notificationMassege: cubit.myPostsModel!.data![index]
                        .forumComments![index].comment
                        .toString(),
                    notificationDate: Jiffy(cubit.myPostsModel!.data![index]
                            .forumComments![index].createdAt)
                        .yMMMMd,
                  ),
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 5,
                  ),
                  itemCount:
                      cubit.myPostsModel!.data![index].forumComments!.length,
                ),
              ),
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: BoxDecoration(
                    color: ColorManager.lightGrey.withOpacity(0.4),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    )),
                child: CustomTextFormField(
                  controller: AppControllers.typeCommentController,
                  keyboardType: TextInputType.text,
                ),
              )
            ],
          ),
        );
      });
}
