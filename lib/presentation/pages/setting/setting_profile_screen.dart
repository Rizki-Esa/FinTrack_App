import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend_fintrack/presentation/widgets/button/switch_button.dart';
import 'package:frontend_fintrack/presentation/widgets/card/expandable_tile_card.dart';
import 'package:image_picker/image_picker.dart';
import '../../../responsive_helper.dart';
import '../../controllers/setting_profile_controller.dart';
import '../../widgets/card/phone_field_card.dart';
import '../../widgets/input/password_input.dart';
import '../../widgets/input/text_input.dart';
import '../../widgets/pop_up/custom_dialog.dart';
import 'package:provider/provider.dart';

class SettingProfileScreen extends StatefulWidget {
  final int userId;
  const SettingProfileScreen({super.key, required this.userId});

  @override
  State<SettingProfileScreen> createState() => _SettingProfileScreenState();
}

enum ExpandedTile { none, profile, email, phone, password }

class _SettingProfileScreenState extends State<SettingProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  ExpandedTile _expandedTile = ExpandedTile.none;

  Future<void> _pickImage(SettingProfileController ctrl) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    ctrl.imageBytes = bytes;

    setState(() {});

    await ctrl.uploadImage(widget.userId);
  }

  void _toggleTile(ExpandedTile tile, SettingProfileController ctrl) {
    setState(() {
      if (_expandedTile == tile) {
        _expandedTile = ExpandedTile.none;
      } else {
        _expandedTile = tile;
      }

      ctrl.resetDraft();

      ctrl.notifyListeners();
    });
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final ctrl = context.read<SettingProfileController>();
      ctrl.loadProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Consumer<SettingProfileController>(
      builder: (context, ctrl, _) => SingleChildScrollView(
        child: Center(
          child: Container(
            width: responsive.value(mobile: double.infinity, tablet: 800, desktop: 1000),
            padding: responsive.padding(mobile: 8, tablet: 10, desktop: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(context, responsive, ctrl),


                /// PERSONAL INFORMATION
                _buildSection(
                  context,
                  responsive: responsive,
                  title: "Personal Information",
                  children: [
                    _buildPersonalSection(context, responsive, ctrl),
                  ],
                ),

                const SizedBox(height: 8),

                /// PREFERENCES
                _buildSection(
                  context,
                  responsive: responsive,
                  title: "Preferences",
                  children: [
                    _buildPreferenceSection(context, responsive, ctrl),
                  ],
                ),

                SizedBox(height: responsive.size(mobile: 12, desktop: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Responsive responsive, SettingProfileController ctrl) {
    final double avatarRadius = responsive.size(mobile: 40, tablet: 45, desktop: 50);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.blue,
              backgroundImage: ctrl.imageBytes != null ? MemoryImage(ctrl.imageBytes!) : null,
              child: ctrl.imageBytes == null ? Icon(Icons.person, size: avatarRadius, color: Colors.white) : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _pickImage(ctrl),
                child: Container(
                  width: avatarRadius * 0.75,
                  height: avatarRadius * 0.75,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: avatarRadius * 0.3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(ctrl.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: responsive.fontSize(mobile: 16, tablet: 18, desktop: 20))),
        const SizedBox(height: 4),
        Text(ctrl.bio, style: TextStyle(fontSize: responsive.fontSize(mobile: 12, tablet: 14, desktop: 16), color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildPersonalSection(BuildContext context, Responsive responsive, SettingProfileController ctrl) {
    return Column(
      children: [
        ExpandableTileCard(
          responsive: responsive,
          icon: Icons.person_outline,
          title: "Edit Profile",
          subtitle: "Name & Bio",
          isExpanded: _expandedTile == ExpandedTile.profile,
          isEditing: ctrl.isEditingProfile,
          onToggle: () => _toggleTile(ExpandedTile.profile, ctrl),
          onEdit: () {
            ctrl.tempName = ctrl.name;
            ctrl.tempBio = ctrl.bio;

            ctrl.isEditingProfile = true;
            ctrl.notifyListeners();
          },
          onSave: () async {
            final name = ctrl.tempName.trim();

            if (name.isEmpty) {
              CustomDialog.show(
                context: context,
                isSuccess: false,
                message: "Name cannot be empty",
                isDarkMode: ctrl.isDarkMode,
              );
              return;
            }

            final success = await ctrl.saveProfile(widget.userId);
            ctrl.isEditingProfile = false;
            ctrl.notifyListeners();
            if (success) {
              CustomDialog.show(
                context: context,
                isSuccess: true,
                message: "Profile updated",
                isDarkMode: ctrl.isDarkMode,
              );
              setState(() => _expandedTile = ExpandedTile.none);
            }
          },
          isLoading: ctrl.isSavingProfile,
          fields: [
            const Text("Full Name", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextInput(
              isEditing: ctrl.isEditingProfile,
              value: ctrl.tempName,
              onChanged: (val) {
                if (val.length <= 30) ctrl.tempName = val;
              },
              maxLength: 30,
            ),
            const SizedBox(height: 20),
            const Text("Bio", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextInput(
              isEditing: ctrl.isEditingProfile,
              value: ctrl.tempBio,
              onChanged: (val) {
                if (val.length <= 100) ctrl.tempBio = val;
              },
              maxLines: 3,
            ),
          ],
        ),
        const Divider(),
        // Email
        ExpandableTileCard(
          responsive: responsive,
          icon: Icons.email_outlined,
          title: "E-mail",
          subtitle: ctrl.email,
          isExpanded: _expandedTile == ExpandedTile.email,
          isEditing: ctrl.isEditingEmail,
          onToggle: () => _toggleTile(ExpandedTile.email, ctrl),
          onEdit: () {
            ctrl.tempEmail = ctrl.email;
            ctrl.isEditingEmail = true;
            ctrl.notifyListeners();
          },
          onSave: () async {

            final email = ctrl.tempEmail.trim().toLowerCase(); // ⭐ NORMALISASI
            final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

            if (email.isEmpty) {
              CustomDialog.show(
                context: context,
                isSuccess: false,
                message: "Email cannot be empty",
                isDarkMode: ctrl.isDarkMode,
              );
              return;
            }

            if (!emailRegex.hasMatch(email)) {
              CustomDialog.show(
                context: context,
                isSuccess: false,
                message: "Please enter a valid email address",
                isDarkMode: ctrl.isDarkMode,
              );
              return;
            }

            /// ⭐ Simpan email hasil normalisasi
            ctrl.tempEmail = email;

            final success = await ctrl.saveEmail(widget.userId);

            if (success) {
              ctrl.isEditingEmail = false;
              ctrl.notifyListeners();

              CustomDialog.show(
                context: context,
                isSuccess: true,
                message: "Email updated",
                isDarkMode: ctrl.isDarkMode,
              );

              setState(() => _expandedTile = ExpandedTile.none);
            } else {
              CustomDialog.show(
                context: context,
                isSuccess: false,
                message: ctrl.errorMessage ?? "Failed to update email",
                isDarkMode: ctrl.isDarkMode,
              );
            }
          },
          isLoading: ctrl.isSavingEmail,
          fields: [
            const Text("Email Address", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextInput(
              isEditing: ctrl.isEditingEmail,
              value: ctrl.tempEmail,
              onChanged: (val) => ctrl.tempEmail = val,
              maxLength: 254,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              forceLowerCase: true, // 🔥 otomatis huruf kecil
            )
          ],
        ),
        const Divider(),
        // Phone
        ExpandableTileCard(
          responsive: responsive,
          icon: Icons.phone_outlined,
          title: "Phone",
          subtitle: ctrl.phone,
          isExpanded: _expandedTile == ExpandedTile.phone,
          isEditing: ctrl.isEditingPhone,
          onToggle: () => _toggleTile(ExpandedTile.phone, ctrl),
          onEdit: () {
            ctrl.tempPhone = ctrl.phone;
            ctrl.isEditingPhone = true;
            ctrl.notifyListeners();
          },
          onSave: () async {
            final phoneInput = ctrl.tempPhone.trim();

            if (phoneInput.isNotEmpty) {
              final numericOnly = RegExp(r'^[0-9]+$');
              if (!numericOnly.hasMatch(phoneInput)) {
                CustomDialog.show(
                  context: context,
                  isSuccess: false,
                  message: "Phone number can only contain digits",
                  isDarkMode: ctrl.isDarkMode,
                );
                return;
              }
              if (phoneInput.startsWith('0')) {
                CustomDialog.show(
                  context: context,
                  isSuccess: false,
                  message:
                  "Do not start with 0. Enter the phone number starting after the country code (+${ctrl.selectedCountry.phoneCode})",
                  isDarkMode: ctrl.isDarkMode,
                );
                return;
              }
            }
            final success = await ctrl.savePhone(widget.userId);
            ctrl.isEditingPhone = false;
            ctrl.notifyListeners();
            if (success) {
              CustomDialog.show(
                context: context,
                isSuccess: true,
                message: "Phone updated",
                isDarkMode: ctrl.isDarkMode,
              );
              setState(() => _expandedTile = ExpandedTile.none);
            }
          },
          isLoading: ctrl.isSavingPhone,
          fields: [
            const Text("Phone Number", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            PhoneFieldCard(
              isEditing: ctrl.isEditingPhone,
              controller: ctrl.phoneController,
              onChanged: (val) => ctrl.tempPhone = val,
              tempCountry: ctrl.selectedCountry,
              onCountryChanged: (c) => ctrl.setSelectedCountry(c),
              showCountryDropdown: ctrl.showCountryDropdown,
              toggleCountryDropdown: ctrl.toggleCountryDropdown,
              countrySearchController: TextEditingController(),
              hintText: ctrl.isEditingPhone ? null : (ctrl.phone.isEmpty ? "Masukkan nomor HP" : ctrl.phone),
            ),
          ],
        ),
        const Divider(),
        ExpandableTileCard(
          responsive: responsive,
          icon: Icons.lock_outline,
          title: "Change Password",
          subtitle: "••••••••",
          isExpanded: _expandedTile == ExpandedTile.password,
          isEditing: ctrl.isEditingPassword,
          onToggle: () => _toggleTile(ExpandedTile.password, ctrl),
          onEdit: () {
            ctrl.isEditingPassword = true;
            ctrl.notifyListeners();
          },
          onSave: () async {
            final newPwd = ctrl.newPassword.trim();
            final confirmPwd = ctrl.confirmPassword.trim();

            if (ctrl.oldPassword.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
              CustomDialog.show(
                context: context,
                isSuccess: false,
                message: "Please fill all password fields",
                isDarkMode: ctrl.isDarkMode,
              );
              return;
            }

            if (newPwd != confirmPwd) {
              CustomDialog.show(
                context: context,
                isSuccess: false,
                message: "New password and confirm password do not match",
                isDarkMode: ctrl.isDarkMode,
              );
              return;
            }

            // Validasi password baru sebelum save
            if (!ctrl.isPasswordValid(newPwd)) {
              CustomDialog.show(
                context: context,
                isSuccess: false,
                message: "Password tidak memenuhi ketentuan",
                isDarkMode: ctrl.isDarkMode,
              );
              return;
            }

            final success = await ctrl.savePassword(widget.userId);

            if (success) {
              ctrl.isEditingPassword = false;
              ctrl.oldPassword = '';
              ctrl.newPassword = '';
              ctrl.confirmPassword = '';
              ctrl.notifyListeners();

              CustomDialog.show(
                context: context,
                isSuccess: true,
                message: "Password updated successfully",
                isDarkMode: ctrl.isDarkMode,
              );
              setState(() => _expandedTile = ExpandedTile.none);

            } else {
              ctrl.notifyListeners();
              CustomDialog.show(
                context: context,
                isSuccess: false,
                message: "Old password is incorrect",
                isDarkMode: ctrl.isDarkMode,
              );
            }
          },
          isLoading: ctrl.isSavingPassword,
          fields: [
            // OLD PASSWORD
            const Text("Old Password", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            PasswordInput(
              isEditing: ctrl.isEditingPassword,
              value: ctrl.oldPassword,
              isObscure: ctrl.oldPasswordObscure,
              onChanged: (v) => ctrl.oldPassword = v,
              toggleObscure: () {
                ctrl.oldPasswordObscure = !ctrl.oldPasswordObscure;
                ctrl.notifyListeners();
              },
            ),
            const SizedBox(height: 12),

            const Text(
              "Masukkan password baru kamu:",
              style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600,),
            ),
            const SizedBox(height: 4),

            // PASSWORD RULES REAL-TIME CHECKBOX
            Consumer<SettingProfileController>(
              builder: (context, ctrl, _) {
                final rules = ctrl.getPasswordRulesStatus(ctrl.newPassword.trim());
                final allValid = ctrl.isPasswordValid(ctrl.newPassword.trim());

                if (allValid) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Password sudah sesuai kriteria ✅",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rules.entries.map((entry) {
                    return Row(
                      children: [
                        Icon(
                          entry.value ? Icons.check_box : Icons.check_box_outline_blank,
                          size: 16,
                          color: entry.value ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 12,
                              color: entry.value ? Colors.green : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 12),

            // NEW PASSWORD
            const Text("New Password", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            PasswordInput(
              isEditing: ctrl.isEditingPassword,
              value: ctrl.newPassword,
              isObscure: ctrl.newPasswordObscure,
              onChanged: (v) {
                ctrl.newPassword = v;
                ctrl.notifyListeners(); // update checkbox real-time
              },
              toggleObscure: () {
                ctrl.newPasswordObscure = !ctrl.newPasswordObscure;
                ctrl.notifyListeners();
              },
            ),
            const SizedBox(height: 12),

            // CONFIRM PASSWORD
            const Text("Confirm Password", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            PasswordInput(
              isEditing: ctrl.isEditingPassword,
              value: ctrl.confirmPassword,
              isObscure: ctrl.confirmPasswordObscure,
              onChanged: (v) => ctrl.confirmPassword = v,
              toggleObscure: () {
                ctrl.confirmPasswordObscure = !ctrl.confirmPasswordObscure;
                ctrl.notifyListeners();
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _buildPreferenceSection(BuildContext context, Responsive responsive, SettingProfileController ctrl) {
    final tilePadding = responsive.paddingSymmetric(horizontalMobile: 8, verticalMobile: 2);

    Widget buildLeading(IconData icon) => Container(
      width: responsive.size(mobile: 38, desktop: 44),
      height: responsive.size(mobile: 38, desktop: 44),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.blue),
    );

    return Column(
      children: [
        ListTile(
          contentPadding: tilePadding,
          leading: buildLeading(Icons.dark_mode_outlined),
          title: const Text('Dark Mode'),
          trailing: SwitchButton(
            value: ctrl.isDarkMode,
            onChanged: (val) => ctrl.setDarkMode(val, widget.userId),
          ),
        ),
        const Divider(),
        ListTile(
          contentPadding: tilePadding,
          leading: buildLeading(Icons.language_outlined),
          title: const Text('Language'),
          subtitle: Text(ctrl.isEnglish ? 'English' : 'Indonesia'),
          trailing: SwitchButton(
            value: ctrl.isEnglish,
            onChanged: (val) => ctrl.setLanguage(val, widget.userId),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildSection(BuildContext context,
      {required Responsive responsive, required String title, required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: responsive.paddingSymmetric(horizontalMobile: 8, verticalMobile: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: responsive.fontSize(mobile: 13, tablet: 14, desktop: 16),
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

