import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'pages_lista/carrinho_page_mercado.dart';
import 'pages_lista/novo_produto_page.dart';

class Frutinha {
  final int id;
  String nome;
  String nomeCientifico;
  String emoji;
  double preco;
  String categoria;
  String descricao;
  File? foto;

  Frutinha({
    required this.id,
    required this.nome,
    required this.nomeCientifico,
    required this.emoji,
    required this.preco,
    required this.categoria,
    required this.descricao,
    this.foto,
  });
}

List<Frutinha> produtos = [
  Frutinha(
    id: 1,
    nome: 'Laranja',
    nomeCientifico: 'Citrus sinensis',
    emoji: '🍊',
    preco: 5.00,
    categoria: 'Cítricos',
    descricao:
        'Fruta cítrica rica em vitamina C e bastante utilizada em sucos e sobremesas.',
  ),
  Frutinha(
    id: 2,
    nome: 'Kiwi',
    nomeCientifico: 'Actinidia deliciosa',
    emoji: '🥝',
    preco: 8.00,
    categoria: 'Cítricos',
    descricao:
        'Fruta de sabor levemente ácido, com polpa verde e pequenas sementes.',
  ),
  Frutinha(
    id: 3,
    nome: 'Maçã',
    nomeCientifico: 'Malus domestica',
    emoji: '🍎',
    preco: 10.00,
    categoria: 'Clássicos',
    descricao:
        'Fruta crocante e de sabor adocicado, muito consumida in natura.',
  ),
  Frutinha(
    id: 4,
    nome: 'Banana',
    nomeCientifico: 'Musa spp.',
    emoji: '🍌',
    preco: 7.00,
    categoria: 'Clássicos',
    descricao:
        'Fruta macia e naturalmente doce, muito utilizada em lanches e sobremesas.',
  ),
  Frutinha(
    id: 5,
    nome: 'Melancia',
    nomeCientifico: 'Citrullus lanatus',
    emoji: '🍉',
    preco: 30.00,
    categoria: 'Doces',
    descricao:
        'Fruta grande e bastante hidratante, com polpa geralmente vermelha e sabor adocicado.',
  ),
  Frutinha(
    id: 6,
    nome: 'Uva',
    nomeCientifico: 'Vitis vinifera',
    emoji: '🍇',
    preco: 20.00,
    categoria: 'Doces',
    descricao:
        'Fruta pequena e suculenta, encontrada em diferentes variedades e cores.',
  ),
];

class ItemCarrinho {
  final Frutinha produto;
  int quantidade;
  ItemCarrinho(this.produto, this.quantidade);
}

class CarrinhoController extends ChangeNotifier {
  List<ItemCarrinho> itens = [];

  void adicionar(Frutinha produto) {
    for (var item in itens) {
      if (item.produto.id == produto.id) {
        item.quantidade++;
        notifyListeners();
        return;
      }
    }
    itens.add(ItemCarrinho(produto, 1));
    notifyListeners();
  }

  void remover(Frutinha produto) {
    for (int i = 0; i < itens.length; i++) {
      if (itens[i].produto.id == produto.id) {
        if (itens[i].quantidade > 1) {
          itens[i].quantidade--;
        } else {
          itens.removeAt(i);
        }
        notifyListeners();
        return;
      }
    }
  }

  void removerItemCompleto(Frutinha produto) {
    itens.removeWhere((item) => item.produto.id == produto.id);
    notifyListeners();
  }

  double get total {
    double soma = 0;
    for (var item in itens) soma += item.produto.preco * item.quantidade;
    return soma;
  }

  int get totalItens {
    int soma = 0;
    for (var item in itens) soma += item.quantidade;
    return soma;
  }

  void limpar() {
    itens.clear();
    notifyListeners();
  }
}

final carrinho = CarrinhoController();

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/carrinho',
      builder: (context, state) => const CarrinhoPage(),
    ),
    GoRoute(
      path: '/novo-produto',
      builder: (context, state) => const NovoProdutoPage(),
    ),
  ],
);

void main() => runApp(const MeuApp());

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Feira de Frutas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 130, 255, 168),
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _categoriaSelecionada = 'Todos';

  static const List<String> _categorias = [
    'Todos',
    'Cítricos',
    'Doces',
    'Clássicos',
    'Outros',
  ];

  List<Frutinha> get _produtosFiltrados {
    if (_categoriaSelecionada == 'Todos') return produtos;
    return produtos.where((p) => p.categoria == _categoriaSelecionada).toList();
  }

  // Tira (ou troca) a foto de um produto já existente.
  // Toque = câmera, toque longo = galeria.
  Future<void> _tirarFotoProduto(Frutinha produto) async {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (imagem != null) {
      setState(() => produto.foto = File(imagem.path));
    }
  }

  Future<void> _escolherFotoDaGaleria(Frutinha produto) async {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (imagem != null) {
      setState(() => produto.foto = File(imagem.path));
    }
  }

  Future<void> _abrirNovoProduto() async {
    final novoProduto = await context.push<Frutinha>('/novo-produto');
    if (novoProduto != null) {
      setState(() => produtos.add(novoProduto));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feira de Frutas'),
        backgroundColor: const Color(0xFF4A7C59),
        foregroundColor: Colors.white,
        actions: [
          ListenableBuilder(
            listenable: carrinho,
            builder: (context, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => context.push('/carrinho'),
                  ),
                  if (carrinho.totalItens > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${carrinho.totalItens}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final cat = _categorias[index];
                final selecionada = cat == _categoriaSelecionada;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selecionada,
                    onSelected: (_) =>
                        setState(() => _categoriaSelecionada = cat),
                    selectedColor: Colors.white,
                    backgroundColor: const Color(0xFF3A6B4A),
                    labelStyle: TextStyle(
                      color: selecionada
                          ? const Color(0xFF4A7C59)
                          : Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    side: BorderSide.none,
                  ),
                );
              },
            ),
          ),
        ),
      ),

      body: _produtosFiltrados.isEmpty
          ? const Center(
              child: Text(
                'Nenhum produto nesta categoria.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _produtosFiltrados.length,
              itemBuilder: (context, index) {
                final produto = _produtosFiltrados[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () => _tirarFotoProduto(produto),
                      onLongPress: () => _escolherFotoDaGaleria(produto),
                      child: produto.foto != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                produto.foto!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Text(
                                  produto.emoji,
                                  style: const TextStyle(fontSize: 36),
                                ),
                                Positioned(
                                  right: -4,
                                  bottom: -4,
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    title: Text(produto.nome),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produto.nomeCientifico,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text('R\$ ${produto.preco.toStringAsFixed(2)}'),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFF4A7C59)),
                      onPressed: () {
                        carrinho.adicionar(produto);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${produto.nome} adicionado!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNovoProduto,
        backgroundColor: const Color(0xFF4A7C59),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Novo produto'),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (_) {}, // sem funcionalidade
        selectedItemColor: const Color(0xFF4A7C59),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Categorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}