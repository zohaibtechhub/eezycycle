import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/widgets/common/user_avatar.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/secret_chat/post_controller.dart';

class CommentView extends StatefulWidget {
  final PostModel post;

  const CommentView({super.key, required this.post});

  @override
  State<CommentView> createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  late final TextEditingController commentTextController;
  late final PostController controller;

  @override
  void initState() {
    super.initState();
    commentTextController = TextEditingController();
    controller = Get.find<PostController>();
    controller.loadComments(widget.post);
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.surface,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: context.onSurface,
            ),
          ),
        ),
        title: const TextWidget(
          title: "Comments",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (post.comments.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedComment01,
                        size: 40,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 10),
                      TextWidget(
                        title: "No comments yet",
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.textPrimary,
                      ),
                      SizedBox(height: 2),
                      TextWidget(
                        title: "Be the first to share your thoughts!",
                        fontSize: 12,
                        textColor: AppColors.textSecondary,
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                itemCount: post.comments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final comment = post.comments[index];
                  return _buildCommentCard(context, comment);
                },
              );
            }),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: context.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentTextController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: context.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    await controller.addComment(
                      context,
                      post,
                      commentTextController.text,
                    );
                    commentTextController.clear();
                    FocusScope.of(context).unfocus();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(BuildContext context, CommentModel comment) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: UserAvatar(
              imageUrl: comment.authorAvatarUrl,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextWidget(
                        title: comment.authorName,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        textColor: AppColors.textPrimary,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    TextWidget(
                      title: comment.timeAgo,
                      fontSize: 11,
                      textColor: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                TextWidget(
                  title: comment.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.textSecondary,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => InkWell(
              onTap: () => controller.toggleCommentLike(comment),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    comment.isLikedByMe.value
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 16,
                    color: comment.isLikedByMe.value
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 2),
                  TextWidget(
                    title: "${comment.likes.value}",
                    fontSize: 10,
                    textColor: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
