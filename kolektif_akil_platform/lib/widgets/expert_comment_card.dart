import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/expert_comment.dart';
import '../services/expert_service.dart';

class ExpertCommentCard extends StatefulWidget {
  final ExpertComment comment;

  const ExpertCommentCard({
    super.key,
    required this.comment,
  });

  @override
  State<ExpertCommentCard> createState() => _ExpertCommentCardState();
}

class _ExpertCommentCardState extends State<ExpertCommentCard> {
  final ExpertService _expertService = ExpertService();
  bool _isLiked = false;
  int _likes = 0;

  @override
  void initState() {
    super.initState();
    _likes = widget.comment.likes;
  }

  Future<void> _handleLike() async {
    if (_isLiked) return;

    setState(() {
      _isLiked = true;
      _likes++;
    });

    try {
      await _expertService.likeComment(widget.comment.id);
    } catch (e) {
      // Hata durumunda geri al
      if (mounted) {
        setState(() {
          _isLiked = false;
          _likes--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Beğeni eklenirken hata: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} dakika önce';
      }
      return '${difference.inHours} saat önce';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final expert = widget.comment.expert;
    
    if (expert == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF9EB0C7).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9EB0C7).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Uzman bilgileri
            Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9EB0C7), Color(0xFF8FA0B8)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9EB0C7).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: expert.photoUrl != null && expert.photoUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            expert.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              expert.displayName ?? 'Uzman',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (expert.verified) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.verified,
                                color: Colors.blue.shade600,
                                size: 16,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            expert.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${expert.expertise.take(2).join(", ")}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Yorum
            Text(
              widget.comment.comment,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 14),
            
            // Alt bilgiler
            Row(
              children: [
                Text(
                  _formatDate(widget.comment.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                
                // Beğeni butonu
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleLike,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _isLiked
                            ? Colors.red.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: _isLiked ? Colors.red : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_likes',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _isLiked ? Colors.red : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
