//tarefa.dart representa o registro que será armazenado na tabela
class Tarefa{
  int? id;
  String descricao;
  String prioridade;
  String status;

  Tarefa({
    this.id,
    required this.descricao,
    required this.prioridade,
    required this.status,
  });

  //converte o objeto Tarefa para um Map
  //que pode ser armazenado no SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'prioridade': prioridade,
      'status': status,
    };
  }

  //Converte um registro do SQLite
  //novamente para um objeto Tarefa
  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'],
      descricao: map['descricao'],
      prioridade: map['prioridade'],
      status: map['status'],
    );
  }
}