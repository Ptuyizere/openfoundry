import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/core/theme/colors.dart';
import 'package:openfoundry/core/utils/validators.dart';
import 'package:openfoundry/logic/auth/auth_cubit.dart';
import 'package:openfoundry/logic/profile/profile_cubit.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});


  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}


class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _bio = TextEditingController();
  final _location = TextEditingController();
  XFile? _imageFile;
  String? _currentImageUrl;


  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().currentUser;
    if (user != null) {
      _name.text = user.name;
      _phone.text = user.phone;
      _bio.text = user.bio;
      _location.text = user.location;
      _currentImageUrl = user.profileImageUrl;
    }
  }


  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _bio.dispose();
    _location.dispose();
    super.dispose();
  }


  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _imageFile = picked);
  }


  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthCubit>().currentUser;
    if (user == null) return;


    final cubit = context.read<ProfileCubit>();
    String? imageUrl = _currentImageUrl;


    if (_imageFile != null) {
      imageUrl = await cubit.uploadProfileImage(
        userId: user.id,
        file: _imageFile!,
      );
    }


    if (!mounted) return;


    await cubit.saveProfile(
      user: user,
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      bio: _bio.text.trim(),
      location: _location.text.trim(),
      profileImageUrl: imageUrl,
    );


    if (!mounted) return;
    context.read<AuthCubit>().refresh();
    context.pop();
  }


  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    final isSaving = context.select((ProfileCubit c) => c.state.isSaving);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        actions: [
          TextButton(
            onPressed: isSaving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.surfaceMuted,
                        backgroundImage: _imageFile != null
                            ? NetworkImage(_imageFile!.path)
                            : (_currentImageUrl != null
                                ? NetworkImage(_currentImageUrl!)
                                : null) as ImageProvider?,
                        child: _imageFile == null && _currentImageUrl == null
                            ? const Icon(Icons.person,
                                size: 48, color: AppColors.textMuted)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (user?.role ?? UserRole.backer).label,
                    style: const TextStyle(fontSize: 12, color: AppColors.accentGold),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) => Validators.required(v, field: 'Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _location,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (v) => Validators.required(v, field: 'Location'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bio,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    hintText: 'Tell us about yourself...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

