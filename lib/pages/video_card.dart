import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nicare/pages/video_player.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shimmer/shimmer.dart';


class ModernVideoCard extends StatelessWidget {
  final int index;
  final List<String> titles;
  final List<String> searchLinks;
  final List<String> thumbnails;
  final double? customWidth;

  const ModernVideoCard({
    Key? key,
    required this.index,
    required this.titles,
    required this.searchLinks,
    required this.thumbnails,
    this.customWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use 16:9 aspect ratio for video thumbnails
    const aspectRatio = 16 / 9;

    // Calculate dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = customWidth ?? screenWidth * 0.85;
    final cardHeight = cardWidth / aspectRatio;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GestureDetector(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: VideoScreen(searchLinks[index]),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        child: Container(
          width: cardWidth,
          height: cardHeight + 72, // Additional height for text and info
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail Container
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    // Thumbnail
                    CachedNetworkImage(
                      imageUrl: thumbnails[index],
                      width: cardWidth,
                      height: cardHeight*0.85,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: cardWidth,
                          height: cardHeight,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: cardWidth,
                        height: cardHeight,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                    // Play button overlay

                  ],
                ),
              ),
              // Video Info
              // Padding(
              //   padding: const EdgeInsets.all(12),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         titles[index],
              //         maxLines: 2,
              //         overflow: TextOverflow.ellipsis,
              //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}