import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/widgets/common/user_avatar.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/secret_chat/post_controller.dart';
import 'add_post.dart';
import 'comment_view.dart';

class PostsView extends StatelessWidget {
  const PostsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<PostController>()
        ? Get.find<PostController>()
        : Get.put(PostController());

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const TextWidget(
          title: "Secret Chat",
          fontSize: 20,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
        actions: [
          IconButton(
            onPressed: () => controller.loadPosts(),
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        title: "Popular",
                        isSelected: controller.currentFilterTab.value == 0,
                        onTap: () => controller.currentFilterTab.value = 0,
                        context: context,
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        title: "My Posts",
                        isSelected: controller.currentFilterTab.value == 1,
                        onTap: () => controller.currentFilterTab.value = 1,
                        context: context,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.posts.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final feed = controller.filteredPosts;
              if (feed.isEmpty) {
                return const Center(
                  child: TextWidget(
                    title: "No posts found",
                    fontSize: 14,
                    textColor: AppColors.textSecondary,
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.loadPosts,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
                  itemCount: feed.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final post = feed[index];
                    return _buildPostCard(context, post, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton.extended(
          onPressed: () => Get.to(() => const AddPostView()),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            "New Post",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextWidget(
          title: title,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          textColor: isSelected ? Colors.white : AppColors.textSecondary,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPostCard(
    BuildContext context,
    PostModel post,
    PostController controller,
  ) {
    log("Image url is ${post.imageUrl}");
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: UserAvatar(
                    imageUrl: post.authorAvatarUrl,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        title: post.authorName,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        textColor: AppColors.textPrimary,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 2),
                      TextWidget(
                        title: post.timeAgo,
                        fontSize: 11,
                        textColor: AppColors.textSecondary,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                if (post.isMyPost)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: () => controller.deletePost(context, post.id),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextWidget(
              title: post.content,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              textColor: AppColors.textPrimary,
              textAlign: TextAlign.start,
            ),
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  controller.mediaUrl(post.imageUrl),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Divider(
              color: AppColors.primary.withValues(alpha: 0.06),
              height: 1,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Obx(
                  () => InkWell(
                    onTap: () => controller.postIdLikeToggle(post),
                    child: Row(
                      children: [
                        Icon(
                          post.isLikedByMe.value
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: post.isLikedByMe.value
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        TextWidget(
                          title: "${post.likes.value}",
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          textColor: post.isLikedByMe.value
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () => Get.to(() => CommentView(post: post)),
                  child: Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedComment01,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Obx(
                        () => TextWidget(
                          title: "${post.commentsCount.value}",
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          textColor: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
