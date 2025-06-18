import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/colors.dart';
import '../../services/moment_service.dart';
import '../../models/moment.dart';
import 'moments_card.dart';

String fullImageUrl(String? relativePath) {
  // Get the correct base URL for images (without /api)
  final imageBaseUrl = MomentService.imageBaseUrl;

  print('🖼️ DEBUG - Image base URL: $imageBaseUrl');
  print('🖼️ DEBUG - Relative path: $relativePath');

  if (relativePath == null || relativePath.isEmpty) {
    final defaultUrl = '$imageBaseUrl/public/images/blank_avt.jpg';
    print('🖼️ DEBUG - Using default avatar: $defaultUrl');
    return defaultUrl;
  }

  if (relativePath.startsWith('http')) {
    print('🖼️ DEBUG - Path is absolute URL: $relativePath');
    return relativePath;
  }

  String fullUrl;
  // Handle paths that start with /public
  if (relativePath.startsWith('/public')) {
    fullUrl = '$imageBaseUrl$relativePath';
  }
  // Handle paths that don't start with /
  else if (!relativePath.startsWith('/')) {
    fullUrl = '$imageBaseUrl/$relativePath';
  } else {
    fullUrl = '$imageBaseUrl$relativePath';
  }

  print('🖼️ DEBUG - Final image URL: $fullUrl');
  return fullUrl;
}

class MomentsPage extends StatefulWidget {
  const MomentsPage({super.key});

  @override
  _MomentsPageState createState() => _MomentsPageState();
}

class _MomentsPageState extends State<MomentsPage> {
  final MomentService _momentService = MomentService();
  late Future<List<Moment>> _momentsFuture;

  @override
  void initState() {
    super.initState();
    print('🚀 DEBUG - MomentsPage initialized');
    _momentsFuture = fetchMoments();
  }

  Future<List<Moment>> fetchMoments() async {
    print('📞 DEBUG - Fetching moments...');
    try {
      final moments = await _momentService.getNewsFeedMoments();
      print('✅ DEBUG - Successfully fetched ${moments.length} moments');
      return moments;
    } catch (e) {
      print('❌ DEBUG - Error fetching moments: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: FutureBuilder<List<Moment>>(
        future: _momentsFuture,
        builder: (context, snapshot) {
          print('🔄 DEBUG - FutureBuilder state: ${snapshot.connectionState}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            print('⏳ DEBUG - Loading moments...');
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('❌ DEBUG - FutureBuilder error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('📭 DEBUG - No moments data available');
            return const Center(child: Text('No moments available.'));
          }

          final moments = snapshot.data!;
          print('📋 DEBUG - Building ListView with ${moments.length} moments');

          return ListView.builder(
            itemCount: moments.length,
            itemBuilder: (context, index) {
              final moment = moments[index];

              print('🏗️ DEBUG - Building moment $index:');
              print('   - User: ${moment.user.u_name}');
              print('   - Avatar path: ${moment.user.u_avt}');
              print('   - Media count: ${moment.media.length}');

              final avatarUrl = fullImageUrl(moment.user.u_avt);
              String? mediaUrl;

              if (moment.media.isNotEmpty) {
                mediaUrl = fullImageUrl(moment.media.first.media_url);
                print('   - Media URL: $mediaUrl');
              }

              // In moments.dart, inside the ListView.builder's itemBuilder:
              return MomentCard(
                username: moment.user.u_name,
                avatar: avatarUrl,
                status: moment.content,
                images: moment.media.isNotEmpty
                    ? moment.media
                        .map((m) => fullImageUrl(m.media_url))
                        .toList()
                    : null,
                location: moment.address,
                time: DateFormat('yyyy-MM-dd HH:mm').format(moment.createdAt),
                type: moment.type,
                category: moment.category.category_name,
                latitude: moment.latitude,
                longitude: moment.longitude,
              );
            },
          );
        },
      ),
    );
  }
}
