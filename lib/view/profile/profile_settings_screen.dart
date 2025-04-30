import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stalhub/view/widgets/custom_bottom_navigation.dart';
import 'package:stalhub/view_model/auth/login_view_model.dart';
import 'package:stalhub/view_model/profile/profile_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  int currentIndex = 4;
  bool isEditing = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final loginVM = Provider.of<LoginViewModel>(context, listen: false);
      final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
      if (loginVM.loggedInUser != null) {
        profileVM.fetchUserData(loginVM.loggedInUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileViewModel, LoginViewModel>(
      builder: (context, vm, loginVM, _) {
        _nameController.text = vm.name ?? '';
        _emailController.text = vm.email ?? '';
        _phoneController.text = vm.phoneNumber ?? '';

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
              child: Column(
                children: [
                  Image.asset('assets/images/stalwrites-logo.png', width: 122, height: 68),
                  const SizedBox(height: 20),
                  Container(
                    width: 119,
                    height: 119,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black.withAlpha(128), width: 2),
                      color: const Color(0xFFEDEDED),
                      image: vm.profilePic != null && vm.profilePic!.isNotEmpty
                          ? DecorationImage(image: NetworkImage(vm.profilePic!), fit: BoxFit.cover)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEDED),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Profile Information",
                            style: TextStyle(
                              color: Colors.black.withAlpha(128),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Figtree',
                            )),
                        const SizedBox(height: 16),
                        isEditing
                            ? Column(
                                children: [
                                  _editableField("Name", _nameController),
                                  _editableField("Email", _emailController),
                                  _editableField("Phone Number", _phoneController),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(vm.name ?? "Name", style: _textStyle(20)),
                                  const SizedBox(height: 8),
                                  Text(vm.role ?? "Company Role", style: _textStyle(16)),
                                  const SizedBox(height: 8),
                                  Text(vm.email ?? "Email", style: _textStyle(16)),
                                  const SizedBox(height: 8),
                                  Text(vm.phoneNumber ?? "Phone Number", style: _textStyle(16)),
                                ],
                              ),
                        if (isEditing) ...[
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () async {
                              final id = loginVM.loggedInUser?.id;
                              if (id != null) {
                                await vm.updateProfile(
                                  userId: id,
                                  updatedName: _nameController.text,
                                  updatedEmail: _emailController.text,
                                  updatedPhone: _phoneController.text,
                                );
                                setState(() => isEditing = false);
                              }
                            },
                            child: Container(
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 26, 26, 26),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _outlinedButton(
                          isEditing ? "Cancel" : "Edit your profile",
                          () => setState(() => isEditing = !isEditing),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _outlinedButton("Change Password", () {
                          final userId = loginVM.loggedInUser?.id;
                          if (userId != null) _showChangePasswordModal(userId);
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ✅ Sign Out Button Inserted Here
                  GestureDetector(
                    onTap: () async {
                      await Supabase.instance.client.auth.signOut();
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    },
                    child: Container(
                      height: 64,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(fontSize: 20, fontFamily: 'Figtree', color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/export'),
                    child: Container(
                      height: 64,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 26, 26, 26),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Text(
                        'Export Files To CSV',
                        style: TextStyle(fontSize: 20, fontFamily: 'Figtree', color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() => currentIndex = index);
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/dashboard');
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, '/sales');
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, '/tasks');
                  break;
                case 3:
                  Navigator.pushReplacementNamed(context, '/tickets');
                  break;
                case 4:
                  break;
              }
            },
          ),
        );
      },
    );
  }

  Widget _editableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black.withAlpha(100)),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordModal(String userId) {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();
    final confirmPass = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Change Password", style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w500)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _passwordInput("Old Password", oldPass),
            _passwordInput("New Password", newPass),
            _passwordInput("Confirm Password", confirmPass),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          GestureDetector(
            onTap: () async {
              if (newPass.text != confirmPass.text) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
                return;
              }
              final vm = Provider.of<ProfileViewModel>(context, listen: false);
              final result = await vm.changePassword(userId: userId, newPassword: newPass.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result ?? "Password updated successfully")),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 26, 26, 26),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black),
              ),
              child: const Text("Confirm", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  TextStyle _textStyle(double size) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w500,
        fontFamily: 'Figtree',
      );

  Widget _outlinedButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withAlpha(128), width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w300,
            color: Colors.black.withAlpha(204),
          ),
        ),
      ),
    );
  }
}