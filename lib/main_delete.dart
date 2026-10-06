import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// IP do PC que está rodando o Apache + MySQL (o servidor da API)
const String baseUrl = 'http://10.140.170.47/pdm_api';

void main() => runApp(const MyApp());

// ------------------------------- MODELO ------------------------------------
class Produto {
  final int id;
  final String nome;
  final double preco;
  final int estoque;

  Produto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.estoque,
  });

  factory Produto.fromJson(Map<String, dynamic> j) => Produto(
        id: int.parse(j['id'].toString()),
        nome: j['nome'].toString(),
        preco: double.parse(j['preco'].toString()),
        estoque: int.parse(j['estoque'].toString()),
      );
}

// ------------------------------- API ---------------------------------------
class Api {
  static final ValueNotifier<String> log =
      ValueNotifier<String>('Nenhuma requisição ainda');

  static const _timeout = Duration(seconds: 10);

  // GET /produtos
  static Future<List<Produto>> listar() async {
    final r = await http
        .get(Uri.parse('$baseUrl/produtos.php'))
        .timeout(_timeout);
    log.value = 'GET /produtos  →  ${r.statusCode}';
    if (r.statusCode != 200) throw Exception('Erro ${r.statusCode}');
    final lista = jsonDecode(r.body) as List;
    return lista.map((e) => Produto.fromJson(e)).toList();
  }

  // DELETE /produtos/{id}
  static Future<void> excluir(int id) async {
    final r = await http
        .delete(Uri.parse('$baseUrl/produtos.php?id=$id'))
        .timeout(_timeout);
    log.value = 'DELETE /produtos/$id  →  ${r.statusCode}';
    if (r.statusCode != 200) throw Exception('Erro ${r.statusCode}');
  }
}

// ------------------------------- APP ---------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cliente REST',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const ProdutosPage(),
    );
  }
}

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  List<Produto> _produtos = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await Api.listar();
      if (!mounted) return;
      setState(() => _produtos = lista);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível conectar à API.\n\n$e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  String _moeda(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  Future<void> _excluir(Produto p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir produto?'),
        content: Text('"${p.nome}" será removido do banco (DELETE).'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await Api.excluir(p.id);
      _mensagem('Produto removido');
      await _carregar();
    } catch (e) {
      _mensagem(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos (cliente)'),
        actions: [
          IconButton(
            tooltip: 'Recarregar (GET)',
            icon: const Icon(Icons.refresh),
            onPressed: _carregar,
          ),
        ],
      ),
      body: Column(
        children: [
          ValueListenableBuilder<String>(
            valueListenable: Api.log,
            builder: (_, texto, __) => Container(
              width: double.infinity,
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                texto,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Expanded(child: _corpo()),
        ],
      ),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_erro!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                  onPressed: _carregar, child: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
    }
    if (_produtos.isEmpty) {
      return const Center(child: Text('Nenhum produto cadastrado'));
    }
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _produtos.length,
        itemBuilder: (_, i) {
          final p = _produtos[i];
          return ListTile(
            leading: CircleAvatar(child: Text('${p.id}')),
            title: Text(p.nome),
            subtitle: Text('${_moeda(p.preco)}  •  Estoque: ${p.estoque}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _excluir(p),
            ),
          );
        },
      ),
    );
  }
}