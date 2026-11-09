import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../auth/data/auth_repository.dart';
import '../../listings/data/property_repository.dart';
import '../models/payment.dart';

/// Shows a payment receipt. [success] adds the "payment done" header used
/// right after paying.
Future<void> showReceipt(BuildContext context, Payment payment,
        {bool success = false}) =>
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.cream,
      builder: (_) => _ReceiptSheet(payment: payment, success: success),
    );

class _ReceiptSheet extends StatelessWidget {
  final Payment payment;
  final bool success;
  const _ReceiptSheet({required this.payment, required this.success});

  @override
  Widget build(BuildContext context) {
    final property = PropertyRepository().byId(payment.propertyId);
    final owner = AuthRepository().userById(payment.ownerId);
    final student = AuthRepository().userById(payment.studentId);
    final cash = payment.status == PaymentStatus.cashPending;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (cash ? AppColors.warning : AppColors.success)
                    .withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(cash ? Icons.schedule : Icons.check_rounded,
                  size: 40,
                  color: cash ? AppColors.warning : AppColors.success),
            ),
            const SizedBox(height: 12),
            Text(
              success
                  ? (cash ? 'Réservation confirmée !' : 'Paiement réussi 🎉')
                  : 'Reçu de paiement',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              cash
                  ? 'Paiement de ${formatPrice(payment.amount)} à remettre au propriétaire.'
                  : '${formatPrice(payment.amount)} payés au propriétaire.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _Row('Référence', payment.reference),
                    _Row('Date',
                        DateFormat('d MMM yyyy · HH:mm', 'fr').format(payment.createdAt)),
                    _Row('Logement', property?.title ?? '—'),
                    _Row('Propriétaire', owner?.fullName ?? '—'),
                    _Row('Étudiant·e', student?.fullName ?? '—'),
                    _Row('Moyen', PaymentMethod.label(payment.method)),
                    if (payment.detail != null) _Row('Détail', payment.detail!),
                    _Row('Statut', PaymentStatus.label(payment.status)),
                    const Divider(height: 24),
                    _Row('Montant', formatPrice(payment.amount), bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _Row(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(color: AppColors.muted)),
            ),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                      fontSize: bold ? 17 : 14,
                      color: bold ? AppColors.roseDark : AppColors.plum)),
            ),
          ],
        ),
      );
}
