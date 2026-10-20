import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://10.140.170.33/pdm_api/tarefas.php';

const Color begeClaro = Color(0xFFF7EFD8);
const Color azulAcinzentado = Color(0xFF556270);
const Color azulEscuro = Color(0xFF273142);
const Color brancoQuente = Color(0xFFFFFCF5);

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
  static final ValueNotifier<String> log = ValueNotifier<String>(
    'Nenhuma requisição ainda',
  );
  static const Duration timeout = Duration(seconds: 10);

  static Uri uri({int? id}) {
    final base = Uri.parse(baseUrl);
    final parametros = Map<String, String>.from(base.queryParameters);
    if (id != null) parametros['id'] = id.toString();
    return base.replace(
      queryParameters: parametros.isEmpty ? null : parametros,
    );
  }

  static void verificar(http.Response resposta) {
    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception('HTTP ${resposta.statusCode}: ${resposta.body}');
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
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: begeClaro,
      colorScheme: ColorScheme.fromSeed(
        seedColor: azulAcinzentado,
        primary: azulAcinzentado,
        onPrimary: brancoQuente,
        secondary: azulEscuro,
        onSecondary: brancoQuente,
        surface: brancoQuente,
        onSurface: azulEscuro,
        error: const Color(0xFF9B3D3D),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: azulEscuro,
        foregroundColor: begeClaro,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: begeClaro,
          fontSize: 21,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: brancoQuente,
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: azulAcinzentado,
          foregroundColor: brancoQuente,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: azulAcinzentado,
        foregroundColor: brancoQuente,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brancoQuente,
        labelStyle: const TextStyle(color: azulAcinzentado),
        floatingLabelStyle: const TextStyle(
          color: azulEscuro,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: azulAcinzentado),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: azulAcinzentado.withValues(alpha: 0.45),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: azulEscuro, width: 1.8),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: begeClaro,
        titleTextStyle: const TextStyle(
          color: azulEscuro,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: azulEscuro,
        contentTextStyle: const TextStyle(color: begeClaro),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: azulEscuro),
        bodyMedium: TextStyle(color: azulEscuro),
        titleMedium: TextStyle(color: azulEscuro, fontWeight: FontWeight.w600),
      ),
    ),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
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
      mensagem('Não foi possível salvar: $e');
    }
  }

  Future<void> excluir(Tarefa tarefa) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text('Deseja excluir "${tarefa.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: azulEscuro,
              foregroundColor: begeClaro,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!mounted || confirmado != true) return;
    try {
      await Api.excluir(tarefa.id);
      mensagem('Tarefa excluída');
      await carregar();
    } catch (e, stack) {
      debugPrint('Falha ao excluir: $e\n$stack');
      mensagem('Não foi possível excluir: $e');
    }
  }

  Widget corpo() {
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(color: azulAcinzentado),
      );
    }
    if (erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 44,
                color: azulAcinzentado,
              ),
              const SizedBox(height: 12),
              SelectableText(erro!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: carregar,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (tarefas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.task_alt,
                size: 58,
                color: azulAcinzentado.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 14),
              const Text(
                'Nenhuma tarefa cadastrada',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                'Toque em “Nova tarefa” para adicionar a primeira.',
                textAlign: TextAlign.center,
                style: TextStyle(color: azulAcinzentado),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: azulAcinzentado,
      onRefresh: carregar,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: tarefas.length,
        itemBuilder: (_, i) {
          final tarefa = tarefas[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: azulEscuro,
                    foregroundColor: begeClaro,
                    child: Text(
                      '${tarefa.id}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tarefa.titulo,
                          style: const TextStyle(
                            color: azulEscuro,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          tarefa.descricao,
                          style: const TextStyle(height: 1.35),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 7,
                          runSpacing: 6,
                          children: [
                            _etiqueta(
                              Icons.flag_outlined,
                              'Prioridade: ${tarefa.prioridade}',
                            ),
                            _etiqueta(
                              Icons.circle_outlined,
                              'Status: ${tarefa.status}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Criado em: ${tarefa.criadoEm.isEmpty ? 'Não informado' : tarefa.criadoEm}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: azulAcinzentado,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        tooltip: 'Editar',
                        icon: const Icon(Icons.edit_outlined),
                        color: azulAcinzentado,
                        onPressed: () => abrirFormulario(tarefa: tarefa),
                      ),
                      IconButton(
                        tooltip: 'Excluir',
                        icon: const Icon(Icons.delete_outline),
                        color: azulEscuro,
                        onPressed: () => excluir(tarefa),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _etiqueta(IconData icone, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: begeClaro,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: azulAcinzentado.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: azulAcinzentado),
          const SizedBox(width: 5),
          Text(texto, style: const TextStyle(fontSize: 12, color: azulEscuro)),
        ],
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
            color: azulAcinzentado,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              children: [
                const Icon(Icons.sync_alt, size: 18, color: begeClaro),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'API  •  $texto',
                    style: const TextStyle(
                      color: begeClaro,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: corpo()),
      ],
    ),
  );
}

// O formulário é separado para descartar os controllers ao fechar o diálogo.
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
    prioridade = TextEditingController(
      text: widget.tarefa?.prioridade ?? 'Média',
    );
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
      valor == null || valor.trim().isEmpty ? 'Campo obrigatório' : null;

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
              decoration: const InputDecoration(
                labelText: 'Título',
                prefixIcon: Icon(Icons.title),
              ),
              validator: obrigatorio,
            ),
            const SizedBox(height: 13),
            TextFormField(
              controller: descricao,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes),
              ),
              minLines: 2,
              maxLines: 4,
              validator: obrigatorio,
            ),
            const SizedBox(height: 13),
            TextFormField(
              controller: prioridade,
              decoration: const InputDecoration(
                labelText: 'Prioridade',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              validator: obrigatorio,
            ),
            const SizedBox(height: 13),
            TextFormField(
              controller: status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.check_circle_outline),
              ),
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
      FilledButton.icon(
        onPressed: salvar,
        icon: const Icon(Icons.save_outlined),
        label: const Text('Salvar'),
      ),
    ],
  );
}