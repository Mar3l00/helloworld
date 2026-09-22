import 'package:flutter/material.dart';

import 'camera/pages_lista/carrinho_page_mercado.dart';

class Produto {
  const Produto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.emoji,
    required this.descricao,
  });

  final String id;
  final String nome;
  final double preco;
  final String emoji;
  final String descricao;
}

class ItemCarrinho {
  ItemCarrinho({required this.produto, this.quantidade = 1});

  final Produto produto;
  int quantidade;
}

class CarrinhoController extends ChangeNotifier {
  final List<ItemCarrinho> itens = [];

  int get totalItens => itens.fold(0, (total, item) => total + item.quantidade);

  double get total => itens.fold(
    0,
    (total, item) => total + item.produto.preco * item.quantidade,
  );

  void adicionar(Produto produto) {
    final indice = itens.indexWhere((item) => item.produto.id == produto.id);
    if (indice == -1) {
      itens.add(ItemCarrinho(produto: produto));
    } else {
      itens[indice].quantidade++;
    }
    notifyListeners();
  }

  void remover(Produto produto) {
    final indice = itens.indexWhere((item) => item.produto.id == produto.id);
    if (indice == -1) return;

    final item = itens[indice];
    if (item.quantidade == 1) {
      itens.removeAt(indice);
    } else {
      item.quantidade--;
    }
    notifyListeners();
  }

  void removerItemCompleto(Produto produto) {
    itens.removeWhere((item) => item.produto.id == produto.id);
    notifyListeners();
  }

  void limpar() {
    itens.clear();
    notifyListeners();
  }
}

final carrinho = CarrinhoController();

const produtos = [
  Produto(
    id: 'maca',
    nome: 'Maca',
    preco: 3.50,
    emoji: '🍎',
    descricao: 'Maca fresca',
  ),
  Produto(
    id: 'banana',
    nome: 'Banana',
    preco: 4.20,
    emoji: '🍌',
    descricao: 'Banana prata',
  ),
  Produto(
    id: 'pao',
    nome: 'Pao',
    preco: 8.90,
    emoji: '🍞',
    descricao: 'Pao artesanal',
  ),
  Produto(
    id: 'leite',
    nome: 'Leite',
    preco: 5.80,
    emoji: '🥛',
    descricao: 'Leite integral',
  ),
];

class MercadoPage extends StatelessWidget {
  const MercadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mercado'),
        backgroundColor: const Color(0xFF4A7C59),
        foregroundColor: Colors.white,
        actions: [
          ListenableBuilder(
            listenable: carrinho,
            builder: (context, _) => IconButton(
              tooltip: 'Abrir carrinho',
              icon: Badge(
                isLabelVisible: carrinho.totalItens > 0,
                label: Text('${carrinho.totalItens}'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CarrinhoPage(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: produtos.length,
        itemBuilder: (context, index) {
          final produto = produtos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Text(produto.emoji, style: const TextStyle(fontSize: 38)),
              title: Text(
                produto.nome,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${produto.descricao}\nR\$ ${produto.preco.toStringAsFixed(2)}',
              ),
              isThreeLine: true,
              trailing: IconButton(
                tooltip: 'Adicionar ao carrinho',
                icon: const Icon(Icons.add_shopping_cart),
                color: const Color(0xFF4A7C59),
                onPressed: () {
                  carrinho.adicionar(produto);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${produto.nome} adicionado')),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}