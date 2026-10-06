import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:period_ovulation_tracker/controllers/secret_chat/secret_profile_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/services/api_service.dart';
import 'package:period_ovulation_tracker/core/utils/short_message.dart';
import 'package:period_ovulation_tracker/routes/app_pages.dart';
import 'package:period_ovulation_tracker/widgets/common/app_loading.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

class CommentModel {
  final String id;
  final String authorName;
  final String? authorAvatarUrl;
  final String text;
  final String timeAgo;
  final RxInt likes;
  final RxBool isLikedByMe;
  final bool isMine;

  CommentModel({
    required this.id,
    required this.authorName,
    this.authorAvatarUrl,
    required this.text,
    required this.timeAgo,
    required int likes,
    required bool isLikedByMe,
    this.isMine = false,
  }) : likes = likes.obs,
       isLikedByMe = isLikedByMe.obs;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'];
    final authorName = author is Map
        ? (author['username']?.toString() ?? 'Anonymous')
        : 'Anonymous';
    final authorAvatar = author is Map
        ? author['avatar_url']?.toString()
        : null;
    return CommentModel(
      id: json['id']?.toString() ?? '',
      authorName: authorName,
      authorAvatarUrl: (authorAvatar != null && authorAvatar.isNotEmpty)
          ? authorAvatar
          : null,
      text: json['body']?.toString() ?? json['text']?.toString() ?? '',
      timeAgo: json['time_ago']?.toString() ?? '',
      likes: _asInt(json['likes_count']),
      isLikedByMe: json['liked_by_me'] == true,
      isMine: json['is_mine'] == true,
    );
  }
}

class PostModel {
  final String id;
  final String authorName;
  final String? authorAvatarUrl;
  final String timeAgo;
  final String content;
  final String? imageUrl;
  final bool isMyPost;
  final RxInt likes;
  final RxBool isLikedByMe;
  final RxInt commentsCount;
  final RxList<CommentModel> comments;

  PostModel({
    required this.id,
    required this.authorName,
    this.authorAvatarUrl,
    required this.timeAgo,
    required this.content,
    this.imageUrl,
    required this.isMyPost,
    required int likes,
    required bool isLikedByMe,
    required int commentsCount,
    List<CommentModel>? comments,
  }) : likes = likes.obs,
       isLikedByMe = isLikedByMe.obs,
       commentsCount = commentsCount.obs,
       comments = (comments ?? <CommentModel>[]).obs;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'];
    final authorName = author is Map
        ? (author['username']?.toString() ?? 'Anonymous')
        : 'Anonymous';
    final authorAvatar = author is Map
        ? author['avatar_url']?.toString()
        : null;
    return PostModel(
      id: json['id']?.toString() ?? '',
      authorName: authorName,
      authorAvatarUrl: (authorAvatar != null && authorAvatar.isNotEmpty)
          ? authorAvatar
          : null,
      timeAgo: json['time_ago']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      isMyPost: json['is_mine'] == true,
      likes: _asInt(json['likes_count']),
      isLikedByMe: json['liked_by_me'] == true,
      commentsCount: _asInt(json['comments_count']),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse('$value') ?? 0;
}

class PostController extends GetxController {
  final ApiClient _api = ApiClient();
  final ImagePicker _picker = ImagePicker();

  final RxInt currentFilterTab = 0.obs;
  final TextEditingController contentController = TextEditingController();
  final Rxn<File> selectedImageFile = Rxn<File>();
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isPublishing = false.obs;
  final RxBool isPickingImage = false.obs;

  List<PostModel> get filteredPosts {
    if (currentFilterTab.value == 1) {
      return posts.where((p) => p.isMyPost).toList();
    }
    return posts;
  }

  @override
  void onInit() {
    super.onInit();
    ever(currentFilterTab, (_) => loadPosts());
    loadPosts();
  }

  SecretProfileController _profileController() {
    if (Get.isRegistered<SecretProfileController>()) {
      return Get.find<SecretProfileController>();
    }
    return Get.put(SecretProfileController());
  }

  Future<bool> _ensureSecretProfile(BuildContext context) async {
    final profile = _profileController();
    if (profile.hasProfile.value &&
        profile.username.value.trim().length >= 3 &&
        profile.username.value != 'Username') {
      return true;
    }
    await profile.loadProfile();
    if (profile.hasProfile.value) return true;

    ShortMessageUtils.showError(
      context,
      'Set your secret chat username first.',
    );
    Get.toNamed(AppPages.editSecretProfile);
    return false;
  }

  Future<void> loadPosts() async {
    isLoading.value = true;
    try {
      final filter = currentFilterTab.value == 1 ? 'mine' : 'popular';
      final response = await _api.get('${ApiEndPoints.posts}?filter=$filter');
      final data = ApiClient.unwrapData(response);
      final list = data?['posts'];
      if (list is List) {
        posts.assignAll(
          list
              .whereType<Map>()
              .map((e) => PostModel.fromJson(Map<String, dynamic>.from(e))),
        );
      } else {
        posts.clear();
      }
    } catch (e) {
      final ctx = Get.context;
      if (ctx != null) {
        ShortMessageUtils.showError(
          ctx,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> postIdLikeToggle(PostModel post) async {
    final wasLiked = post.isLikedByMe.value;
    post.isLikedByMe.value = !wasLiked;
    post.likes.value += wasLiked ? -1 : 1;

    try {
      final response = await _api.post(ApiEndPoints.postLikes(post.id), {});
      final data = ApiClient.unwrapData(response);
      if (data != null) {
        post.isLikedByMe.value = data['liked_by_me'] == true;
        post.likes.value = _asInt(data['likes_count']);
      }
    } catch (e) {
      post.isLikedByMe.value = wasLiked;
      post.likes.value += wasLiked ? 1 : -1;
      final ctx = Get.context;
      if (ctx != null) {
        ShortMessageUtils.showError(
          ctx,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  Future<void> toggleCommentLike(CommentModel comment) async {
    final wasLiked = comment.isLikedByMe.value;
    comment.isLikedByMe.value = !wasLiked;
    comment.likes.value += wasLiked ? -1 : 1;

    try {
      final response =
          await _api.post(ApiEndPoints.commentLikes(comment.id), {});
      final data = ApiClient.unwrapData(response);
      if (data != null) {
        comment.isLikedByMe.value = data['liked_by_me'] == true;
        comment.likes.value = _asInt(data['likes_count']);
      }
    } catch (e) {
      comment.isLikedByMe.value = wasLiked;
      comment.likes.value += wasLiked ? 1 : -1;
      final ctx = Get.context;
      if (ctx != null) {
        ShortMessageUtils.showError(
          ctx,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  Future<void> loadComments(PostModel post) async {
    try {
      final response = await _api.get(ApiEndPoints.postComments(post.id));
      final data = ApiClient.unwrapData(response);
      final list = data?['comments'];
      if (list is List) {
        final comments = list
            .whereType<Map>()
            .map((e) => CommentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        post.comments.assignAll(comments);
        post.commentsCount.value = comments.length;
      }
    } catch (e) {
      final ctx = Get.context;
      if (ctx != null) {
        ShortMessageUtils.showError(
          ctx,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  Future<void> addComment(
    BuildContext context,
    PostModel post,
    String commentText,
  ) async {
    if (commentText.trim().isEmpty) {
      ShortMessageUtils.showError(context, 'Comment cannot be empty.');
      return;
    }
    if (!await _ensureSecretProfile(context)) return;

    try {
      final response = await _api.post(ApiEndPoints.postComments(post.id), {
        'body': commentText.trim(),
      });
      final data = ApiClient.unwrapData(response);
      final commentJson = data?['comment'];
      if (commentJson is Map) {
        post.comments.add(
          CommentModel.fromJson(Map<String, dynamic>.from(commentJson)),
        );
      }
      if (data?['comments_count'] != null) {
        post.commentsCount.value = _asInt(data!['comments_count']);
      } else {
        post.commentsCount.value = post.comments.length;
      }
      ShortMessageUtils.showSuccess(context, 'Comment added successfully!');
    } catch (e) {
      ShortMessageUtils.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> deletePost(BuildContext context, String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: context.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const TextWidget(
                title: 'Delete post?',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                textColor: AppColors.textPrimary,
              ),
              const SizedBox(height: 10),
              const TextWidget(
                title:
                    'This post will be removed permanently. Comments and likes will be deleted too.',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                textColor: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    AppLoading.show('Deleting post…');
    try {
      await _api.delete(ApiEndPoints.postById(postId));
      posts.removeWhere((p) => p.id == postId);
      AppLoading.hide();
      if (context.mounted) {
        ShortMessageUtils.showSuccess(context, 'Post has been removed.');
      }
    } catch (e) {
      AppLoading.hide();
      if (context.mounted) {
        ShortMessageUtils.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  Future<void> pickImageFromGallery(BuildContext context) async {
    if (isPickingImage.value) return;
    isPickingImage.value = true;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked == null) return;
      selectedImageFile.value = File(picked.path);
    } catch (e) {
      ShortMessageUtils.showError(
        context,
        'Could not open gallery. Check photo permissions.',
      );
    } finally {
      isPickingImage.value = false;
    }
  }

  void clearSelectedImage() {
    selectedImageFile.value = null;
  }

  String mediaUrl(String? path) => _api.resolveMediaUrl(path);

  Future<void> createNewPost(BuildContext context) async {
    if (contentController.text.trim().isEmpty) {
      ShortMessageUtils.showError(
        context,
        'Please write something for your post.',
      );
      return;
    }
    if (!await _ensureSecretProfile(context)) return;
    if (isPublishing.value) return;

    isPublishing.value = true;
    try {
      final content = contentController.text.trim();
      late final dynamic response;

      final image = selectedImageFile.value;
      if (image != null) {
        response = await _api.postFormData(ApiEndPoints.posts, {
          'content': content,
          'image': image,
        });
      } else {
        response = await _api.post(ApiEndPoints.posts, {
          'content': content,
        });
      }

      final data = ApiClient.unwrapData(response);
      final postJson = data?['post'];
      if (postJson is Map) {
        posts.insert(
          0,
          PostModel.fromJson(Map<String, dynamic>.from(postJson)),
        );
      }

      contentController.clear();
      selectedImageFile.value = null;
      Get.back();
      ShortMessageUtils.showSuccess(context, 'Post published successfully!');
    } catch (e) {
      ShortMessageUtils.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isPublishing.value = false;
    }
  }

  @override
  void onClose() {
    contentController.dispose();
    super.onClose();
  }
}
