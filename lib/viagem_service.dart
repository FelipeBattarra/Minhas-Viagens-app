import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'viagem_model.dart';

class ViagemService {
  // Chave única para armazenar a lista no dispositivo
  static const _storageKey = 'viagens_list';

  // Método para salvar a lista de viagens
  Future<void> salvarViagens(List<Viagem> viagens) async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Converte cada objeto Viagem para um Map (usando toJson)
    // 2. Converte a lista de Maps para uma lista de Strings JSON
    List<String> viagensJson =
        viagens.map((viagem) => json.encode(viagem.toJson())).toList();
    // 3. Salva a lista de strings no SharedPreferences
    await prefs.setStringList(_storageKey, viagensJson);
  }

  // Método para carregar a lista de viagens
  Future<List<Viagem>> carregarViagens() async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Obtém a lista de strings JSON do SharedPreferences
    final List<String>? viagensJson = prefs.getStringList(_storageKey);

    if (viagensJson != null) {
      // 2. Converte cada string JSON de volta para um Map
      // 3. Converte cada Map de volta para um objeto Viagem
      return viagensJson
          .map((jsonString) => Viagem.fromStorageJson(json.decode(jsonString)))
          .toList();
    }
    // Se não houver nada salvo, retorna uma lista vazia
    return [];
  }
}
