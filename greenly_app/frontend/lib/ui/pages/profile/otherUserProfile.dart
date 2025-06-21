import 'package:flutter/material.dart';
import '../../../components/colors.dart';
import '../../../services/moment_service.dart';
import '../../../models/moment.dart';
import '../../moments/moments_card.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final int userId;
  final String username;
  final String avatarUrl;

  const OtherUserProfileScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.avatarUrl,
  });

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  final MomentService _momentService = MomentService();
  List<Moment> _moments = [];
  String? _typeFilter;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserMoments();
  }

  Future<void> _fetchUserMoments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final moments = await _momentService.getPublicMomentsOfUser(
        userId: widget.userId,
        page: 1,
        limit: 20,
        moment_type: _typeFilter,
      );
      setState(() {
        _moments = moments;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load moments: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTypeChip(String label, String? value) {
    return ChoiceChip(
      label: Text(label),
      selected: _typeFilter == value,
      onSelected: (_) {
        setState(() {
          _typeFilter = value;
        });
        _fetchUserMoments();
      },
      selectedColor: button,
      labelStyle: TextStyle(
        color: _typeFilter == value ? Colors.white : Colors.black,
        fontFamily: 'Oktah',
        fontSize: 13,
      ),
      backgroundColor: Colors.grey.shade200,
      shape: StadiumBorder(
        side: BorderSide(color: Colors.grey.shade400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(125),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.white,
          scrolledUnderElevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hàng chứa avatar, tên và nút Back
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(widget.avatarUrl),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.username,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF708C5B),
                          side: const BorderSide(color: Color(0xFF5A7445)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Oktah',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  // Các chip filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTypeChip('All', null),
                        const SizedBox(width: 6),
                        _buildTypeChip('Diary', 'diary'),
                        const SizedBox(width: 6),
                        _buildTypeChip('Event', 'event'),
                        const SizedBox(width: 6),
                        _buildTypeChip('Report', 'report'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  if (_error != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  else if (_isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (_moments.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'No public moments found.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }
                          final moment = _moments[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF708C5B).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: MomentCard(
                              moment: moment,
                            ),
                          );
                        },
                        childCount: _moments.isEmpty ? 1 : _moments.length,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
