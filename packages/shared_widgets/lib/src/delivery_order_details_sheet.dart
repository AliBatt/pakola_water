import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:models/models.dart';
import 'package:utilities/utilities.dart';

import 'app_snackbar.dart';
import 'geo/map_launcher.dart';
import 'geo/reverse_geocode.dart';
import 'order_timestamp_formatter.dart';

export 'order_timestamp_formatter.dart';

Future<void> showDeliveryOrderDetailsSheet({
  required BuildContext context,
  required DeliveryOrder order,
  OrderTimestampFormatter formatTs = DateTimeFormatter.format,
  List<Widget>? actionButtons,
  Stream<List<OrderMessage>>? messagesStream,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DeliveryOrderDetailsSheet(
      order: order,
      formatTs: formatTs,
      actionButtons: actionButtons,
      messagesStream: messagesStream,
    ),
  );
}

class DeliveryOrderDetailsSheet extends StatelessWidget {
  const DeliveryOrderDetailsSheet({
    super.key,
    required this.order,
    this.formatTs = DateTimeFormatter.format,
    this.actionButtons,
    this.messagesStream,
  });

  final DeliveryOrder order;
  final OrderTimestampFormatter formatTs;
  final List<Widget>? actionButtons;
  final Stream<List<OrderMessage>>? messagesStream;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.productName,
                    style: context.texts.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Chip(label: Text(order.status.label)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(label: 'Customer', value: order.customerName),
            _InfoRow(
              label: 'Qty / Total',
              value:
                  '${order.quantity} · Rs ${order.lineTotal.toStringAsFixed(0)} · ${order.paymentMethod.label}',
            ),
            _InfoRow(label: 'Placed', value: formatTs(order.createdAt)),
            if (order.estimatedArrivalAt != null)
              _InfoRow(
                label: 'Supervisor ETA',
                value: formatTs(order.estimatedArrivalAt),
              ),
            if (order.riderName != null)
              _InfoRow(label: 'Rider', value: order.riderName!),
            if (order.supervisorName != null)
              _InfoRow(label: 'Supervisor', value: order.supervisorName!),
            if (order.note != null && order.note!.isNotEmpty)
              _InfoRow(label: 'Note', value: order.note!),
            const Divider(height: AppSpacing.xl),
            DeliveryContactSection(order: order),
            if (actionButtons != null && actionButtons!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              ...actionButtons!,
            ],
            if (messagesStream != null) ...[
              const Divider(height: AppSpacing.xl),
              Text(
                'Messages',
                style: context.texts.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              StreamBuilder<List<OrderMessage>>(
                stream: messagesStream,
                builder: (context, snapshot) {
                  final messages = snapshot.data ?? [];
                  if (messages.isEmpty) {
                    return Text(
                      'No messages yet.',
                      style: context.texts.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    );
                  }
                  return Column(
                    children: messages.map((message) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          title: Text(message.message),
                          subtitle: Text(
                            '${message.createdByName} · ${message.type.label}'
                            '${message.createdAt != null ? ' · ${formatTs(message.createdAt)}' : ''}',
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DeliveryContactSection extends StatefulWidget {
  const DeliveryContactSection({
    super.key,
    required this.order,
    this.showPhone = true,
    this.showTitle = true,
  });

  final DeliveryOrder order;
  final bool showPhone;
  final bool showTitle;

  @override
  State<DeliveryContactSection> createState() => _DeliveryContactSectionState();
}

class _DeliveryContactSectionState extends State<DeliveryContactSection> {
  String? _resolvedAddress;
  bool _resolvingAddress = false;
  bool _openingMaps = false;

  @override
  void initState() {
    super.initState();
    _maybeResolveAddress();
  }

  @override
  void didUpdateWidget(covariant DeliveryContactSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldLoc = oldWidget.order.deliveryLocation;
    final newLoc = widget.order.deliveryLocation;
    final locationChanged = oldLoc?.latitude != newLoc?.latitude ||
        oldLoc?.longitude != newLoc?.longitude;
    final addressChanged =
        oldWidget.order.deliveryAddress != widget.order.deliveryAddress;
    if (locationChanged || addressChanged) {
      _resolvedAddress = null;
      _maybeResolveAddress();
    }
  }

  Future<void> _maybeResolveAddress() async {
    final order = widget.order;
    final location = order.deliveryLocation;
    if (location == null) return;
    if (!isCoordinateOnlyAddress(order.deliveryAddress)) return;

    setState(() => _resolvingAddress = true);
    final resolved = await reverseGeocode(
      location,
      userAgent: 'PakolaWaters/1.0 (order-delivery-contact)',
    );
    if (!mounted) return;
    setState(() {
      _resolvingAddress = false;
      _resolvedAddress = resolved;
    });
  }

  String get _addressDisplay {
    final order = widget.order;
    final resolved = _resolvedAddress?.trim();
    final stored = order.deliveryAddress?.trim();
    final base = (resolved != null && resolved.isNotEmpty)
        ? resolved
        : (stored != null &&
                stored.isNotEmpty &&
                !isCoordinateOnlyAddress(stored)
            ? stored
            : (stored != null && stored.isNotEmpty ? stored : null));

    if (base == null || base.isEmpty) {
      if (_resolvingAddress) return 'Resolving address…';
      return order.isCustomDeliveryLocation ? '(custom location)' : '—';
    }
    if (order.isCustomDeliveryLocation &&
        !base.toLowerCase().contains('custom location')) {
      return '$base (custom location)';
    }
    return base;
  }

  Future<void> _copy(BuildContext context, String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      AppSnackBar.success(context, '$label copied');
    }
  }

  Future<void> _openMaps() async {
    final location = widget.order.deliveryLocation;
    if (location == null) return;

    setState(() => _openingMaps = true);
    final opened = await openInGoogleMaps(
      location,
      label: _addressDisplay == '—' ? null : _addressDisplay,
    );
    if (!mounted) return;
    setState(() => _openingMaps = false);
    if (!opened) {
      AppSnackBar.error(context, 'Could not open Google Maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final location = order.deliveryLocation;
    final address = _addressDisplay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showTitle) ...[
          Text(
            'Delivery contact',
            style: context.texts.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (widget.showPhone &&
            order.customerPhone != null &&
            order.customerPhone!.isNotEmpty)
          _CopyableRow(
            label: 'Phone',
            value: order.customerPhone!,
            onCopy: () => _copy(context, 'Phone', order.customerPhone!),
          ),
        _CopyableRow(
          label: 'Address',
          value: address,
          onCopy: address == '—' || address == 'Resolving address…'
              ? null
              : () => _copy(context, 'Address', address),
        ),
        if (location != null) ...[
          _CopyableRow(
            label: 'Latitude',
            value: location.latitude.toString(),
            onCopy: () =>
                _copy(context, 'Latitude', location.latitude.toString()),
          ),
          _CopyableRow(
            label: 'Longitude',
            value: location.longitude.toString(),
            onCopy: () =>
                _copy(context, 'Longitude', location.longitude.toString()),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: _openingMaps ? null : _openMaps,
            icon: _openingMaps
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.map_outlined),
            label: Text(
              _openingMaps ? 'Opening Maps…' : 'Open in Google Maps',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => _copy(
              context,
              'Coordinates',
              '${location.latitude}, ${location.longitude}',
            ),
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copy lat, lng'),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.texts.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.texts.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyableRow extends StatelessWidget {
  const _CopyableRow({
    required this.label,
    required this.value,
    this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.texts.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: context.texts.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onCopy != null)
            IconButton(
              tooltip: 'Copy $label',
              onPressed: onCopy,
              icon: const Icon(Icons.copy_outlined),
            ),
        ],
      ),
    );
  }
}
