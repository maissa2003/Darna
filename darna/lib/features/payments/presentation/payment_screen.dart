import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../bookings/data/booking_repository.dart';
import '../../bookings/models/booking.dart';
import '../../listings/data/property_repository.dart';
import '../data/payment_repository.dart';
import '../models/payment.dart';
import 'receipt_sheet.dart';

/// Pays the first month of an accepted reservation.
class PaymentScreen extends StatefulWidget {
  final String bookingId;
  const PaymentScreen({super.key, required this.bookingId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumber = TextEditingController();
  final _cardName = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  final _walletPhone = TextEditingController();
  String _method = PaymentMethod.card;
  String _wallet = 'D17';
  bool _paying = false;

  @override
  void dispose() {
    for (final c in [_cardNumber, _cardName, _expiry, _cvv, _walletPhone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pay(Booking booking, int amount) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _paying = true);
    final digits = _cardNumber.text.replaceAll(' ', '');
    final detail = switch (_method) {
      PaymentMethod.card => '•••• ${digits.substring(digits.length - 4)}',
      PaymentMethod.wallet => '$_wallet · +216 ${_walletPhone.text.trim()}',
      _ => null,
    };
    final payment = await PaymentRepository()
        .pay(booking: booking, amount: amount, method: _method, detail: detail);
    if (!mounted) return;
    await showReceipt(context, payment, success: true);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final booking = BookingRepository().byId(widget.bookingId);
    final property =
        booking == null ? null : PropertyRepository().byId(booking.propertyId);
    if (booking == null || property == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Réservation introuvable',
            message: 'Elle a peut-être été supprimée.'),
      );
    }
    final amount = property.price;

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            const _DemoBanner(),
            const SizedBox(height: 16),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child:
                                PropertyCover(property: property, height: 60),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(property.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text('Emménagement : ${formatDate(booking.date)}',
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    _Line('Loyer du 1er mois', formatPrice(amount)),
                    const SizedBox(height: 6),
                    const _Line('Frais de service Darna', 'Offerts'),
                    const Divider(height: 24),
                    _Line('Total', formatPrice(amount), bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle('Moyen de paiement'),
            _MethodTile(
              icon: Icons.credit_card,
              title: 'Carte bancaire',
              subtitle: 'Visa, Mastercard, carte CIB / e-Dinar',
              selected: _method == PaymentMethod.card,
              onTap: () => setState(() => _method = PaymentMethod.card),
            ),
            _MethodTile(
              icon: Icons.phone_iphone,
              title: 'Portefeuille mobile',
              subtitle: 'D17, Flouci',
              selected: _method == PaymentMethod.wallet,
              onTap: () => setState(() => _method = PaymentMethod.wallet),
            ),
            _MethodTile(
              icon: Icons.payments_outlined,
              title: 'Espèces',
              subtitle: 'À payer au propriétaire à la remise des clés',
              selected: _method == PaymentMethod.cash,
              onTap: () => setState(() => _method = PaymentMethod.cash),
            ),
            const SizedBox(height: 16),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: switch (_method) {
                PaymentMethod.card => _cardForm(),
                PaymentMethod.wallet => _walletForm(),
                _ => const _InfoBox(
                    icon: Icons.handshake_outlined,
                    text:
                        'Ta réservation sera confirmée et tu paieras le propriétaire en main propre le jour de ton arrivée. Demande-lui un reçu.',
                  ),
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _paying ? null : () => _pay(booking, amount),
              icon: _paying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Icon(_method == PaymentMethod.cash
                      ? Icons.check
                      : Icons.lock_outline),
              label: Text(_paying
                  ? 'Paiement en cours…'
                  : _method == PaymentMethod.cash
                      ? 'Confirmer la réservation'
                      : 'Payer ${formatPrice(amount)}'),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_outlined,
                    size: 16, color: AppColors.muted),
                SizedBox(width: 6),
                Text('Paiement sécurisé · données de carte jamais stockées',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardForm() => Column(
        children: [
          TextFormField(
            controller: _cardNumber,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            decoration: const InputDecoration(
              labelText: 'Numéro de carte',
              hintText: '0000 0000 0000 0000',
              prefixIcon: Icon(Icons.credit_card),
            ),
            validator: (v) {
              final digits = (v ?? '').replaceAll(' ', '');
              if (digits.length != 16) return 'Le numéro doit avoir 16 chiffres';
              if (!_luhnValid(digits)) return 'Numéro de carte invalide';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _cardName,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Nom sur la carte',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                (v == null || v.trim().length < 3) ? 'Nom obligatoire' : null,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiry,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryFormatter(),
                  ],
                  decoration: const InputDecoration(
                      labelText: 'Expiration', hintText: 'MM/AA'),
                  validator: _validateExpiry,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvv,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: const InputDecoration(
                      labelText: 'CVV', hintText: '123'),
                  validator: (v) =>
                      (v ?? '').length == 3 ? null : '3 chiffres',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _InfoBox(
            icon: Icons.science_outlined,
            text:
                'Mode démo : utilise la carte de test 4242 4242 4242 4242, une date future et n\'importe quel CVV.',
          ),
        ],
      );

  Widget _walletForm() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final w in ['D17', 'Flouci'])
                ChoiceChip(
                  label: Text(w),
                  selected: _wallet == w,
                  onSelected: (_) => setState(() => _wallet = w),
                ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _walletPhone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            decoration: InputDecoration(
              labelText: 'Numéro lié à $_wallet',
              prefixText: '+216 ',
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            validator: (v) => RegExp(r'^\d{8}$').hasMatch(v ?? '')
                ? null
                : 'Numéro invalide (8 chiffres)',
          ),
          const SizedBox(height: 10),
          _InfoBox(
            icon: Icons.notifications_active_outlined,
            text:
                'Tu recevras une demande de confirmation dans l\'application $_wallet (simulée en mode démo).',
          ),
        ],
      );

  String? _validateExpiry(String? v) {
    final parts = (v ?? '').split('/');
    if (parts.length != 2 || parts[1].length != 2) return 'Format MM/AA';
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null || month < 1 || month > 12) {
      return 'Date invalide';
    }
    final now = DateTime.now();
    // Cards are valid until the end of their expiry month.
    final endOfMonth = DateTime(2000 + year, month + 1);
    if (!endOfMonth.isAfter(now)) return 'Carte expirée';
    return null;
  }

  static bool _luhnValid(String digits) {
    var sum = 0;
    for (var i = 0; i < digits.length; i++) {
      var d = int.parse(digits[digits.length - 1 - i]);
      if (i.isOdd) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
    }
    return sum % 10 == 0;
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
        text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    final text = digits.length > 2
        ? '${digits.substring(0, 2)}/${digits.substring(2)}'
        : digits;
    return TextEditingValue(
        text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.warning),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Version de démonstration : aucun argent n\'est débité.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _Line(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 17 : 14,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: bold ? AppColors.roseDark : AppColors.plum,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: selected ? AppColors.blush : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: selected ? AppColors.rose : const Color(0xFFEBD6D8),
                width: selected ? 1.6 : 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(icon,
                      color: selected ? AppColors.roseDark : AppColors.muted),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        Text(subtitle,
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected ? AppColors.rose : AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoBox({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.peachLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.roseDark),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );
}
