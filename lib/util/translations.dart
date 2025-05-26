import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'MP3 Player': 'MP3 Player',
          'Pick Audio File': 'Pick Audio File',
          'No song loaded': 'No song loaded',
        },
        'km_KH': {
          'MP3 Player': 'កម្មវិធីចាក់បទភ្លេង MP3',
          'Pick Audio File': 'ជ្រើសរើសឯកសារសំឡេង',
          'No song loaded': 'មិនមានបទភ្លេងទេ',
        },
      };
}
