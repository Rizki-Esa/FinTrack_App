import 'package:flutter/material.dart';
import '../../../responsive_helper.dart';
import '../button/action_button.dart';
import '../button/loading_action_button.dart';

class ExpandableTileCard extends StatelessWidget {
  final Responsive responsive;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isExpanded;
  final bool isEditing;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final bool isLoading;
  final List<Widget> fields;

  const ExpandableTileCard({
    super.key,
    required this.responsive,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isExpanded,
    required this.isEditing,
    required this.onToggle,
    required this.onEdit,
    required this.onSave,
    required this.isLoading,
    required this.fields,
  });

  Widget _buildIconContainer(IconData icon) {
    return Container(
      width: responsive.size(mobile: 38, desktop: 44),
      height: responsive.size(mobile: 38, desktop: 44),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.blue),
    );
  }

  Widget _buildEditButton(VoidCallback onPressed) {
    return ActionButton(
      onPressed: onPressed,
      icon: Icons.edit,
      label: "Edit",
    );
  }

  Widget _buildSaveButton(VoidCallback onPressed) {
    return LoadingActionButton(
      isLoading: isLoading,
      onPressed: onPressed,
      icon: Icons.check,
      label: "Save",
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        ListTile(
          contentPadding: responsive.paddingSymmetric(
            horizontalMobile: 8,
            horizontalTablet: 0,
            horizontalDesktop: 0,
            verticalMobile: 2,
            verticalTablet: 4,
            verticalDesktop: 6,
          ),
          leading: _buildIconContainer(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.25 : 0,
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.chevron_right),
          ),
          onTap: onToggle,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded
              ? ClipRect(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // penting agar child menentukan tinggi
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...fields,
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: isEditing
                          ? _buildSaveButton(onSave)
                          : _buildEditButton(onEdit),
                    ),
                  ),
                ],
              ),
            ),
          )
              : const SizedBox(),
        ),
      ],
    );
  }
}