import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getImagemClasse(String classe) {
  switch (classe) {
    case 'Dark Knight':
      return 'lib/assets/classes/bk.png';

    case 'Dark Wizard':
      return 'lib/assets/classes/sm.png';

    case 'Fairy Elf':
      return 'lib/assets/classes/elf.png';

    case 'Magic Gladiator':
      return 'lib/assets/classes/mg.png';

    case 'Dark Lord':
      return 'lib/assets/classes/dl.png';

    case 'Rage Fighter':
      return 'lib/assets/classes/rf.png';

    case 'Summoner':
      return 'lib/assets/classes/summoner.png';

    default:
      return 'lib/assets/classes/bk.png';
  }
}

void main() {
  runApp(const GuildManagerApp());
}

class GuildManagerApp extends StatelessWidget {
  const GuildManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> players = [
    {
      'nome': 'VikingBK',
      'classe': 'Dark Knight',
      'reset': '120',
      'level': '400',
    },
    {
      'nome': 'ElfQueen',
      'classe': 'Fairy Elf',
      'reset': '98',
      'level': '400',
    },
    {
      'nome': 'SoulMaster',
      'classe': 'Dark Wizard',
      'reset': '150',
      'level': '400',
    },
  ];

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController levelController = TextEditingController();
  final TextEditingController resetController = TextEditingController();
  final TextEditingController buscaController = TextEditingController();

  String busca = '';
  int? playerEditandoIndex;

  final List<String> classes = [
    'Dark Knight',
    'Dark Wizard',
    'Fairy Elf',
    'Magic Gladiator',
    'Dark Lord',
    'Summoner',
    'Rage Fighter',
  ];

  String classeSelecionada = 'Dark Knight';

  @override
  void initState() {
    super.initState();
    carregarPlayers();
  }

  @override
  void dispose() {
    nomeController.dispose();
    levelController.dispose();
    resetController.dispose();
    buscaController.dispose();
    super.dispose();
  }

  Future<void> salvarPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = players.map((player) => jsonEncode(player)).toList();
    await prefs.setStringList('players', playersJson);
  }

  Future<void> carregarPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getStringList('players');

    if (playersJson != null) {
      setState(() {
        players.clear();
        players.addAll(
          playersJson.map(
            (player) => Map<String, String>.from(jsonDecode(player)),
          ),
        );
      });
    }
  }

  int _safeInt(String? value) {
    return int.tryParse(value ?? '') ?? 0;
  }

void adicionarPlayer() {
  if (nomeController.text.isNotEmpty &&
      levelController.text.isNotEmpty &&
      resetController.text.isNotEmpty) {

    setState(() {
      if (playerEditandoIndex != null) {

        players[playerEditandoIndex!] = {
          'nome': nomeController.text,
          'classe': classeSelecionada,
          'level': levelController.text,
          'reset': resetController.text,
        };

        playerEditandoIndex = null;

      } else {

        players.add({
          'nome': nomeController.text,
          'classe': classeSelecionada,
          'level': levelController.text,
          'reset': resetController.text,
        });
      }

      players.sort((a, b) {
        final resetA = _safeInt(a['reset']);
        final resetB = _safeInt(b['reset']);
        final levelA = _safeInt(a['level']);
        final levelB = _safeInt(b['level']);

        if (resetB != resetA) {
          return resetB.compareTo(resetA);
        }

        return levelB.compareTo(levelA);
      });
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      salvarPlayers();
    });

    nomeController.clear();
    levelController.clear();
    resetController.clear();

    setState(() {
      classeSelecionada = 'Dark Knight';
    });
  }
}

  void removerPlayer(int index) {
    setState(() {
      players.removeAt(index);
    });
    salvarPlayers();
  }

  void limparRanking() {
    setState(() {
      players.clear();
    });
    salvarPlayers();
  }

  IconData _iconeClasse(String classe) {
    switch (classe) {
      case 'Dark Knight':
        return Icons.shield;
      case 'Summoner':
        return Icons.auto_fix_high;
      case 'Fairy Elf':
        return Icons.track_changes;
      case 'Magic Gladiator':
        return Icons.flash_on;
      case 'Dark Lord':
        return Icons.dark_mode;
      case 'Rage Fighter':
        return Icons.sports_mma;
      case 'Dark Wizard':
        return Icons.psychology;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final playersFiltrados = players
        .where((player) {
          final nome = player['nome']?.toLowerCase() ?? '';
          return nome.contains(busca.toLowerCase());
        })
        .toList();

    playersFiltrados.sort((a, b) {
      final resetA = _safeInt(a['reset']);
      final resetB = _safeInt(b['reset']);
      final levelA = _safeInt(a['level']);
      final levelB = _safeInt(b['level']);

      if (resetB != resetA) {
        return resetB.compareTo(resetA);
      }
      return levelB.compareTo(levelA);
    });

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Row(
  mainAxisSize: MainAxisSize.min,
  children: const [
    Icon(
      Icons.emoji_events,
      color: Colors.amber,
      size: 30,
    ),
    SizedBox(width: 10),
    Text(
      'Ranking Mu Online',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
  ],
),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 10,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: limparRanking,
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.amber,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                controller: nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nome do player',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: classeSelecionada,
                dropdownColor: Colors.grey,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Classe',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                items: classes
                    .map(
                      (classe) => DropdownMenuItem(
                        value: classe,
                        child: Text(classe),
                      ),
                    )
                    .toList(),
                onChanged: (valor) {
                  setState(() {
                    classeSelecionada = valor ?? classeSelecionada;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: resetController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Reset',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: levelController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Level',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: buscaController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Buscar player',
                  labelStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                ),
                onChanged: (valor) {
                  setState(() {
                    busca = valor;
                  });
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: playersFiltrados.length,
                  itemBuilder: (context, index) {
                    final player = playersFiltrados[index];
                    final posicao = '#${index + 1}';

                    String medalha = '';
                    if (index == 0) {
                      medalha = '🥇';
                    } else if (index == 1) {
                      medalha = '🥈';
                    } else if (index == 2) {
                      medalha = '🥉';
                    }

                    final iconeClasse = _iconeClasse(player['classe'] ?? '');

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: index == 0
                            ? const LinearGradient(
                                colors: [
                                  Colors.amber,
                                  Colors.orange,
                                ],
                              )
                            : index == 1
                                ? const LinearGradient(
                                    colors: [
                                      Colors.grey,
                                      Colors.black54,
                                    ],
                                  )
                                : index == 2
                                    ? const LinearGradient(
                                        colors: [
                                          Colors.brown,
                                          Colors.brown,
                                        ],
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Colors.grey,
                                          Colors.black,
                                        ],
                                      ),
                        boxShadow: [
                          BoxShadow(
                            color: index <= 2
                                ? Colors.amber.withOpacity(0.3)
                                : Colors.black54,
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: index <= 2
                              ? Colors.amber
                              : Colors.white12,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
onTap: () {
  setState(() {
    playerEditandoIndex = index;

    nomeController.text = player['nome'] ?? '';
    levelController.text = player['level'] ?? '';
    resetController.text = player['reset'] ?? '';
    classeSelecionada =
        player['classe'] ?? classeSelecionada;
  });
},
leading: CircleAvatar(
  radius: 28,
  backgroundColor: Colors.black.withOpacity(0.4),
  backgroundImage: AssetImage(
    getImagemClasse(player['classe'] ?? ''),
  ),
),
                        title: Text(
                          '$medalha $posicao - ${player['nome'] ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${player['classe']} - Level ${player['level']} - Reset ${player['reset']}',
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            removerPlayer(index);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
     floatingActionButton: FloatingActionButton(
  backgroundColor: Colors.amber,
  onPressed: adicionarPlayer,
  child: Icon(
    playerEditandoIndex == null
        ? Icons.add
        : Icons.save,
    color: Colors.black,
  ),
),
);
  }
}

