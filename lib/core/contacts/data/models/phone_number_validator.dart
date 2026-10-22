import 'package:cellphone_validator/cellphone_validator.dart';

/// Validates international phone numbers such as `+56 9 1111 2222`.
///
/// Lives in `data` because `cellphone_validator` depends on Flutter, which
/// `domain` must not import.
class PhoneNumberValidator {
  const PhoneNumberValidator._();

  static String? validate(String value) {
    final phone = value.trim();
    if (!phone.startsWith('+')) {
      return 'Phone "$value" must start with the country code, e.g. +56';
    }

    final validator = PhoneValidator(lang: 'es');
    // getCountryByPhone sorts the list it receives, so hand it a copy.
    final country = validator.getCountryByPhone([
      ...CellPhoneValidator.countries,
    ], phone);
    if (country == null) {
      return 'Phone "$value" has an unsupported country code';
    }

    final national = phone
        .replaceAll(RegExp(r'\D'), '')
        .substring(country.dialCode.length);
    return validator.checkPhonePattern(national, country)
        ? null
        : 'Phone "$value" is not a valid ${country.countryName} number';
  }
}
