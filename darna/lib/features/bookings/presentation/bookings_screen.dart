import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../auth/data/auth_repository.dart';
import '../../home/presentation/auth_provider.dart';
import '../../listings/data/property_repository.dart';
import '../../payments/data/payment_repository.dart';
import '../../payments/models/payment.dart';
import '../../payments/presentation/receipt_sheet.dart';
import '../data/booking_repository.dart';
import '../models/booking.dart';

/// Students see the requests they sent; owners see the ones they received
/// and can accept or refuse them.
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final isOwner = user.role == 'owner';
    final repo = BookingRepository();
    return Scaffold(
      appBar: AppBar(
          title: Text(isOwner ? 'Demandes reçues' : 'Mes demandes')),
      body: ListenableBuilder(
        listenable: Listenable.merge(
            [repo.listenable(), PaymentRepository().listenable()]),
        builder: (context, _) {
          final items =
              isOwner ? repo.forOwner(user.id) : repo.forStudent(user.id);
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.event_note_outlined,
              title: 'Aucune demande',
              message: isOwner
                  ? 'Les demandes de visite et de réservation des étudiants apparaîtront ici.'
                  : 'Quand tu demandes une visite ou une réservation, tu pourras suivre son statut ici.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                _BookingCard(booking: items[i], isOwner: isOwner),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isOwner;
  const _BookingCard({required this.booking, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final repo = BookingRepository();
    final property = PropertyRepository().byId(booking.propertyId);
    final other = AuthRepository()
        .userById(isOwner ? booking.studentId : booking.ownerId);
    final accepted = booking.status == BookingStatus.accepted;
    final pending = booking.status == BookingStatus.pending;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: property == null
            ? null
            : () => context.push('/property/${property.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (property != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: PropertyCover(property: property, height: 56),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(property?.title ?? 'Annonce supprimée',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          '${booking.kindLabel} · ${formatDate(booking.date)}',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                      label: BookingStatus.label(booking.status),
                      color: statusColor(booking.status)),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  UserAvatar(name: other?.fullName ?? '?', radius: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${isOwner ? 'Étudiant·e' : 'Propriétaire'} : ${other?.fullName ?? '—'}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        if (accepted && other != null)
                          Text('📞 +216 ${other.phone}',
                              style:
                                  const TextStyle(color: AppColors.success)),
                      ],
                    ),
                  ),
                ],
              ),
              if (booking.message.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('« ${booking.message} »',
                      style: const TextStyle(fontStyle: FontStyle.italic)),
                ),
              ],
              // Visits can be paid too: after visiting, the student pays the
              // first month to secure the place.
              if (accepted)
                _PaymentSection(booking: booking, isOwner: isOwner),
              if (pending) ...[
                const SizedBox(height: 12),
                if (isOwner)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              repo.setStatus(booking, BookingStatus.rejected),
                          child: const Text('Refuser'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                              minimumSize: const Size(64, 48)),
                          onPressed: () =>
                              repo.setStatus(booking, BookingStatus.accepted),
                          child: const Text('Accepter'),
                        ),
                      ),
                    ],
                  )
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        final ok = await confirmDialog(context,
                            'Annuler la demande ?', 'Le propriétaire en sera informé.');
                        if (ok) {
                          await repo.setStatus(
                              booking, BookingStatus.cancelled);
                        }
                      },
                      child: const Text('Annuler la demande'),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Payment state of an accepted reservation: a pay button for the student,
/// the status (and cash confirmation) for the owner.
class _PaymentSection extends StatelessWidget {
  final Booking booking;
  final bool isOwner;
  const _PaymentSection({required this.booking, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final repo = PaymentRepository();
    final payment = repo.forBooking(booking.id);

    if (payment == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: isOwner
            ? const Row(
                children: [
                  Icon(Icons.hourglass_empty, size: 18, color: AppColors.muted),
                  SizedBox(width: 6),
                  Text("En attente du paiement de l'étudiant·e",
                      style: TextStyle(color: AppColors.muted)),
                ],
              )
            : SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/pay/${booking.id}'),
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Payer et confirmer'),
                ),
              ),
      );
    }

    final cash = payment.status == PaymentStatus.cashPending;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
        decoration: BoxDecoration(
          color: (cash ? AppColors.warning : AppColors.success)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(cash ? Icons.payments_outlined : Icons.check_circle,
                size: 20, color: cash ? AppColors.warning : AppColors.success),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                cash
                    ? "Espèces à l'arrivée · ${formatPrice(payment.amount)}"
                    : 'Payé · ${formatPrice(payment.amount)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (isOwner && cash)
              TextButton(
                onPressed: () => repo.confirmCash(payment),
                child: const Text('Reçu'),
              ),
            TextButton(
              onPressed: () => showReceipt(context, payment),
              child: const Text('Voir le reçu'),
            ),
          ],
        ),
      ),
    );
  }
}
