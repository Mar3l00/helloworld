import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main_camera.dart';

class NovoProdutoPage extends StatefulWidget {
  const NovoProdutoPage({super.key});

  @override
  State<NovoProdutoPage> createState() => _NovoProdutoPageState();
}

class _NovoProdutoPageState extends State<NovoProdutoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _nomeCientificoController = TextEditingController();
  final _precoController = TextEditingController();
  final _descricaoController = TextEditingController();

  String _categoriaSelecionada = 'Clássicos';
  String _emojiSelecionado = '🍓';
  File? _foto;

  static const List<String> _categorias = [
    'Cítricos',
    'Doces',
    'Clássicos',
    'Outros',
  ];

  static const List<String> _emojisDisponiveis = [
    '🍓',
    '🍍',
    '🍑',
    '🍒',
    '🥭',
    '🍐',
    '🍋',
    '🍈',
  ];

  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (imagem != null) {
      setState(() => _foto = File(imagem.path));
    }
  }

  Future<void> _escolherDaGaleria() async {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (imagem != null) {
      setState(() => _foto = File(imagem.path));
    }
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final novoId =
        produtos.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
    final preco =
        double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0;

    final novoProduto = Frutinha(
      id: novoId,
      nome: _nomeController.text.trim(),
      nomeCientifico: _nomeCientificoController.text.trim().isEmpty
          ? '-'
          : _nomeCientificoController.text.trim(),
      emoji: _emojiSelecionado,
      preco: preco,
      categoria: _categoriaSelecionada,
      descricao: _descricaoController.text.trim(),
      foto: _foto,
    );

    Navigator.of(context).pop(novoProduto);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _nomeCientificoController.dispose();
    _precoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Produto'),
        backgroundColor: const Color(0xFF4A7C59),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _tirarFoto,
                onLongPress: _escolherDaGaleria,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFFEFEFEF),
                  backgroundImage: _foto != null ? FileImage(_foto!) : null,
                  child: _foto == null
                      ? const Icon(
                          Icons.camera_alt,
                          size: 32,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _foto == null
                    ? 'Toque para tirar foto (segure para galeria)'
                    : 'Toque para tirar outra foto',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nomeCientificoController,
              decoration: const InputDecoration(
                labelText: 'Nome científico (opcional)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _precoController,
              decoration: const InputDecoration(labelText: 'Preço (R\$)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o preço';
                final valor = double.tryParse(v.replaceAll(',', '.'));
                if (valor == null || valor <= 0) return 'Preço inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _categoriaSelecionada,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: _categorias
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _categoriaSelecionada = v!),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Emoji (usado se não houver foto):'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _emojisDisponiveis.map((e) {
                final selecionado = e == _emojiSelecionado;
                return ChoiceChip(
                  label: Text(e, style: const TextStyle(fontSize: 20)),
                  selected: selecionado,
                  onSelected: (_) => setState(() => _emojiSelecionado = e),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.check),
              label: const Text('Salvar Produto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C59),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}