import 'package:flutter/material.dart';
import 'package:tasaciones_app/core/api/api_status.dart';
import 'package:tasaciones_app/core/models/permisos_response.dart';
import 'package:tasaciones_app/widgets/app_dialogs.dart';

import '../../../core/api/acciones_api.dart';
import '../../../core/api/permisos_api.dart';
import '../../../core/api/recursos_api.dart';
import '../../../core/authentication_client.dart';
import '../../../core/base/base_view_model.dart';
import '../../../core/locator.dart';
import '../../../core/models/acciones_response.dart';
import '../../../core/models/recursos_response.dart';
import '../../../core/services/navigator_service.dart';
import '../../../theme/theme.dart';
import '../widgets/forms/form_crear_permiso.dart';

class PermisosViewModel extends BaseViewModel {
  final user = locator<AuthenticationClient>().loadSession;
  final _permisosApi = locator<PermisosAPI>();
  final _accionesApi = locator<AccionesApi>();
  final _recursosApi = locator<RecursosAPI>();
  final listController = ScrollController();
  final _navigationService = locator<NavigatorService>();

  List<PermisosData> permisos = [];
  int pageNumber = 1;
  bool _cargando = false;
  bool hasNextPage = false;

  PermisosViewModel() {
    listController.addListener(() {
      if (listController.position.maxScrollExtent == listController.offset) {
        if (hasNextPage) {
          cargarMasPermisos();
        }
      }
    });
  }

  bool get cargando => _cargando;
  set cargando(bool value) {
    _cargando = value;
    notifyListeners();
  }

  Future<void> onInit() async {
    cargando = true;
    permisos = [];
    pageNumber = 1;
    hasNextPage = false;
    var resp =
        await _permisosApi.getPermisos(pageNumber: pageNumber, pageSize: 20);
    if (resp is Success) {
      var temp = resp.response as PermisosResponse;
      permisos = temp.data;
      hasNextPage = temp.hasNextPage;
      notifyListeners();
    }
    if (resp is Failure) {
      Dialogs.error(msg: resp.messages[0]);
    }
    cargando = false;
  }

  Future<void> cargarMasPermisos() async {
    pageNumber += 1;
    var resp =
        await _permisosApi.getPermisos(pageNumber: pageNumber, pageSize: 20);
    if (resp is Success) {
      var temp = resp.response as PermisosResponse;
      permisos.addAll(temp.data);
      hasNextPage = temp.hasNextPage;
      notifyListeners();
    }
    if (resp is Failure) {
      Dialogs.error(msg: resp.messages[0]);
    }
  }

  Future<void> modificarPermiso(String descripcion, int id, String accionNombre,
      String recursoNombre, BuildContext context) async {
    String permisoDescripcion = descripcion;
    Map<String, dynamic> accion = {};
    Map<String, dynamic> recurso = {};
    dynamic opcion;
    Size size = MediaQuery.of(context).size;
    ProgressDialog.show(context);
    var resp = await _accionesApi.getAcciones();
    if (resp is Success<AccionesResponse>) {
      var resp2 = await _recursosApi.getRecursos();
      if (resp2 is Success<RecursosResponse>) {
        ProgressDialog.dissmiss(context);
        final GlobalKey<FormState> _formKey = GlobalKey();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  content: formCrearPermiso(
                      "Modificacion de Permiso",
                      _formKey,
                      descripcion,
                      recurso,
                      accion, (String descripcionf) async {
                    ProgressDialog.show(context);
                    var creacion = await _permisosApi.updatePermisos(
                        id: id,
                        descripcion: descripcionf,
                        idAccion: accion["id"] ?? 0,
                        idRecurso: recurso["id"] ?? 0,
                        esBasico: 1);
                    if (creacion is Success<PermisosPOSTResponse>) {
                      ProgressDialog.dissmiss(context);
                      Dialogs.success(msg: "Modificacion exitosa");
                      _navigationService.pop();
                      onInit();
                    } else if (creacion is Failure) {
                      ProgressDialog.dissmiss(context);
                      Dialogs.error(msg: creacion.messages.first);
                    }
                  }, () async {
                    Dialogs.confirm(context,
                        tittle: "Eliminar Permiso",
                        description:
                            "Esta seguro que desea eliminar el permiso?",
                        confirm: () async {
                      ProgressDialog.show(context);
                      var resp = await _permisosApi.deletePermisos(id: id);
                      if (resp is Success<PermisosPOSTResponse>) {
                        ProgressDialog.dissmiss(context);
                        Dialogs.success(msg: "Eliminado con exito");
                        _navigationService.pop();
                        onInit();
                      } else if (resp is Failure) {
                        ProgressDialog.dissmiss(context);
                        Dialogs.error(msg: resp.messages.first);
                      }
                    });
                  },
                      opcion,
                      resp.response.data,
                      resp2.response.data,
                      [
                        Text("Permiso: $descripcion", style: appDropdown),
                        const SizedBox(
                          height: 3,
                        ),
                        Text("Accion: $accionNombre", style: appDropdown),
                        const SizedBox(
                          height: 3,
                        ),
                        Text("Recurso: $recursoNombre", style: appDropdown)
                      ],
                      size,
                      false,
                      "Modificar",
                      true),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ));
            });
      } else if (resp2 is Failure) {
        ProgressDialog.dissmiss(context);
        Dialogs.error(msg: resp2.messages.first);
      }
    } else if (resp is Failure) {
      ProgressDialog.dissmiss(context);
      Dialogs.error(msg: resp.messages.first);
    }
  }

  Future<void> crearPermiso(BuildContext context, Size size) async {
    String descripcion = "";
    Map<String, dynamic> accion = {};
    Map<String, dynamic> recurso = {};
    dynamic opcion;
    ProgressDialog.show(context);
    var resp = await _accionesApi.getAcciones();
    if (resp is Success<AccionesResponse>) {
      var resp2 = await _recursosApi.getRecursos();
      if (resp2 is Success<RecursosResponse>) {
        ProgressDialog.dissmiss(context);
        final GlobalKey<FormState> _formKey = GlobalKey();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  content: formCrearPermiso(
                      "Creacion de Permiso",
                      _formKey,
                      descripcion,
                      recurso,
                      accion, (String descripcionf) async {
                    ProgressDialog.show(context);
                    var creacion = await _permisosApi.createPermisos(
                        descripcion: descripcionf,
                        idAccion: accion["id"],
                        idRecurso: recurso["id"],
                        esBasico: 1);
                    if (creacion is Success<PermisosData>) {
                      ProgressDialog.dissmiss(context);
                      Dialogs.success(msg: "Creacion exitosa");
                      _formKey.currentState?.reset();
                      _navigationService.pop();
                      onInit();
                    } else if (creacion is Failure) {
                      ProgressDialog.dissmiss(context);
                      Dialogs.error(msg: creacion.messages.first);
                    }
                  }, () {}, opcion, resp.response.data, resp2.response.data, [],
                      size, false, "Crear", false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ));
            });
      } else if (resp2 is Failure) {
        ProgressDialog.dissmiss(context);
        Dialogs.error(msg: resp2.messages.first);
      }
    } else if (resp is Failure) {
      ProgressDialog.dissmiss(context);
      Dialogs.error(msg: resp.messages.first);
    }
  }

  @override
  void dispose() {
    listController.dispose();
    super.dispose();
  }
}
