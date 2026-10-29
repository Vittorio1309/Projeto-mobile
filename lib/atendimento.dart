import 'item_trabalho.dart';
import 'situacao_atendimento.dart';
import 'tipo_trabalho.dart';
import 'veiculo.dart';

class Atendimento {
  static const int quantidadeMinimaTrabalhosParaConcluir = 1;
  static const SituacaoAtendimento situacaoInicial =
      SituacaoAtendimento.aberto;
  static const Object _naoInformado = Object();

  final int id;
  final DateTime dataEntrada;
  final String problemaRelatado;
  final Veiculo veiculo;
  SituacaoAtendimento _situacao;
  DateTime? _dataConclusao;
  final List<ItemTrabalho> _itens;

  SituacaoAtendimento get situacao => _situacao;
  DateTime? get dataConclusao => _dataConclusao;
  List<ItemTrabalho> get itens => List<ItemTrabalho>.unmodifiable(_itens);

  factory Atendimento({
    required int id,
    required Veiculo veiculo,
    required String problemaRelatado,
    DateTime? dataEntrada,
  }) {
    return Atendimento._(
      id: id,
      veiculo: veiculo,
      problemaRelatado: problemaRelatado,
      dataEntrada: dataEntrada ?? DateTime.now(),
      situacao: situacaoInicial,
      dataConclusao: null,
      itens: const <ItemTrabalho>[],
    );
  }

  Atendimento._({
    required this.id,
    required this.veiculo,
    required this.problemaRelatado,
    required this.dataEntrada,
    required SituacaoAtendimento situacao,
    required DateTime? dataConclusao,
    required List<ItemTrabalho> itens,
    bool registrarNoVeiculo = true,
  }) : _situacao = situacao,
       _dataConclusao = dataConclusao,
       _itens = List<ItemTrabalho>.of(itens) {
    if (situacao == SituacaoAtendimento.concluido) {
      if (_itens.isEmpty) {
        throw StateError('Um atendimento concluído precisa ter um trabalho.');
      }
      if (_dataConclusao == null) {
        throw StateError(
          'Um atendimento concluído precisa ter data de conclusão.',
        );
      }
    }
    final idsTipos = <int>{};
    for (final item in _itens) {
      if (!idsTipos.add(item.tipo.id)) {
        throw StateError(
          'Um atendimento não pode conter o mesmo tipo de trabalho duas vezes.',
        );
      }
    }
    if (registrarNoVeiculo) {
      veiculo.adicionarAtendimento(this);
    }
  }

  void adicionarTrabalho(TipoTrabalho tipo) {
    if (_situacao == SituacaoAtendimento.concluido) {
      throw StateError('Não é possível alterar um atendimento concluído.');
    }
    if (_itens.any((item) => item.tipo.id == tipo.id)) {
      throw StateError('Este trabalho já foi adicionado ao atendimento.');
    }

    _itens.add(ItemTrabalho(tipo));
  }

  bool removerTrabalho(TipoTrabalho tipo) {
    if (_situacao == SituacaoAtendimento.concluido) {
      return false;
    }

    final indice = _itens.indexWhere((item) => item.tipo.id == tipo.id);
    if (indice == -1) {
      return false;
    }

    _itens.removeAt(indice);
    return true;
  }

  double calcularValorTotal() {
    var total = 0.0;
    for (final item in _itens) {
      total += item.subtotal();
    }
    return total;
  }

  void alterarSituacao(SituacaoAtendimento nova) {
    if (nova == SituacaoAtendimento.concluido) {
      if (!podeSerConcluido()) {
        throw StateError(
          'Adicione ao menos um trabalho antes de concluir o atendimento.',
        );
      }
      if (_situacao != SituacaoAtendimento.concluido) {
        _dataConclusao = DateTime.now();
      }
    }

    _situacao = nova;
  }

  bool estaEmAndamento() =>
      _situacao != SituacaoAtendimento.concluido &&
      _situacao != SituacaoAtendimento.cancelado;

  bool podeSerConcluido() =>
      _itens.length >= quantidadeMinimaTrabalhosParaConcluir;

  String resumo() {
    final total = calcularValorTotal().toStringAsFixed(2).replaceAll('.', ',');
    return veiculo.identificacao() +
        ' | Resp.: ' +
        veiculo.responsavel.nome +
        ' | Situação: ' +
        _situacao.name +
        ' | Total: R\$ ' +
        total;
  }

  Atendimento copyWith({
    SituacaoAtendimento? situacao,
    Object? dataConclusao = _naoInformado,
    bool limparDataConclusao = false,
    List<ItemTrabalho>? itens,
  }) {
    final novosItens = itens ?? _itens;
    final novaSituacao = situacao ?? _situacao;

    if (novaSituacao == SituacaoAtendimento.concluido &&
        novosItens.isEmpty) {
      throw StateError(
        'Um atendimento não pode ser copiado como concluído sem trabalho.',
      );
    }

    DateTime? novaDataConclusao;
    if (limparDataConclusao) {
      novaDataConclusao = null;
    } else if (!identical(dataConclusao, _naoInformado)) {
      novaDataConclusao = dataConclusao as DateTime?;
    } else if (novaSituacao == SituacaoAtendimento.concluido &&
        _situacao != SituacaoAtendimento.concluido) {
      novaDataConclusao = DateTime.now();
    } else {
      novaDataConclusao = _dataConclusao;
    }
    if (novaSituacao == SituacaoAtendimento.concluido &&
        novaDataConclusao == null) {
      throw StateError(
        'Um atendimento concluído precisa ter data de conclusão.',
      );
    }

    final copia = Atendimento._(
      id: id,
      veiculo: veiculo,
      problemaRelatado: problemaRelatado,
      dataEntrada: dataEntrada,
      situacao: novaSituacao,
      dataConclusao: novaDataConclusao,
      itens: novosItens,
      registrarNoVeiculo: false,
    );
    veiculo.substituirAtendimento(copia);
    return copia;
  }

  Atendimento copiarParaVeiculo(Veiculo novoVeiculo) {
    return Atendimento._(
      id: id,
      veiculo: novoVeiculo,
      problemaRelatado: problemaRelatado,
      dataEntrada: dataEntrada,
      situacao: _situacao,
      dataConclusao: _dataConclusao,
      itens: _itens,
      registrarNoVeiculo: false,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'dataEntrada': dataEntrada.toIso8601String(),
    'problemaRelatado': problemaRelatado,
    'placaVeiculo': veiculo.placa,
    'situacao': _situacao.name,
    'dataConclusao': _dataConclusao?.toIso8601String(),
    'itens': _itens.map((item) => item.toMap()).toList(),
  };

  factory Atendimento.fromMap(
    Map<String, dynamic> map, {
    required Veiculo veiculo,
    TipoTrabalho Function(int id)? resolverTipoTrabalho,
  }) {
    if (map['placaVeiculo'] != veiculo.placa) {
      throw ArgumentError(
        'A placa do mapa não corresponde ao veículo informado.',
      );
    }

    final nomeSituacao = map['situacao'] as String;
    final situacao = SituacaoAtendimento.values.firstWhere(
      (valor) => valor.name == nomeSituacao,
      orElse: () => throw FormatException(
        'Situação de atendimento inválida: ' + nomeSituacao,
      ),
    );
    final itens = (map['itens'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) {
          if (item is! Map) {
            throw FormatException('Cada item do atendimento deve ser um mapa.');
          }
          return ItemTrabalho.fromMap(
            Map<String, dynamic>.from(item),
            resolverTipoTrabalho: resolverTipoTrabalho,
          );
        })
        .toList();

    return Atendimento._(
      id: map['id'] as int,
      veiculo: veiculo,
      problemaRelatado: map['problemaRelatado'] as String,
      dataEntrada: DateTime.parse(map['dataEntrada'] as String),
      situacao: situacao,
      dataConclusao: map['dataConclusao'] == null
          ? null
          : DateTime.parse(map['dataConclusao'] as String),
      itens: itens,
    );
  }

  @override
  String toString() => 'Atendimento(' + resumo() + ')';
}
