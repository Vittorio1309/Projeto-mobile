class TipoTrabalho {
  final int id;
  final String descricao;
  double _valorPadrao;

  double get valorPadrao => _valorPadrao;

  TipoTrabalho({
    required this.id,
    required this.descricao,
    required double valorPadrao,
  }) : _valorPadrao = _validarValor(valorPadrao);

  void reajustarValor(double novoValor) {
    _valorPadrao = _validarValor(novoValor);
  }

  TipoTrabalho copyWith({double? valorPadrao}) {
    return TipoTrabalho(
      id: id,
      descricao: this.descricao,
      valorPadrao: valorPadrao ?? _valorPadrao,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'descricao': descricao,
    'valorPadrao': _valorPadrao,
  };

  factory TipoTrabalho.fromMap(Map<String, dynamic> map) {
    return TipoTrabalho(
      id: map['id'] as int,
      descricao: map['descricao'] as String,
      valorPadrao: (map['valorPadrao'] as num).toDouble(),
    );
  }

  static double _validarValor(double valor) {
    if (!valor.isFinite || valor < 0) {
      throw ArgumentError.value(
        valor,
        'valor',
        'O valor do trabalho deve ser finito e não negativo.',
      );
    }

    return valor;
  }

  @override
  String toString() =>
      'TipoTrabalho(id: $id, descricao: $descricao, '
      'valorPadrao: $_valorPadrao)';
}
