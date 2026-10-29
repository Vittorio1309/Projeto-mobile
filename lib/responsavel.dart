import 'veiculo.dart';

class Responsavel {
  static const Object _naoInformado = Object();

  final int id;
  final String cpf;
  String _nome;
  String _telefone;
  String? _email;
  final List<Veiculo> _veiculos;

  String get nome => _nome;
  set nome(String novoNome) => _nome = novoNome;
  String get telefone => _telefone;
  String? get email => _email;
  List<Veiculo> get veiculos => List<Veiculo>.unmodifiable(_veiculos);

  Responsavel({
    required this.id,
    required this.cpf,
    required String nome,
    required String telefone,
    String? email,
  }) : _nome = nome,
       _telefone = telefone,
       _email = email,
       _veiculos = <Veiculo>[];

  Responsavel._({
    required this.id,
    required this.cpf,
    required String nome,
    required String telefone,
    required String? email,
    required List<Veiculo> veiculos,
  }) : _nome = nome,
       _telefone = telefone,
       _email = email,
       _veiculos = List<Veiculo>.of(veiculos);

  void adicionarVeiculo(Veiculo veiculo) {
    if (!identical(veiculo.responsavel, this)) {
      throw ArgumentError(
        'O veículo precisa estar associado a este responsável.',
      );
    }

    if (!_veiculos.contains(veiculo)) {
      _veiculos.add(veiculo);
    }
  }

  bool removerVeiculo(Veiculo veiculo) => _veiculos.remove(veiculo);

  void substituirVeiculo(Veiculo antigo, Veiculo novo) {
    if (!identical(novo.responsavel, this)) {
      throw ArgumentError(
        'O novo veículo precisa estar associado a este responsável.',
      );
    }

    final indice = _veiculos.indexWhere((veiculo) => identical(veiculo, antigo));
    if (indice == -1) {
      throw StateError('O veículo a substituir não está na lista.');
    }
    _veiculos[indice] = novo;
  }

  List<Veiculo> listarVeiculos() => veiculos;

  void atualizarContato(String telefone, String? email) {
    _telefone = telefone;
    _email = email;
  }

  Responsavel copyWith({
    String? nome,
    String? telefone,
    Object? email = _naoInformado,
    List<Veiculo>? veiculos,
  }) {
    final copia = Responsavel._(
      id: id,
      cpf: cpf,
      nome: nome ?? _nome,
      telefone: telefone ?? _telefone,
      email: identical(email, _naoInformado) ? _email : email as String?,
      veiculos: const <Veiculo>[],
    );
    for (final veiculo in veiculos ?? _veiculos) {
      veiculo.copyWith(responsavel: copia);
    }
    return copia;
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'cpf': cpf,
    'nome': _nome,
    'telefone': _telefone,
    'email': _email,
    'veiculoPlacas': _veiculos.map((veiculo) => veiculo.placa).toList(),
  };

  factory Responsavel.fromMap(
    Map<String, dynamic> map, {
    List<Veiculo> Function(List<String> placas, Responsavel responsavel)?
    resolverVeiculos,
  }) {
    final responsavel = Responsavel(
      id: map['id'] as int,
      cpf: map['cpf'] as String,
      nome: map['nome'] as String,
      telefone: map['telefone'] as String,
      email: map['email'] as String?,
    );
    final placas = (map['veiculoPlacas'] as List<dynamic>? ?? const <dynamic>[])
        .map((placa) => placa as String)
        .toList();

    if (placas.isNotEmpty) {
      if (resolverVeiculos == null) {
        throw ArgumentError(
          'Passe resolverVeiculos para reconstruir os veículos relacionados.',
        );
      }

      for (final veiculo in resolverVeiculos(placas, responsavel)) {
        responsavel.adicionarVeiculo(veiculo);
      }
    }

    return responsavel;
  }

  @override
  String toString() =>
      'Responsavel(id: $id, cpf: $cpf, nome: $_nome, telefone: $_telefone, '
      'email: $_email, veiculos: ' +
      _veiculos.length.toString() +
      ')';
}
