import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:tasaciones_app/core/authentication_client.dart';
import 'package:tasaciones_app/core/base/base_view_model.dart';
import 'package:tasaciones_app/core/locator.dart';
import 'package:tasaciones_app/core/models/menu_response.dart';
import 'package:tasaciones_app/core/models/roles_claims_response.dart';
import 'package:tasaciones_app/core/models/sign_in_response.dart';
import 'package:tasaciones_app/core/models/usuarios_response.dart';
import 'package:tasaciones_app/core/providers/permisos_provider.dart';

import '../../../core/api/api_status.dart';
import '../../../core/api/roles_api.dart';
import '../../../core/models/roles_response.dart';
import '../../../widgets/app_dialogs.dart';
import '../../core/services/navigator_service.dart';
import '../../core/user_client.dart';

class HomeViewModel extends BaseViewModel {
  final _authenticationClient = locator<AuthenticationClient>();
  final _navigatorService = locator<NavigatorService>();
  final _userClient = locator<UserClient>();
  final _rolesAPI = locator<RolesAPI>();
  bool _loading = false;
  late Session _user;
  late UsuariosData _userData;
  final logger = Logger();
  final List<RolClaimsData> _permisos;
  final MenuResponse _menu;
  HomeViewModel(this._permisos, this._menu);

  List<RolClaimsData> get permisos => _permisos;
  MenuResponse get menu => _menu;

  Session get user => _user;
  UsuariosData get userData => _userData;
  set user(Session value) {
    _user = value;
    notifyListeners();
  }

  set userData(UsuariosData value) {
    _userData = value;
    notifyListeners();
  }

  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> onInit(BuildContext context) async {
    user = _authenticationClient.loadSession;
    userData = _userClient.loadUsuario;
    // await getRoles(context);
  }

  Future<void> getRoles(BuildContext context) async {
    loading = true;
    var resp = await _rolesAPI.getRoles();
    if (resp is Success<RolResponse>) {
      // for (var rolUser in _user.role) {
      //   for (var rolData in resp.response.data) {
      //     // await getPermisos(context, rolUser, rolData);
      //   }
      // }
      loading = false;
    } else if (resp is Failure) {
      Dialogs.error(msg: resp.messages.first);
      loading = false;
    }
  }

  Future<void> getPermisos(
      BuildContext context, String rolUser, RolData data) async {
    if (rolUser == data.description) {
      var resp = await _rolesAPI.getRolesClaims(
        idRol: data.id,
      );
      if (resp is Success<RolClaimsResponse>) {
        for (var rolData in resp.response.data) {
          Provider.of<PermisosUserProvider>(context, listen: false)
              .permisoUser = rolData;
        }
      } else if (resp is Failure) {
        Dialogs.error(msg: resp.messages.first);
      }
    }
  }

  void accesPermisos() => logger.i(_permisos
      .map<String>((e) => "Rol: ${e.id.toString()} ${e.descripcion}")
      .toList());
}
