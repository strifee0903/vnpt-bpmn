import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MomentCard extends StatelessWidget {
  final String username;
  final String avatar;
  final String status;
  final List<String>? images; // Changed from String? to List<String>?
  final String location;
  final String time;
  final String type;
  final String category;

  const MomentCard({
    super.key,
    required this.username,
    required this.avatar,
    required this.status,
    this.images,
    required this.location,
    required this.time,
    required this.type,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar + username
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  print('👤 DEBUG - Avatar tapped, URL: $avatar');
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: ClipOval(
                    child: Image.network(
                      avatar,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          print(
                              '✅ DEBUG - Avatar loaded successfully: $avatar');
                          return child;
                        }
                        print('⏳ DEBUG - Avatar loading: $avatar');
                        return const CircularProgressIndicator(strokeWidth: 2);
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ DEBUG - Avatar load failed: $avatar');
                        print('❌ DEBUG - Avatar error: $error');
                        print('❌ DEBUG - Avatar stackTrace: $stackTrace');
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                username,
                style: const TextStyle(
                  fontFamily: 'Oktah',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_vert),
            ],
          ),
        ),

        // Status
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            status,
            style: const TextStyle(
              fontFamily: 'Oktah',
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Image carousel for multiple images
        if (images != null && images!.isNotEmpty)
          SizedBox(
            height: 300,
            child: PageView.builder(
              itemCount: images!.length,
              itemBuilder: (context, index) {
                final image = images![index];
                return GestureDetector(
                  onTap: () {
                    print('🖼️ DEBUG - Image tapped, URL: $image');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            print(
                                '✅ DEBUG - Image loaded successfully: $image');
                            return child;
                          }
                          print('⏳ DEBUG - Image loading: $image');
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ DEBUG - Image load failed: $image');
                          print('❌ DEBUG - Image error: $error');
                          print('❌ DEBUG - Image stackTrace: $stackTrace');
                          return Container(
                            color: Colors.grey[300],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Image failed to load',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'URL: $image',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // Page indicator if there are multiple images
        if (images != null && images!.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images!.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),

        // Additional information
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📍 $location"),
              Text("🕒 $time"),
              Text("📝 $type  |  📂 $category"),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Debug info
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 12.0),
        //   child: Container(
        //     padding: const EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       color: Colors.grey[100],
        //       borderRadius: BorderRadius.circular(4),
        //     ),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Text(
        //           'DEBUG INFO:',
        //           style: TextStyle(
        //             fontSize: 10,
        //             fontWeight: FontWeight.bold,
        //             color: Colors.blue[800],
        //           ),
        //         ),
        //         Text(
        //           'Avatar: $avatar',
        //           style: const TextStyle(fontSize: 9, color: Colors.blue),
        //         ),
        //         if (images != null)
        //           Text(
        //             'Images: ${images!.length}',
        //             style: const TextStyle(fontSize: 9, color: Colors.blue),
        //           ),
        //       ],
        //     ),
        //   ),
        // ),

        const SizedBox(height: 10),
      ],
    );
  }
}
