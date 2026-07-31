
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/core/theme/colors.dart';
import 'package:openfoundry/data/models/pitch.dart';
import 'package:openfoundry/data/repositories/pitch_repository.dart';
import 'package:openfoundry/logic/auth/auth_cubit.dart';
import 'package:openfoundry/presentation/common/widgets/funding_progress_bar.dart';
import 'package:openfoundry/router.dart';

class PitchDetailScreen extends StatelessWidget {
  const PitchDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pitch')),
      body: StreamBuilder<Pitch?>(
        stream: PitchRepository().watchSingle(id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }
          final pitch = snap.data;
          if (pitch == null) {
            return const Center(
              child: Text('Pitch not found',
                  style: TextStyle(color: AppColors.textMuted)),
            );
          }
          final user = context.read<AuthCubit>().currentUser;
          final isBacker = user?.role == UserRole.backer;
          final isOwner = user?.id == pitch.entrepreneurId;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: _PitchDetailContent(pitch: pitch, isOwner: isOwner),
                ),
              ),
              if (isBacker && pitch.status == PitchStatus.open)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border:
                        Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: AppColors.secondary,
                      ),
                      onPressed: () => context.pushNamed(
                        AppRoute.fundPitch.name,
                        pathParameters: {'id': pitch.id},
                      ),
                      icon: const Icon(Icons.handshake),
                      label: const Text('Fund this pitch'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PitchDetailContent extends StatelessWidget {
  const _PitchDetailContent({required this.pitch, required this.isOwner});
  final Pitch pitch;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pitch.coverImageUrl != null)
          Image.network(
            pitch.coverImageUrl!,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 220,
                color: AppColors.surfaceMuted,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.secondary,
                  ),
                ),
              );
            },
            errorBuilder: (_, _, _) => Container(
              height: 220,
              color: AppColors.surfaceMuted,
            ),
          )
        else
          Container(
            height: 160,
            color: AppColors.surfaceMuted,
            child: const Center(
              child:
                  Icon(Icons.image, size: 48, color: AppColors.textMuted),
            ),
          ),
        if (pitch.videoUrl != null)
          _VideoPlayerWidget(url: pitch.videoUrl!),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      pitch.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  _StatusChip(status: pitch.status),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _InfoChip(
                      label: pitch.industry, icon: Icons.business),
                  const SizedBox(width: 8),
                  _InfoChip(
                    label: pitch.fundingType.label,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('About this pitch',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 6),
              Text(pitch.description,
                  style:
                      const TextStyle(fontSize: 14, height: 1.5)),
              if (pitch.fundingType == FundingType.equity &&
                  pitch.pricePerShare != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Price per share: \$${pitch.pricePerShare!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGold,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text('Funding progress',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              FundingProgressBar(
                  raised: pitch.raised, goal: pitch.fundingGoal),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Raised: \$${pitch.raised.toStringAsFixed(0)}'),
                  Text(
                      'Goal: \$${pitch.fundingGoal.toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                  '${(pitch.progress * 100).toStringAsFixed(0)}% funded',
                  style: const TextStyle(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              const Text('Entrepreneur',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              _ContactTile(
                icon: Icons.person,
                label: pitch.entrepreneurName,
              ),
              _ContactTile(
                icon: Icons.email_outlined,
                label: pitch.entrepreneurEmail,
              ),
              _ContactTile(
                icon: Icons.phone_outlined,
                label: pitch.entrepreneurPhone,
              ),
              if (isOwner) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.pushNamed(
                    AppRoute.pitchEdit.name,
                    pathParameters: {'id': pitch.id},
                    extra: pitch,
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit pitch'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accentGold),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final PitchStatus status;

  @override
  Widget build(BuildContext context) {
    final open = status == PitchStatus.open;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: open ? AppColors.accentGold : AppColors.accentSage,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        open ? 'Open' : 'Funded',
        style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  const _VideoPlayerWidget({required this.url});
  final String url;

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() => _initialized = true);
      }).catchError((_) {
        if (mounted) setState(() => _hasError = true);
      });
    _controller.setVolume(1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text('Unable to load video',
              style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }
    if (!_initialized) {
      return const SizedBox(
        height: 200,
        child: Center(
            child: CircularProgressIndicator(color: AppColors.secondary)),
      );
    }
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(32),
            ),
            child: IconButton(
              iconSize: 42,
              color: AppColors.primary,
              icon: Icon(
                _controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

