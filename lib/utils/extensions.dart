extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

extension AppDateExtension on DateTime {
  DateTime getDateOnly() {
    return DateTime(year, month, day);
  }
}

extension FormValidations on String {
  String? validEmail() {
    return RegExp(
                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
            .hasMatch(this)
        ? null
        : "E-mail inválido.";
  }

  String? validPassword() {
    return RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(this)
        ? null
        : "Senha inválida. Deve possuir pelo menos 8 caracteres, com letras e dígitos.";
  }
}
