import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tasaciones_app/core/api/notas.dart';
import 'package:tasaciones_app/core/api/api_status.dart';
import 'package:tasaciones_app/core/models/notas_response.dart';
import 'package:tasaciones_app/core/models/profile_response.dart';
import 'package:tasaciones_app/core/providers/profile_permisos_provider.dart';
import 'package:tasaciones_app/core/services/navigator_service.dart';
import 'package:tasaciones_app/core/user_client.dart';
import 'package:tasaciones_app/theme/theme.dart';
import 'package:tasaciones_app/views/auth/login/login_view.dart';
import 'package:tasaciones_app/widgets/app_dialogs.dart';

import '../../../core/base/base_view_model.dart';
import '../../../core/locator.dart';

class NotasViewModel extends BaseViewModel {
  final int idSolicitud;
  final bool showCreate;

  final _notasApi = locator<NotasApi>();
  final _userClient = locator<UserClient>();
  final _navigationService = locator<NavigatorService>();
  final listController = ScrollController();
  TextEditingController tcNewDescription = TextEditingController();
  TextEditingController tcNewTitulo = TextEditingController();
  TextEditingController tcNewFechaCompromiso = TextEditingController();
  TextEditingController tcNewHoraCompromiso = TextEditingController();
  TextEditingController tcNewFechaMostrar = TextEditingController();
  TextEditingController tcBuscar = TextEditingController();

  List<NotasData> notas = [];
  int pageNumber = 1;
  bool _cargando = false;
  bool _busqueda = false;
  bool hasNextPage = false;
  late NotasResponse notasResponse;
  late ProfilePermisoResponse profilePermisoResponse;
  Profile? usuario;

  NotasViewModel({required this.showCreate, required this.idSolicitud}) {
    listController.addListener(() {
      if (listController.position.maxScrollExtent == listController.offset) {
        if (hasNextPage) {
          cargarMasNotas();
        }
      }
    });
  }

  bool get cargando => _cargando;
  set cargando(bool value) {
    _cargando = value;
    notifyListeners();
  }

  bool get busqueda => _busqueda;
  set busqueda(bool value) {
    _busqueda = value;
    notifyListeners();
  }

  void ordenar() {
    notas.sort((a, b) {
      return a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
    });
  }

  String formatFecha(String fecha) {
    var temp = DateTime.tryParse(fecha);

    String r = temp!.day.toString() +
        "-" +
        DateFormat.MMM().format(temp) +
        "-" +
        temp.year.toString();
    r = r.replaceAll("Jan", "Ene");
    r = r.replaceAll("Apr", "Abr");
    r = r.replaceAll("Aug", "Ago");
    r = r.replaceAll("Apr", "Abr");
    r = r.replaceAll("Dec", "Dic");
    return r;
  }

  Future<void> onInit(BuildContext context) async {
    cargando = true;
    usuario = _userClient.loadProfile;
    profilePermisoResponse =
        Provider.of<ProfilePermisosProvider>(context, listen: false)
            .profilePermisos;

    Object resp = Failure;
    if (idSolicitud == 0) {
      switch (usuario!.roles!.any((element) =>
          element.roleName == "AprobadorTasaciones" ||
          element.roleName == "Administrador")) {
        case true:
          resp = await _notasApi.getNotas(pageNumber: pageNumber);
          break;
        case false:
          resp = await _notasApi.getNotas(
              pageNumber: pageNumber, usuario: usuario!.id ?? "");
          break;
        default:
      }
    } else {
      switch (usuario!.roles!
          .any((element) => element.roleName == "AprobadorTasaciones")) {
        case true:
          resp = await _notasApi.getNotas(
              pageNumber: pageNumber, idSolicitud: idSolicitud);
          break;
        case false:
          resp = await _notasApi.getNotas(
              pageNumber: pageNumber,
              usuario: usuario!.id ?? "",
              idSolicitud: idSolicitud);
          break;
        default:
      }
    }
    if (resp is Success) {
      notasResponse = resp.response as NotasResponse;
      notas = notasResponse.data;
      ordenar();
      hasNextPage = notasResponse.hasNextPage;
      notifyListeners();
    }
    if (resp is Failure) {
      Dialogs.error(msg: resp.messages[0]);
    }
    if (resp is TokenFail) {
      _navigationService.navigateToPageAndRemoveUntil(LoginView.routeName);
      Dialogs.error(msg: 'Sesión expirada');
    }
    cargando = false;
  }

  bool tienePermiso(String permisoRequerido) {
    for (var permisoRol in profilePermisoResponse.data) {
      for (var permiso in permisoRol.permisos!) {
        if (permiso.descripcion == permisoRequerido) return true;
      }
    }
    return false;
  }

  Future<void> cargarMasNotas() async {
    pageNumber += 1;
    var resp = await _notasApi.getNotas(pageNumber: pageNumber);
    if (resp is Success) {
      var temp = resp.response as NotasResponse;
      notasResponse.data.addAll(temp.data);
      notas.addAll(temp.data);
      ordenar();
      hasNextPage = temp.hasNextPage;
      notifyListeners();
    }
    if (resp is Failure) {
      pageNumber -= 1;
      Dialogs.error(msg: resp.messages[0]);
    }
    if (resp is TokenFail) {
      _navigationService.navigateToPageAndRemoveUntil(LoginView.routeName);
      Dialogs.error(msg: 'Sesión expirada');
    }
  }

  Future<void> buscarNotas(String query) async {
    cargando = true;

    Object resp = Failure;
    if (idSolicitud == 0) {
      switch (usuario!.roles!.any((element) =>
          element.roleName == "AprobadorTasaciones" ||
          element.roleName == "Administrador")) {
        case true:
          resp =
              await _notasApi.getNotas(pageNumber: pageNumber, titulo: query);
          break;
        case false:
          resp = await _notasApi.getNotas(
              pageNumber: pageNumber,
              usuario: usuario!.id ?? "",
              titulo: query);
          break;
        default:
      }
    } else {
      switch (usuario!.roles!
          .any((element) => element.roleName == "AprobadorTasaciones")) {
        case true:
          resp = await _notasApi.getNotas(
              pageNumber: pageNumber, idSolicitud: idSolicitud, titulo: query);
          break;
        case false:
          resp = await _notasApi.getNotas(
              pageNumber: pageNumber,
              usuario: usuario!.id ?? "",
              idSolicitud: idSolicitud,
              titulo: query);
          break;
        default:
      }
    }

    if (resp is Success) {
      var temp = resp.response as NotasResponse;
      notas = temp.data;
      ordenar();
      hasNextPage = temp.hasNextPage;
      _busqueda = true;
      notifyListeners();
    }
    if (resp is Failure) {
      Dialogs.error(msg: resp.messages[0]);
    }
    if (resp is TokenFail) {
      _navigationService.navigateToPageAndRemoveUntil(LoginView.routeName);
      Dialogs.error(msg: 'Sesión expirada');
    }
    cargando = false;
  }

  void limpiarBusqueda() {
    _busqueda = false;
    notas = notasResponse.data;
    if (notas.length >= 20) {
      hasNextPage = true;
    }
    notifyListeners();
    tcBuscar.clear();
  }

  Future<void> onRefresh() async {
    notas = [];
    cargando = true;
    Object resp = Failure;
    if (idSolicitud == 0) {
      switch (usuario!.roles!.any((element) =>
          element.roleName == "AprobadorTasaciones" ||
          element.roleName == "Administrador")) {
        case true:
          resp = await _notasApi.getNotas(pageNumber: pageNumber);
          break;
        case false:
          resp = await _notasApi.getNotas(
              pageNumber: pageNumber, usuario: usuario!.id ?? "");
          break;
        default:
      }
    } else {
      switch (usuario!.roles!
          .any((element) => element.roleName == "AprobadorTasaciones")) {
        case true:
          resp = await _notasApi.getNotas(
              pageNumber: pageNumber, idSolicitud: idSolicitud);
          break;
        case false:
          resp = await _notasApi.getNotas(
              pageNumber: pageNumber,
              usuario: usuario!.id ?? "",
              idSolicitud: idSolicitud);
          break;
        default:
      }
    }
    if (resp is Success) {
      var temp = resp.response as NotasResponse;
      notasResponse = temp;
      notas = temp.data;
      ordenar();
      hasNextPage = temp.hasNextPage;
      notifyListeners();
    }
    if (resp is Failure) {
      Dialogs.error(msg: resp.messages[0]);
    }
    if (resp is TokenFail) {
      _navigationService.navigateToPageAndRemoveUntil(LoginView.routeName);
      Dialogs.error(msg: 'Sesión expirada');
    }
    cargando = false;
  }

  Future<void> modificarNota(BuildContext ctx, NotasData nota) async {
    tcNewDescription.text = nota.descripcion;
    tcNewTitulo.text = nota.titulo;

    int idx = nota.fechaHora.indexOf("T");
    List parts = [
      nota.fechaHora.substring(0, idx).trim(),
      nota.fechaHora.substring(idx + 1).trim()
    ];
    tcNewFechaMostrar.text = formatFecha(parts[0]);
    tcNewFechaCompromiso.text = parts[0];
    tcNewHoraCompromiso.text = parts[1];

    bool readOnly = tienePermiso("Actualizar NotasSolicitud");
    bool eliminar = tienePermiso("Eliminar NotasSolicitud");
    final GlobalKey<FormState> _formKey = GlobalKey();
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return AlertDialog(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.zero,
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 80,
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: AppColors.brownLight,
                    child: const Text(
                      'Modificar nota',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        readOnly: !readOnly,
                        controller: tcNewTitulo,
                        validator: (value) {
                          if (value!.trim() == '' || value.length > 50) {
                            return 'Escriba un titulo válido';
                          } else {
                            return null;
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: "Titulo",
                          label: Text("Titulo"),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.datetime,
                        readOnly: true,
                        controller: tcNewFechaMostrar,
                        validator: (value) {
                          if (value!.trim() == '') {
                            return 'Seleccione una fecha';
                          } else {
                            return null;
                          }
                        },
                        decoration: const InputDecoration(
                          label: Text("Fecha"),
                          suffixIcon: Icon(Icons.calendar_today),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.datetime,
                        readOnly: true,
                        initialValue: DateFormat("h:mma")
                            .format(DateTime.parse("2012-02-27 " + parts[1])),
                        validator: (value) {
                          if (value!.trim() == '') {
                            return 'Seleccione una hora';
                          } else {
                            return null;
                          }
                        },
                        decoration: const InputDecoration(
                          label: Text("Hora"),
                          suffixIcon: Icon(Icons.alarm),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: tcNewDescription,
                        readOnly: !readOnly,
                        maxLines: 5,
                        validator: (value) {
                          if (value!.trim() == '' || value.length > 1500) {
                            return 'Escriba una descripción válida';
                          } else {
                            return null;
                          }
                        },
                        decoration: const InputDecoration(
                          label: Text("Descripción"),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      eliminar
                          ? TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Dialogs.confirm(ctx,
                                    tittle: 'Eliminar Nota',
                                    description:
                                        '¿Esta seguro de eliminar la nota ${nota.titulo}?',
                                    confirm: () async {
                                  ProgressDialog.show(ctx);
                                  var resp =
                                      await _notasApi.deleteNota(id: nota.id);
                                  ProgressDialog.dissmiss(ctx);
                                  if (resp is Failure) {
                                    Dialogs.error(msg: resp.messages[0]);
                                  }
                                  if (resp is TokenFail) {
                                    _navigationService
                                        .navigateToPageAndRemoveUntil(
                                            LoginView.routeName);
                                    Dialogs.error(msg: 'Sesión expirada');
                                  }
                                  if (resp is Success) {
                                    Dialogs.success(msg: 'Nota eliminada');
                                    await onRefresh();
                                  }
                                });
                              }, // button pressed
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const <Widget>[
                                  Icon(
                                    AppIcons.trash,
                                    color: AppColors.grey,
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ), // icon
                                  Text("Eliminar"), // text
                                ],
                              ),
                            )
                          : TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                tcNewDescription.clear();
                              }, // button pressed
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const <Widget>[
                                  Icon(
                                    AppIcons.closeCircle,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ), // icon
                                  Text("Cancelar"), // text
                                ],
                              ),
                            ),
                      eliminar
                          ? TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                tcNewDescription.clear();
                              }, // button pressed
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const <Widget>[
                                  Icon(
                                    AppIcons.closeCircle,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ), // icon
                                  Text("Cancelar"), // text
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                      TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (tcNewDescription.text.trim() !=
                                    nota.descripcion ||
                                tcNewFechaCompromiso.text.trim() +
                                        "T" +
                                        tcNewHoraCompromiso.text.trim() !=
                                    nota.fechaHora ||
                                tcNewTitulo.text.trim() != nota.titulo) {
                              ProgressDialog.show(context);
                              var resp = await _notasApi.updateNota(
                                  titulo: tcNewTitulo.text.trim(),
                                  descripcion: tcNewDescription.text.trim(),
                                  id: nota.id);
                              ProgressDialog.dissmiss(context);
                              if (resp is Success) {
                                Dialogs.success(msg: 'Nota Actualizada');
                                Navigator.of(context).pop();
                                await onRefresh();
                              }

                              if (resp is Failure) {
                                ProgressDialog.dissmiss(context);
                                Dialogs.error(msg: resp.messages[0]);
                              }
                              if (resp is TokenFail) {
                                _navigationService.navigateToPageAndRemoveUntil(
                                    LoginView.routeName);
                                Dialogs.error(msg: 'Sesión expirada');
                              }
                              tcNewDescription.clear();
                            } else {
                              Dialogs.success(msg: 'Nota Actualizada');
                              Navigator.of(context).pop();
                            }
                          }
                        }, // button pressed
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(
                              AppIcons.save,
                              color: AppColors.green,
                            ),
                            SizedBox(
                              height: 3,
                            ), // icon
                            Text("Guardar"), // text
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
  }

  Future<void> crearNotas(BuildContext ctx) async {
    tcNewDescription.clear();
    tcNewTitulo.clear();
    final GlobalKey<FormState> _formKey = GlobalKey();
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return AlertDialog(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.zero,
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 80,
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: AppColors.brownLight,
                    child: const Text(
                      'Crear Nota',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: tcNewTitulo,
                        validator: (value) {
                          if (value!.trim() == '' || value.length > 50) {
                            return 'Escriba un titulo válido';
                          } else {
                            return null;
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: "Titulo",
                          label: Text("Titulo"),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: tcNewDescription,
                        validator: (value) {
                          if (value!.trim() == '' || value.length > 1500) {
                            return 'Escriba una descripción válida';
                          } else {
                            return null;
                          }
                        },
                        maxLines: 5,
                        decoration: const InputDecoration(
                          label: Text("Descripción"),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          tcNewDescription.clear();
                          tcNewTitulo.clear();
                        }, // button pressed
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(
                              AppIcons.closeCircle,
                              color: Colors.red,
                            ),
                            SizedBox(
                              height: 3,
                            ), // icon
                            Text("Cancelar"), // text
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            ProgressDialog.show(context);
                            var resp = await _notasApi.createNota(
                                titulo: tcNewTitulo.text.trim(),
                                idSolicitud: idSolicitud,
                                descripcion: tcNewDescription.text.trim());
                            ProgressDialog.dissmiss(context);
                            if (resp is Success) {
                              Dialogs.success(msg: 'Nota Creada');
                              Navigator.of(context).pop();
                              await onRefresh();
                            }

                            if (resp is Failure) {
                              ProgressDialog.dissmiss(context);
                              Dialogs.error(msg: resp.messages[0]);
                            }
                            if (resp is TokenFail) {
                              _navigationService.navigateToPageAndRemoveUntil(
                                  LoginView.routeName);
                              Dialogs.error(msg: 'Sesión expirada');
                            }
                            tcNewDescription.clear();
                            tcNewFechaCompromiso.clear();
                            tcNewFechaMostrar.clear();
                            tcNewHoraCompromiso.clear();
                            tcNewTitulo.clear();
                          }
                        }, // button pressed
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(
                              AppIcons.save,
                              color: AppColors.green,
                            ),
                            SizedBox(
                              height: 3,
                            ), // icon
                            Text("Guardar"), // text
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    listController.dispose();
    tcNewDescription.dispose();
    tcNewTitulo.dispose();
    tcBuscar.dispose();
    super.dispose();
  }
}
