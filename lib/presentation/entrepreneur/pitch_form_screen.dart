import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/core/constants/industries.dart';
import 'package:openfoundry/core/theme/colors.dart';
import 'package:openfoundry/core/utils/validators.dart';
import 'package:openfoundry/data/models/pitch.dart';
import 'package:openfoundry/logic/auth/auth_cubit.dart';
import 'package:openfoundry/logic/pitch/pitch_cubit.dart';
import 'package:openfoundry/router.dart';


class PitchFormScreen extends StatefulWidget {
  const PitchFormScreen({super.key, this.pitch});


  final Pitch? pitch;


  @override
  State<PitchFormScreen> createState() => _PitchFormScreenState();
}


class _PitchFormScreenState extends State<PitchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _pricePerShare = TextEditingController();
  final _goal = TextEditingController();


  String _industry = Industries.all.first;
  FundingType _fundingType = FundingType.grant;
  XFile? _cover;
  XFile? _video;
  String? _coverUrl;
  String? _videoUrl;
  bool _uploadingMedia = false;


  bool get _isEditing => widget.pitch != null;


  @override
  void initState() {
    super.initState();
    if (widget.pitch != null) {
      final p = widget.pitch!;
      _title.text = p.title;
      _description.text = p.description;
      _industry = p.industry;
      _fundingType = p.fundingType;
      _pricePerShare.text =
          p.pricePerShare != null ? p.pricePerShare.toString() : '';
      _goal.text = p.fundingGoal.toString();
      _coverUrl = p.coverImageUrl;
      _videoUrl = p.videoUrl;
    }
  }


  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _pricePerShare.dispose();
    _goal.dispose();
    super.dispose();
  }


  Future<void> _pickCover() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _cover = picked);
  }


  Future<void> _pickVideo() async {
    final picked = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (picked != null) setState(() => _video = picked);
  }


  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthCubit>().currentUser;
    if (user == null) return;


    final cubit = context.read<PitchCubit>();


    final newId = await cubit.savePitch(
      user: user,
      pitchId: widget.pitch?.id ?? '',
      title: _title.text.trim(),
      description: _description.text.trim(),
      industry: _industry,
      fundingType: _fundingType,
      pricePerShare: _fundingType == FundingType.equity
          ? double.tryParse(_pricePerShare.text)
          : null,
      fundingGoal: double.tryParse(_goal.text) ?? 0,
      coverImageUrl: _coverUrl,
      videoUrl: _videoUrl,
      isEditing: _isEditing,
      raised: widget.pitch?.raised ?? 0,
      status: widget.pitch?.status ?? PitchStatus.open,
      createdAt: widget.pitch?.createdAt,
    );


    if (newId == null || !mounted) return;
    final pitchId = newId;
    String? coverUrl = _coverUrl;
    String? videoUrl = _videoUrl;
    bool uploadFailed = false;


    if (_cover != null) {
      setState(() => _uploadingMedia = true);
      final url = await cubit.uploadCover(
            pitchId: pitchId,
            file: _cover!,
          );
      setState(() => _uploadingMedia = false);
      if (url == null) uploadFailed = true;
      coverUrl = url;
    }
    if (_video != null) {
      setState(() => _uploadingMedia = true);
      final url = await cubit.uploadVideo(
            pitchId: pitchId,
            file: _video!,
          );
      setState(() => _uploadingMedia = false);
      if (url == null) uploadFailed = true;
      videoUrl = url;
    }


    if (uploadFailed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image or video upload failed. Check Firebase Storage rules and CORS.'),
          backgroundColor: AppColors.error,
        ),
      );
    }


    if (_cover != null || _video != null) {
      await cubit.savePitch(
        user: user,
        pitchId: pitchId,
        title: _title.text.trim(),
        description: _description.text.trim(),
        industry: _industry,
        fundingType: _fundingType,
        pricePerShare: _fundingType == FundingType.equity
            ? double.tryParse(_pricePerShare.text)
            : null,
        fundingGoal: double.tryParse(_goal.text) ?? 0,
        coverImageUrl: coverUrl,
        videoUrl: videoUrl,
        isEditing: true,
        raised: widget.pitch?.raised ?? 0,
        status: widget.pitch?.status ?? PitchStatus.open,
        createdAt: widget.pitch?.createdAt,
      );
    }


    if (!mounted) return;
    if (_isEditing) {
      context.pop();
    } else {
      context.goNamed(AppRoute.home.name);
    }
  }


  @override
  Widget build(BuildContext context) {
    final saving = context.select((PitchCubit c) => c.state.isSaving);


    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Pitch' : 'New Pitch'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CoverPicker(
                  cover: _cover,
                  coverUrl: _coverUrl,
                  onPick: _pickCover,
                ),
                const SizedBox(height: 12),
                _VideoPicker(
                  video: _video,
                  videoUrl: _videoUrl,
                  onPick: _pickVideo,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => Validators.required(v, field: 'Title'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 5,
                  validator: (v) => Validators.required(v, field: 'Description'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _industry,
                  decoration: const InputDecoration(labelText: 'Industry'),
                  items: Industries.all
                      .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                      .toList(),
                  onChanged: (v) => setState(() => _industry = v ?? _industry),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<FundingType>(
                  initialValue: _fundingType,
                  decoration: const InputDecoration(labelText: 'Funding type'),
                  items: FundingType.values
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(f.label),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _fundingType = v ?? _fundingType),
                ),
                if (_fundingType == FundingType.equity) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pricePerShare,
                    decoration: const InputDecoration(
                      labelText: 'Price per share',
                      prefixText: '\$ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.sharesPrice,
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _goal,
                  decoration: const InputDecoration(
                    labelText: 'Funding goal',
                    prefixText: '\$ ',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.amount,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: (saving || _uploadingMedia) ? null : _save,
                  child: (saving || _uploadingMedia)
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Text(_isEditing ? 'Save changes' : 'Publish pitch'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _CoverPicker extends StatelessWidget {
  const _CoverPicker({
    required this.cover,
    required this.coverUrl,
    required this.onPick,
  });


  final XFile? cover;
  final String? coverUrl;
  final VoidCallback onPick;


  @override
  Widget build(BuildContext context) {
    final hasCover = cover != null || coverUrl != null;
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
          image: hasCover
              ? DecorationImage(
                  image: cover != null
                      ? NetworkImage(cover!.path)
                      : NetworkImage(coverUrl!) as ImageProvider,
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: hasCover
            ? const Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.edit, color: AppColors.primary),
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 32, color: AppColors.textMuted),
                  SizedBox(height: 8),
                  Text('Add cover image',
                      style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
      ),
    );
  }
}


class _VideoPicker extends StatelessWidget {
  const _VideoPicker({
    required this.video,
    required this.videoUrl,
    required this.onPick,
  });


  final XFile? video;
  final String? videoUrl;
  final VoidCallback onPick;


  @override
  Widget build(BuildContext context) {
    final hasVideo = video != null || videoUrl != null;
    return OutlinedButton.icon(
      onPressed: onPick,
      icon: Icon(hasVideo ? Icons.check_circle : Icons.video_library_outlined),
      label: Text(hasVideo ? 'Video selected' : 'Add pitch video'),
    );
  }
}

