import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:greenly_app/services/moment_service.dart';
import '../pages/profile/user_manager.dart';
import 'add_moment.dart';

class AddMomentPlace extends StatefulWidget {
  final VoidCallback? onPostCreated;

  const AddMomentPlace({super.key, this.onPostCreated});

  @override
  State<AddMomentPlace> createState() => _AddMomentPlaceState();
}

class _AddMomentPlaceState extends State<AddMomentPlace> {
  @override
  void initState() {
    super.initState();
    // Load user data when widget initializes if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.currentUser == null && !userProvider.isLoading) {
        userProvider.loadCurrentUser();
      }
    });
  }

  Future<void> _navigateToAddMoment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMomentPage()),
    );

    if (result == 'refresh' && widget.onPostCreated != null) {
      widget.onPostCreated!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (userProvider.error != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    userProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        }

        final currentUser = userProvider.currentUser;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _navigateToAddMoment,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF708C5B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + username
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade100,
                        backgroundImage: currentUser?.u_avt != null
                            ? NetworkImage(
                                MomentService.fullImageUrl(currentUser!.u_avt),
                              )
                            : const AssetImage('assets/images/blankava.png')
                                as ImageProvider,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          currentUser?.u_name ?? 'Unknown User',
                          style: const TextStyle(
                            fontFamily: 'Oktah',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),

                  // Share your moment
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            color: Colors.grey.shade500, size: 20),
                        const SizedBox(width: 12),
                        const Text(
                          'Share your moment...',
                          style: TextStyle(
                            fontFamily: 'Oktah',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
