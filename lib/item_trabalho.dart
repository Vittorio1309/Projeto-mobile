import 'tipo_trabalho.dart';

class ItemTrabalho {
  final TipoTrabalho tipo;
  final double valorCobrado;

  ItemTrabalho(this.tipo) : valorCobrado = tipo.valorPadrao;

  ItemTrabalho._({required this.tipo, required this.valorCobrado}) {
    if (!valorCobrado.isFinite || valorCobrado < 0) {
      throw ArgumentError.value(
        valorCobrado,
        'valorCobrado',
        'O valor cobrado deve ser finito e não negativo.',
      );
    }
  }

  double subtotal() => valorCobrado;

  // Tipo e valor são imutáveis após o lançamento do trabalho.
  ItemTrabalho copyWith() =>
      ItemTrabalho._(tipo: tipo, valorCobrado: valorCobrado);

  Map<String, dynamic> toMap() => <String, dynamic>{
    'tipoTrabalho': tipo.toMap(),
    'valorCobrado': valorCobrado,
  };

  factory ItemTrabalho.fromMap(
    Map<String, dynamic> map, {
    TipoTrabalho Function(int id)? resolverTipoTrabalho,
  }) {
    final dadosTipo = map['tipoTrabalho'];
    if (dadosTipo is! Map) {
      throw FormatException('tipoTrabalho deve ser um mapa.');
    }
    final mapaTipo = Map<String, dynamic>.from(dadosTipo);
    final idTipo = mapaTipo['id'] as int;
    final tipo =
        resolverTipoTrabalho?.call(idTipo) ?? TipoTrabalho.fromMap(mapaTipo);

    return ItemTrabalho._(
      tipo: tipo,
      valorCobrado: (map['valorCobrado'] as num).toDouble(),
    );
  }

  @override
  String toString() =>
      'ItemTrabalho(tipoId: ' +
      tipo.id.toString() +
      ', valorCobrado: ' +
      valorCobrado.toString() +
      ')';
}
