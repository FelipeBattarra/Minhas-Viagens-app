import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'geocoding_service.dart';
import 'viagem_model.dart';
import 'viagem_service.dart'; // NOVO: Importa o nosso serviço
import 'Mapas.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Viagem> _listaViagens = [];
  final ViagemService _viagemService =
      ViagemService(); // NOVO: Instância do serviço
  bool _isLoading = true; // NOVO: Estado de carregamento inicial

  // NOVO: `initState` para carregar os dados quando o app inicia
  @override
  void initState() {
    super.initState();
    _carregarViagensSalvas();
  }

  Future<void> _carregarViagensSalvas() async {
    final viagens = await _viagemService.carregarViagens();
    setState(() {
      _listaViagens = viagens;
      _isLoading = false; // Terminou o carregamento
    });
  }

  Future<void> _adicionarLocal() async {
    final selectedLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (context) => const Mapas()),
    );
    if (selectedLocation != null) {
      await _adicionarViagemDaLocalizacao(selectedLocation);
    }
  }

  Future<void> _adicionarViagemDaLocalizacao(LatLng location) async {
    try {
      final dadosLocal =
          await GeocodingService.getAddressFromCoordinates(location);

      final nomeController = TextEditingController(
        text: dadosLocal['name'] ??
            dadosLocal['address']['amenity'] ??
            'Novo Local',
      );

      final confirmado = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar Local'),
          content: SingleChildScrollView(/* ... Conteúdo do diálogo ... */),
          actions: [/* ... Ações do diálogo ... */],
        ),
      );

      if (confirmado == true) {
        final novaViagem = Viagem.fromApiJson(
          dadosLocal,
          nomePersonalizado: nomeController.text,
        );
        setState(() => _listaViagens.add(novaViagem));
        await _viagemService
            .salvarViagens(_listaViagens); // NOVO: Salva a lista
      }
    } catch (e) {
      final nome = await _mostrarDialogoManual(location);
      if (nome != null) {
        setState(() => _listaViagens.add(
              Viagem(
                coordenadas: location,
                nome: nome,
                endereco:
                    'Coordenadas: ${location.latitude.toStringAsFixed(6)}, '
                    '${location.longitude.toStringAsFixed(6)}',
                cidade: 'Não identificada',
                estado: '',
                pais: '',
                cep: '',
              ),
            ));
        await _viagemService
            .salvarViagens(_listaViagens); // NOVO: Salva a lista
      }
    }
  }

  // NOVO: Função para editar uma viagem
  Future<void> _editarViagem(int index) async {
    final viagem = _listaViagens[index];
    final nomeController = TextEditingController(text: viagem.nome);

    final novoNome = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Nome do Local'),
        content: TextFormField(
          controller: nomeController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Novo nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nomeController.text),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (novoNome != null && novoNome.isNotEmpty) {
      setState(() {
        _listaViagens[index].nome = novoNome;
      });
      await _viagemService.salvarViagens(_listaViagens); // Salva após editar
    }
  }

  Future<String?> _mostrarDialogoManual(LatLng location) async {
    // ... sem alterações nesta função ...
  }

  void _excluirViagem(int index) async {
    // ATUALIZADO: para ser async
    setState(() {
      _listaViagens.removeAt(index);
    });
    await _viagemService
        .salvarViagens(_listaViagens); // NOVO: Salva após excluir
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas viagens"),
        actions: [
          // ... sem alterações aqui ...
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _adicionarLocal,
      ),
      body:
          _isLoading // NOVO: Mostra um indicador de progresso enquanto carrega
              ? const Center(child: CircularProgressIndicator())
              : _listaViagens.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum local salvo\nClique no + para começar',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _listaViagens.length,
                      itemBuilder: (context, index) {
                        final viagem = _listaViagens[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(
                              viagem.nome,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle:
                                Column(/* ... Conteúdo do subtítulo ... */),
                            // ATUALIZADO: trailing com botões de editar e excluir
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => _editarViagem(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _excluirViagem(index),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Opcional: pode levar ao mapa focado neste local
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
