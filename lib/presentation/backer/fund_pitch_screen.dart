import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/core/theme/colors.dart';
import 'package:openfoundry/core/utils/validators.dart';
import 'package:openfoundry/data/models/pitch.dart';
import 'package:openfoundry/data/repositories/pitch_repository.dart';
import 'package:openfoundry/logic/auth/auth_cubit.dart';
import 'package:openfoundry/logic/contribution/contribution_cubit.dart';
import 'package:openfoundry/router.dart';


class FundPitchScreen extends StatefulWidget {
  const FundPitchScreen({super.key, required this.id});
  final String id;


  @override
  State<FundPitchScreen> createState() => _FundPitchScreenState();
}


class _FundPitchScreenState extends State<FundPitchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  PaymentMethod _method = PaymentMethod.mpesa;
  Pitch? _pitch;


  @override
  void initState() {
    super.initState();
    _loadPitch();
  }


  Future<void> _loadPitch() async {
    final pitch = await PitchRepository().read(widget.id);
    if (mounted) setState(() => _pitch = pitch);
  }


  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }


  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthCubit>().currentUser;
    if (user == null || _pitch == null) return;


    context.read<ContributionCubit>().fundPitch(
          pitch: _pitch!,
          backerId: user.id,
          backerName: user.name,
          amount: double.parse(_amount.text.trim()),
          paymentMethod: _method,
        );
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<ContributionCubit, ContributionState>(
      listener: (context, state) {
        if (state.status == ContributionStatus.success ||
            state.status == ContributionStatus.failure) {
          _showResult(
            success: state.status == ContributionStatus.success,
            message: state.message,
          );
        }
      },
      child: _buildBody(),
    );
  }


  void _showResult({required bool success, String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error_outline,
              size: 48,
              color: success ? AppColors.accentSage : AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              success ? 'Payment successful!' : 'Payment failed',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message, style: const TextStyle(color: AppColors.textMuted)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (success) {
                context.goNamed(AppRoute.home.name,
                    queryParameters: {'tab': '1'});
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  Widget _buildBody() {
    final isProcessing =
        context.select((ContributionCubit c) => c.state.isProcessing);


    return Scaffold(
      appBar: AppBar(title: const Text('Fund pitch')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_pitch != null) ...[
                  Text(
                    _pitch!.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${_pitch!.entrepreneurName}',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.accentGold.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 16, color: AppColors.accentGold),
                        const SizedBox(width: 8),
                        Text(
                          _pitch!.entrepreneurPhone,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_pitch!.fundingType == FundingType.equity &&
                      _pitch!.pricePerShare != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Price per share: \$${_pitch!.pricePerShare!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ] else
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.secondary),
                  ),
                const Text('Enter amount',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amount,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$ ',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.amount,
                  autofocus: true,
                ),
                const SizedBox(height: 20),
                const Text('Payment method',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SegmentedButton<PaymentMethod>(
                  segments: [
                    ButtonSegment(
                      value: PaymentMethod.mpesa,
                      label: Text(PaymentMethod.mpesa.label),
                    ),
                    ButtonSegment(
                      value: PaymentMethod.momo,
                      label: Text(PaymentMethod.momo.label),
                    ),
                  ],
                  selected: {_method},
                  onSelectionChanged: (s) =>
                      setState(() => _method = s.first),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.secondary,
                  ),
                  onPressed: (isProcessing || _pitch == null) ? null : _submit,
                  child: isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.secondary,
                          ),
                        )
                      : const Text('Confirm payment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
