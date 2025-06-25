import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final bool showFilterBar;
  final VoidCallback onToggleFilter;
  final String? currentFilter;
  final ValueChanged<String?> onFilterChanged;
  final bool showSettings;
  final VoidCallback? onEditProfile;
  final VoidCallback? onLogout;

  const FilterBar({
    super.key,
    required this.showFilterBar,
    required this.onToggleFilter,
    required this.currentFilter,
    required this.onFilterChanged,
    this.showSettings = false,
    this.onEditProfile,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: showFilterBar
            ? Container(
                key: const ValueKey('expanded'),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF708C5B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onToggleFilter,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.filter_alt,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTypeChip(
                              'All',
                              null,
                              const Icon(Icons.all_inclusive, size: 16)),
                            const SizedBox(width: 6),
                            _buildTypeChip(
                              'Diary',
                              'diary',
                              Icon(Icons.book,
                                  size: 18,
                                  color: Color.fromARGB(255, 48, 39, 176))),
                            const SizedBox(width: 6),
                            _buildTypeChip(
                              'Event',
                              'event',
                              const Icon(Icons.event,
                                  size: 18, color: Colors.blueAccent)),
                            const SizedBox(width: 6),
                            _buildTypeChip(
                              'Report',
                              'report',
                              Icon(Icons.list_alt_rounded,
                                  size: 18,
                                  color: Color.fromARGB(255, 163, 22, 22))),
                          ],
                        ),
                      ),
                    ),
                    if (showSettings) ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.settings, color: Colors.black87),
                        onSelected: (value) {
                          if (value == 'logout' && onLogout != null) {
                            onLogout!();
                          } else if (value == 'profile' && onEditProfile != null) {
                            onEditProfile!();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: 'profile', child: Text('Edit Profile')),
                          const PopupMenuItem(
                              value: 'logout', child: Text('Logout')),
                        ],
                      ),
                    ],
                  ],
                ),
              )
            : Container(
                key: const ValueKey('collapsed'),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onToggleFilter,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.filter_alt_off,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    if (showSettings) ...[
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.settings, color: Colors.black87),
                        onSelected: (value) {
                          if (value == 'logout' && onLogout != null) {
                            onLogout!();
                          } else if (value == 'profile' && onEditProfile != null) {
                            onEditProfile!();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: 'profile', child: Text('Edit Profile')),
                          const PopupMenuItem(
                              value: 'logout', child: Text('Logout')),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String? value, Icon icon) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: currentFilter == value,
      onSelected: (_) => onFilterChanged(value),
      selectedColor: Colors.green,
      labelStyle: TextStyle(
        color: currentFilter == value ? Colors.white : Colors.black,
        fontFamily: 'Oktah',
        fontSize: 13,
      ),
      backgroundColor: Colors.grey.shade200,
      shape: StadiumBorder(
        side: BorderSide(color: Colors.grey.shade400),
      ),
    );
  }
}

class FilterHeader extends SliverPersistentHeaderDelegate {
  final bool showFilterBar;
  final VoidCallback onToggleFilter;
  final String? currentFilter;
  final ValueChanged<String?> onFilterChanged;
  final bool showSettings;
  final VoidCallback? onEditProfile;
  final VoidCallback? onLogout;

  FilterHeader({
    required this.showFilterBar,
    required this.onToggleFilter,
    required this.currentFilter,
    required this.onFilterChanged,
    this.showSettings = false,
    this.onEditProfile,
    this.onLogout,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return FilterBar(
      showFilterBar: showFilterBar,
      onToggleFilter: onToggleFilter,
      currentFilter: currentFilter,
      onFilterChanged: onFilterChanged,
      showSettings: showSettings,
      onEditProfile: onEditProfile,
      onLogout: onLogout,
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}