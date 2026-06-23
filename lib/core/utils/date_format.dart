const _months = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

String formatShortDate(DateTime date) {
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}
