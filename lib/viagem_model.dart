import 'dart:convert';
import 'package:latlong2/latlong.dart';

class Viagem {
  final LatLng coordenadas;
  String nome; // Alterado para não ser final
  final String endereco;
  final String cidade;
  final String estado;
  final String pais;
  final String cep;
  final String? bairro;
  final String? referencia;

  Viagem({
    required this.coordenadas,
    required this.nome,
    required this.endereco,
    required this.cidade,
    required this.estado,
    required this.pais,
    required this.cep,
    this.bairro,
    this.referencia,
  });

  // NOVO: Método para converter a instância da classe para um Map (para JSON)
  Map<String, dynamic> toJson() {
    return {
      'latitude': coordenadas.latitude,
      'longitude': coordenadas.longitude,
      'nome': nome,
      'endereco': endereco,
      'cidade': cidade,
      'estado': estado,
      'pais': pais,
      'cep': cep,
      'bairro': bairro,
      'referencia': referencia,
    };
  }

  // NOVO: Método factory para criar uma instância a partir de um Map (de JSON)
  factory Viagem.fromStorageJson(Map<String, dynamic> json) {
    return Viagem(
      coordenadas: LatLng(json['latitude'], json['longitude']),
      nome: json['nome'],
      endereco: json['endereco'],
      cidade: json['cidade'],
      estado: json['estado'],
      pais: json['pais'],
      cep: json['cep'],
      bairro: json['bairro'],
      referencia: json['referencia'],
    );
  }

  // ATUALIZADO: O construtor a partir da API Nominatim permanece
  factory Viagem.fromApiJson(Map<String, dynamic> json,
      {required String nomePersonalizado}) {
    final endereco = json['address'];
    return Viagem(
      coordenadas: LatLng(
        double.parse(json['lat']),
        double.parse(json['lon']),
      ),
      nome: nomePersonalizado,
      endereco:
          '${endereco['road'] ?? ''}, ${endereco['house_number'] ?? ''}'.trim(),
      cidade: endereco['city'] ?? endereco['town'] ?? endereco['village'] ?? '',
      estado: endereco['state'] ?? '',
      pais: endereco['country'] ?? '',
      cep: endereco['postcode'] ?? '',
      bairro: endereco['suburb'] ?? endereco['neighbourhood'] ?? '',
      referencia: endereco['amenity'] ?? endereco['building'] ?? '',
    );
  }
}
