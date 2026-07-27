enum OthersDatePreset {
  all,
  today,
  yesterday,
  week,
  month,
  custom,
}

extension OthersDatePresetLabel on OthersDatePreset {
  String get label {
    switch (this) {
      case OthersDatePreset.all:
        return 'All time';
      case OthersDatePreset.today:
        return 'Today';
      case OthersDatePreset.yesterday:
        return 'Yesterday';
      case OthersDatePreset.week:
        return 'This week';
      case OthersDatePreset.month:
        return 'This month';
      case OthersDatePreset.custom:
        return 'Custom range';
    }
  }
}
