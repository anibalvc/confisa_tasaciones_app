// To parse this JSON data, do
//
//     final vinDecoderResponse = vinDecoderResponseFromJson(jsonString);

import 'dart:convert';

VinDecoderResponse vinDecoderResponseFromJson(String str) =>
    VinDecoderResponse.fromJson(json.decode(str));

String vinDecoderResponseToJson(VinDecoderResponse data) =>
    json.encode(data.toJson());

class VinDecoderResponse {
  VinDecoderResponse({
    required this.data,
  });

  VinDecoderData data;

  factory VinDecoderResponse.fromJson(Map<String, dynamic> json) =>
      VinDecoderResponse(
        data: VinDecoderData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };
}

class VinDecoderData {
  VinDecoderData({
    this.codigoMarca,
    this.marca,
    this.codigoModelo,
    this.modelo,
    this.ano,
    this.tipoVehiculo,
    this.sistemaCambio,
    this.traccion,
    this.numeroPuertas,
    this.numeroCilindros,
    this.fuerzaMotriz,
    this.serie,
    this.idSerie,
    this.trim,
    this.idTrim,
  });

  int? codigoMarca;
  String? marca;
  int? codigoModelo;
  String? modelo;
  int? ano;
  String? tipoVehiculo;
  String? sistemaCambio;
  String? traccion;
  int? numeroPuertas;
  int? numeroCilindros;
  int? fuerzaMotriz;
  String? serie;
  int? idSerie;
  String? trim;
  int? idTrim;

  factory VinDecoderData.fromJson(Map<String, dynamic> json) => VinDecoderData(
        codigoMarca: json["codigoMarca"] == '' ? null : json["codigoMarca"],
        marca: json["marca"] == '' ? null : json["marca"],
        codigoModelo: json["codigoModelo"] == '' ? null : json["codigoModelo"],
        modelo: json["modelo"] == '' ? null : json["modelo"],
        ano: json["ano"] == '' ? null : int.parse(json["ano"]),
        tipoVehiculo: json["tipoVehiculo"] == '' ? null : json["tipoVehiculo"],
        sistemaCambio:
            json["sistemaCambio"] == '' ? null : json["sistemaCambio"],
        traccion: json["traccion"] == '' ? null : json["traccion"],
        numeroPuertas: json["numeroPuertas"] == ''
            ? null
            : int.parse(json["numeroPuertas"]),
        numeroCilindros: json["numeroCilindros"] == ''
            ? null
            : int.parse(json["numeroCilindros"]),
        fuerzaMotriz: json["fuerzaMotriz"] == ''
            ? null
            : double.parse(json["fuerzaMotriz"]).round(),
        serie: json["serie"] == '' ? null : json["serie"],
        idSerie: json["idSerie"] == '' ? null : json["idSerie"],
        trim: json["trim"] == '' ? null : json["trim"],
        idTrim: json["idTrim"] == '' ? null : json["idTrim"],
      );

  Map<String, dynamic> toJson() => {
        "codigoMarca": codigoMarca,
        "marca": marca,
        "codigoModelo": codigoModelo,
        "modelo": modelo,
        "ano": ano,
        "tipoVehiculo": tipoVehiculo,
        "sistemaCambio": sistemaCambio,
        "traccion": traccion,
        "numeroPuertas": numeroPuertas,
        "numeroCilindros": numeroCilindros,
        "fuerzaMotriz": fuerzaMotriz,
        "serie": serie,
        "idSerie": idSerie,
        "trim": trim,
        "idTrim": idTrim,
      };
}
