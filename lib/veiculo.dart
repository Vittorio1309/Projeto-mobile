import 'atendimento.dart';
import 'responsavel.dart';

class Veiculo {
  static const Object _naoInformado = Object();

  final String placa;
  final String marca;
  final String modelo;
  final int ano;
  String? _cor;
  Responsavel _responsavel;
  final List<Atendimento> _atendimentos;

  String? get cor => _cor;
  set cor(String? novaCor) => _cor = novaCor;

  Responsavel get responsavel => _responsavel;
  set responsavel(Responsavel novoResponsavel) {
    if (identical(_responsavel, novoResponsavel)) {
      return;
    }

    _responsavel.removerVeiculo(this);
    _responsavel = novoResponsavel;
    _responsavel.adicionarVeiculo(this);
  }

  List<Atendimento> get atendimentos =>
      List<Atendimento>.unmodifiable(_atendimentos);

  Veiculo({
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.ano,
    required Responsavel responsavel,
    String? cor,
  }) : _responsavel = responsavel,
       _cor = cor,
       _atendimentos = <Atendimento>[] {
    _responsavel.adicionarVeiculo(this);
  }

  Veiculo._({
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.ano,
    required Responsavel responsavel,
    required String? cor,
    required List<Atendimento> atendimentos,
  }) : _responsavel = responsavel,
       _cor = cor,
       _atendimentos = List<Atendimento>.of(atendimentos);

  void adicionarAtendimento(Atendimento atendimento) {
    if (!identical(atendimento.veiculo, this)) {
      throw ArgumentError('O atendimento precisa pertencer a este veículo.');
    }
    if (_atendimentos.any((item) => item.id == atendimento.id)) {
      throw StateError('Já existe um atendimento com este identificador.');
    }

    _atendimentos.add(atendimento);
  }

  void substituirAtendimento(Atendimento atendimento) {
    if (!identical(atendimento.veiculo, this)) {
      throw ArgumentError('O atendimento precisa pertencer a este veículo.');
    }

    final indice = _atendimentos.indexWhere((item) => item.id == atendimento.id);
    if (indice == -1) {
      throw StateError('O atendimento a substituir não está no histórico.');
    }
    _atendimentos[indice] = atendimento;
  }

  String identificacao() => '$placa - $modelo $ano';

  List<Atendimento> consultarHistorico() => atendimentos;

  Veiculo copyWith({
    Responsavel? responsavel,
    Object? cor = _naoInformado,
    List<Atendimento>? atendimentos,
  }) {
    final novoResponsavel = responsavel ?? _responsavel;
    final copia = Veiculo._(
      placa: placa,
      marca: marca,
      modelo: modelo,
      ano: ano,
      responsavel: novoResponsavel,
      cor: identical(cor, _naoInformado) ? _cor : cor as String?,
      atendimentos: const <Atendimento>[],
    );
    for (final atendimento in atendimentos ?? _atendimentos) {
      copia.adicionarAtendimento(atendimento.copiarParaVeiculo(copia));
    }

    if (identical(novoResponsavel, _responsavel)) {
      _responsavel.substituirVeiculo(this, copia);
    } else {
      novoResponsavel.adicionarVeiculo(copia);
    }
    return copia;
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'placa': placa,
    'marca': marca,
    'modelo': modelo,
    'ano': ano,
    'cor': _cor,
    'idResponsavel': _responsavel.id,
    'atendimentoIds': _atendimentos.map((item) => item.id).toList(),
  };

  factory Veiculo.fromMap(
    Map<String, dynamic> map, {
    required Responsavel responsavel,
    List<Atendimento> Function(List<int> ids, Veiculo veiculo)?
    resolverAtendimentos,
  }) {
    if (map['idResponsavel'] != responsavel.id) {
      throw ArgumentError(
        'O idResponsavel do mapa não corresponde ao responsável informado.',
      );
    }

    final veiculo = Veiculo(
      placa: map['placa'] as String,
      marca: map['marca'] as String,
      modelo: map['modelo'] as String,
      ano: map['ano'] as int,
      cor: map['cor'] as String?,
      responsavel: responsavel,
    );
    final ids =
        (map['atendimentoIds'] as List<dynamic>? ?? const <dynamic>[])
            .map((id) => (id as num).toInt())
            .toList();

    if (ids.isNotEmpty) {
      if (resolverAtendimentos == null) {
        throw ArgumentError(
          'Passe resolverAtendimentos para reconstruir o histórico.',
        );
      }

      for (final atendimento in resolverAtendimentos(ids, veiculo)) {
        if (!_containsAtendimento(veiculo, atendimento.id)) {
          veiculo.adicionarAtendimento(atendimento);
        }
      }
    }

    return veiculo;
  }

  static bool _containsAtendimento(Veiculo veiculo, int id) =>
      veiculo._atendimentos.any((item) => item.id == id);

  @override
  String toString() =>
      'Veiculo(placa: $placa, marca: $marca, modelo: $modelo, ano: $ano, '
      'cor: $_cor, responsavelId: ' +
      _responsavel.id.toString() +
      ', atendimentos: ' +
      _atendimentos.length.toString() +
      ')';
}
