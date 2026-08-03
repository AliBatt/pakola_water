import 'package:l10n/l10n.dart';
import 'package:models/models.dart';

extension SupportRequestStatusL10n on SupportRequestStatus {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case SupportRequestStatus.open:
        return l10n.supportStatusOpen;
      case SupportRequestStatus.inProgress:
        return l10n.supportStatusInProgress;
      case SupportRequestStatus.completed:
        return l10n.supportStatusCompleted;
      case SupportRequestStatus.rejected:
        return l10n.supportStatusRejected;
      case SupportRequestStatus.closed:
        return l10n.supportStatusClosed;
    }
  }
}
