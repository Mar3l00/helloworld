import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://10.140.170.33/pdm_api/tarefas.php';

void main() => runApp(const MyApp());

class Tarefa {
  final int id;
  final String titulo;
  final String descricao;
  final String prioridade;
  final String status;
  final String criadoEm;

  const Tarefa({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.prioridade,
    required this.status,
    required this.criadoEm,
  });

  factory Tarefa.fromJson(Map<String, dynamic> j) => Tarefa(
        id: int.parse(j['id'].toString()),
        titulo: j['titulo']?.toString() ?? '',
        descricao: j['descricao']?.toString() ?? '',
        prioridade: j['prioridade']?.toString() ?? '',
        status: j['status']?.toString() ?? '',
        criadoEm: j['criado_em']?.toString() ?? '',
      );
}

class Api {
  static final ValueNotifier<String> log =
      ValueNotifier<String>('Nenhuma requisicao ainda');
  static const Duration timeout = Duration(seconds: 10);

  static Uri uri({int? id}) {
    final base = Uri.parse(baseUrl);
    final parametros = Map<String, String>.from(base.queryParameters);
    if (id != null) parametros['id'] = id.toString();
    return base.replace(queryParameters: parametros.isEmpty ? null : parametros);
  }

  static void verificar(http.Response resposta) {
    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception(
        'HTTP ${resposta.statusCode}: ${resposta.body}',
      );
    }
  }

  static void registrar(String metodo, http.Response resposta) {
    log.value = '$metodo -> HTTP ${resposta.statusCode}';
    debugPrint(log.value);
    debugPrint('Resposta: ${resposta.body}');
  }

  static Future<List<Tarefa>> listar() async {
    try {
      final resposta = await http.get(uri()).timeout(timeout);
      registrar('GET', resposta);
      debugPrint('STATUS HTTP: ${resposta.statusCode}');
      final corpo = utf8.decode(resposta.bodyBytes);
      debugPrint('RESPOSTA COMPLETA GET: $corpo');
      verificar(resposta);

      final dynamic dados = jsonDecode(corpo);
      List<dynamic> lista;

      if (dados is List) {
        lista = dados;
      } else if (dados is Map<String, dynamic>) {
        if (dados['tarefas'] is List) {
          lista = dados['tarefas'] as List<dynamic>;
        } else if (dados['data'] is List) {
          lista = dados['data'] as List<dynamic>;
        } else if (dados['dados'] is List) {
          lista = dados['dados'] as List<dynamic>;
        } else {
          throw FormatException('Formato desconhecido. Resposta: $corpo');
        }
      } else {
        throw FormatException('Resposta inesperada: $corpo');
      }

      return lista.map((item) {
        return Tarefa.fromJson(Map<String, dynamic>.from(item as Map));
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('ERRO AO CARREGAR: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<void> criar(DadosTarefa dados) async {
    final resposta = await http
        .post(
          uri(),
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(dados.toJson()),
        )
        .timeout(timeout);
    registrar('POST', resposta);
    verificar(resposta);
  }

  static Future<void> atualizar(int id, DadosTarefa dados) async {
    final resposta = await http
        .put(
          uri(id: id),
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(dados.toJson()),
        )
        .timeout(timeout);
    registrar('PUT', resposta);
    verificar(resposta);
  }

  static Future<void> excluir(int id) async {
    final resposta = await http.delete(uri(id: id)).timeout(timeout);
    registrar('DELETE', resposta);
    verificar(resposta);
  }
}

class DadosTarefa {
  final String titulo;
  final String descricao;
  final String prioridade;
  final String status;

  const DadosTarefa({
    required this.titulo,
    required this.descricao,
    required this.prioridade,
    required this.status,
  });

  Map<String, String> toJson() => {
        'titulo': titulo,
        'descricao': descricao,
        'prioridade': prioridade,
        'status': status,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Cliente REST',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const TarefasPage(),
      );
}

class TarefasPage extends StatefulWidget {
  const TarefasPage({super.key});

  @override
  State<TarefasPage> createState() => _TarefasPageState();
}

class _TarefasPageState extends State<TarefasPage> {
  List<Tarefa> tarefas = [];
  bool carregando = false;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    if (!mounted) return;
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final resultado = await Api.listar();
      if (!mounted) return;
      setState(() => tarefas = resultado);
    } catch (e, stack) {
      debugPrint('Falha ao carregar: $e\n$stack');
      if (!mounted) return;
      setState(() => erro = 'Erro ao carregar tarefas:\n$e');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  void mensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  Future<void> abrirFormulario({Tarefa? tarefa}) async {
    final dados = await showDialog<DadosTarefa>(
      context: context,
      builder: (_) => FormularioTarefa(tarefa: tarefa),
    );
    if (!mounted || dados == null) return;

    try {
      if (tarefa == null) {
        await Api.criar(dados);
        mensagem('Tarefa cadastrada');
      } else {
        await Api.atualizar(tarefa.id, dados);
        mensagem('Tarefa atualizada');
      }
      await carregar();
    } catch (e, stack) {
      debugPrint('Falha ao salvar: $e\n$stack');
      mensagem('Nao foi possivel salvar: $e');
    }
  }

  Future<void> excluir(Tarefa tarefa) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text('Excluir "${tarefa.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!mounted || confirmado != true) return;
    try {
      await Api.excluir(tarefa.id);
      mensagem('Tarefa excluida');
      await carregar();
    } catch (e, stack) {
      debugPrint('Falha ao excluir: $e\n$stack');
      mensagem('Nao foi possivel excluir: $e');
    }
  }

  Widget corpo() {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(erro!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: carregar,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (tarefas.isEmpty) {
      return const Center(child: Text('Nenhuma tarefa cadastrada'));
    }
    return RefreshIndicator(
      onRefresh: carregar,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: tarefas.length,
        itemBuilder: (_, i) {
          final tarefa = tarefas[i];
          return ListTile(
            leading: CircleAvatar(child: Text('${tarefa.id}')),
            title: Text(tarefa.titulo),
            subtitle: Text(
              '${tarefa.descricao}\n'
              'Prioridade: ${tarefa.prioridade} | Status: ${tarefa.status}\n'
              'Criado em: ${tarefa.criadoEm.isEmpty ? 'Nao informado' : tarefa.criadoEm}',
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit),
                  onPressed: () => abrirFormulario(tarefa: tarefa),
                ),
                IconButton(
                  tooltip: 'Excluir',
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => excluir(tarefa),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Tarefas'),
          actions: [
            IconButton(
              tooltip: 'Recarregar',
              onPressed: carregar,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => abrirFormulario(),
          icon: const Icon(Icons.add),
          label: const Text('Nova tarefa'),
        ),
        body: Column(
          children: [
            ValueListenableBuilder<String>(
              valueListenable: Api.log,
              builder: (_, texto, __) => Container(
                width: double.infinity,
                color: Colors.black87,
                padding: const EdgeInsets.all(12),
                child: Text(
                  texto,
                  style: const TextStyle(color: Colors.greenAccent),
                ),
              ),
            ),
            Expanded(child: corpo()),
          ],
        ),
      );
}

// StatefulWidget separado: os controllers sao descartados com o dialogo.
class FormularioTarefa extends StatefulWidget {
  final Tarefa? tarefa;
  const FormularioTarefa({super.key, this.tarefa});

  @override
  State<FormularioTarefa> createState() => _FormularioTarefaState();
}

class _FormularioTarefaState extends State<FormularioTarefa> {
  final chave = GlobalKey<FormState>();
  late final TextEditingController titulo;
  late final TextEditingController descricao;
  late final TextEditingController prioridade;
  late final TextEditingController status;

  @override
  void initState() {
    super.initState();
    titulo = TextEditingController(text: widget.tarefa?.titulo ?? '');
    descricao = TextEditingController(text: widget.tarefa?.descricao ?? '');
    prioridade = TextEditingController(text: widget.tarefa?.prioridade ?? 'Media');
    status = TextEditingController(text: widget.tarefa?.status ?? 'Pendente');
  }

  @override
  void dispose() {
    titulo.dispose();
    descricao.dispose();
    prioridade.dispose();
    status.dispose();
    super.dispose();
  }

  String? obrigatorio(String? valor) =>
      valor == null || valor.trim().isEmpty ? 'Campo obrigatorio' : null;

  void salvar() {
    if (!chave.currentState!.validate()) return;
    Navigator.pop(
      context,
      DadosTarefa(
        titulo: titulo.text.trim(),
        descricao: descricao.text.trim(),
        prioridade: prioridade.text.trim(),
        status: status.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.tarefa == null ? 'Nova tarefa' : 'Editar tarefa'),
        content: Form(
          key: chave,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titulo,
                  decoration: const InputDecoration(labelText: 'Titulo'),
                  validator: obrigatorio,
                ),
                TextFormField(
                  controller: descricao,
                  decoration: const InputDecoration(labelText: 'Descricao'),
                  minLines: 2,
                  maxLines: 4,
                  validator: obrigatorio,
                ),
                TextFormField(
                  controller: prioridade,
                  decoration: const InputDecoration(labelText: 'Prioridade'),
                  validator: obrigatorio,
                ),
                TextFormField(
                  controller: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  validator: obrigatorio,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(onPressed: salvar, child: const Text('Salvar')),
        ],
      );
}
