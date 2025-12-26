import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/glamora_theme.dart';
import '../services/feed_service.dart';
import '../pages/post_detail_page.dart';

class FeedPostCard extends StatefulWidget {
  final String postId;
  final String userId;
  final String username;
  final String userAvatar;
  final String imageUrl;
  final String caption;
  final List<String> likes;
  final int likeCount;
  final int commentCount;
  final Timestamp? createdAt;
  final List<String> tags;

  const FeedPostCard({
    super.key,
    required this.postId,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.imageUrl,
    required this.caption,
    required this.likes,
    required this.likeCount,
    required this.commentCount,
    this.createdAt,
    required this.tags,
  });

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  bool _showHeart = false;
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = FeedService.hasUserLiked(widget.likes);
    
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _heartAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() async {
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _showHeart = true;
      });
      await FeedService.likePost(widget.postId);
      _heartController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() => _showHeart = false);
            _heartController.reset();
          }
        });
      });
    }
  }

  void _toggleLike() async {
    setState(() => _isLiked = !_isLiked);
    
    if (_isLiked) {
      await FeedService.likePost(widget.postId);
    } else {
      await FeedService.unlikePost(widget.postId);
    }
  }

  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwnPost = widget.userId == currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + Username + Time + Menu
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  // Premium Avatar with gradient border
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          GlamoraColors.deepNavy,
                          GlamoraColors.deepNavy.withOpacity(0.5),
                          const Color(0xFF667eea),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: widget.userAvatar.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.userAvatar,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(color: Colors.grey[200]),
                                errorWidget: (_, __, ___) => _defaultAvatar(),
                              )
                            : _defaultAvatar(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Username + Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: GlamoraColors.deepNavy,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (widget.createdAt != null)
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Text(
                                _getTimeAgo(widget.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  
                  // Menu
                  if (isOwnPost)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.more_horiz, color: GlamoraColors.deepNavy.withOpacity(0.7)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        onSelected: (value) async {
                          if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Text('Delete Post', style: TextStyle(color: GlamoraColors.deepNavy)),
                                content: const Text('Are you sure you want to delete this post?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await FeedService.deletePost(widget.postId);
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red[400], size: 20),
                                const SizedBox(width: 8),
                                const Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Image with double-tap to like
            GestureDetector(
              onDoubleTap: _handleDoubleTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: GlamoraColors.deepNavy,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('Image unavailable', style: TextStyle(color: Colors.grey[400])),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Double-tap heart animation - Premium style
                  if (_showHeart)
                    ScaleTransition(
                      scale: _heartAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 80,
                          shadows: [
                            Shadow(blurRadius: 30, color: Colors.black26),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Action buttons - Premium style
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Like button with animation
                  _ActionButton(
                    icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : GlamoraColors.deepNavy,
                    onTap: _toggleLike,
                    isActive: _isLiked,
                  ),
                  const SizedBox(width: 20),
                  
                  // Comment button
                  _ActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    color: GlamoraColors.deepNavy,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailPage(postId: widget.postId),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  
                  // Share button
                  _ActionButton(
                    icon: Icons.send_rounded,
                    color: GlamoraColors.deepNavy,
                    onTap: () {},
                  ),
                  
                  const Spacer(),
                  
                  // Bookmark button
                  _ActionButton(
                    icon: Icons.bookmark_border_rounded,
                    color: GlamoraColors.deepNavy,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Like count - Premium style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          GlamoraColors.deepNavy.withOpacity(0.1),
                          GlamoraColors.deepNavy.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, size: 16, color: Colors.red[400]),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.likeCount + (_isLiked && !widget.likes.contains(FirebaseAuth.instance.currentUser?.uid) ? 1 : 0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: GlamoraColors.deepNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (widget.commentCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.commentCount}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Caption - Better contrast
            if (widget.caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, height: 1.4),
                    children: [
                      TextSpan(
                        text: widget.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: GlamoraColors.deepNavy,
                        ),
                      ),
                      const TextSpan(text: '  '),
                      TextSpan(
                        text: widget.caption,
                        style: TextStyle(
                          color: Colors.grey[800], // ✅ Fixed: Better contrast
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Tags - Premium pill style
            if (widget.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: widget.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF667eea).withOpacity(0.15),
                          const Color(0xFF764ba2).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$tag',
                      style: const TextStyle(
                        color: Color(0xFF667eea),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )).toList(),
                ),
              ),

            // View all comments - Premium
            if (widget.commentCount > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailPage(postId: widget.postId),
                      ),
                    );
                  },
                  child: Text(
                    'View all ${widget.commentCount} comments',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlamoraColors.deepNavy.withOpacity(0.2),
            GlamoraColors.deepNavy.withOpacity(0.1),
          ],
        ),
      ),
      child: const Icon(Icons.person, color: GlamoraColors.deepNavy, size: 22),
    );
  }
}

// Premium action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}
