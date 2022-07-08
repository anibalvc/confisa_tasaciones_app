import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasaciones_app/core/api/api_status.dart';
import 'package:tasaciones_app/core/api/autentication_api.dart';
import 'package:tasaciones_app/core/authentication_client.dart';
import 'package:tasaciones_app/core/base/base_view_model.dart';
import 'package:tasaciones_app/core/locator.dart';
import 'package:tasaciones_app/core/models/sign_in_response.dart';
import 'package:tasaciones_app/core/services/navigator_service.dart';
import 'package:tasaciones_app/views/home/home_view.dart';
import 'package:tasaciones_app/widgets/app_dialogs.dart';

import '../../core/api/roles_api.dart';
import '../../core/models/roles_claims_response.dart';
import '../../core/models/roles_response.dart';
import '../../core/providers/permisos_provider.dart';

class LoginViewModel extends BaseViewModel {
  final _navigationService = locator<NavigatorService>();
  final _authenticationAPI = locator<AuthenticationAPI>();
  final _rolesAPI = locator<RolesAPI>();
  final _autenticationClient = locator<AuthenticationClient>();

  late Session _user;

  TextEditingController tcEmail = TextEditingController();
  TextEditingController tcPassword = TextEditingController();
  bool obscurePassword = true;

  Future<void> signIn(BuildContext context) async {
    ProgressDialog.show(context);
    var resp = await _authenticationAPI.signIn(
      email: tcEmail.text,
      password: tcPassword.text,
    );
    if (resp is Success<SignInResponse>) {
      ProgressDialog.dissmiss(context);
      _autenticationClient.saveSession(resp.response.data);
      _user = resp.response.data;
      await getRoles(context);
      _navigationService.navigateToPageWithReplacement(HomeView.routeName);
    } else if (resp is Failure) {
      ProgressDialog.dissmiss(context);
      Dialogs.alert(
        context,
        tittle: 'Error',
        description: resp.messages,
      );
    }
  }

  Future<void> getRoles(BuildContext context) async {
    ProgressDialog.show(context);
    var resp = await _rolesAPI.getRoles(token: _user.token);
    if (resp is Success<RolResponse>) {
      for (var rolUser in _user.role) {
        for (var rolData in resp.response.data) {
          await getPermisos(context, rolUser, rolData);
        }
      }
    } else if (resp is Failure) {
      ProgressDialog.dissmiss(context);
      Dialogs.alert(
        context,
        tittle: 'Error',
        description: resp.messages,
      );
    }
  }

  Future<void> getPermisos(
      BuildContext context, String rolUser, RolData data) async {
    if (rolUser == data.description) {
      var resp =
          await _rolesAPI.getRolesClaims(idRol: data.id, token: _user.token);
      if (resp is Success<RolClaimsResponse>) {
        ProgressDialog.dissmiss(context);
        for (var rolData in resp.response.data) {
          Provider.of<PermisosProvider>(context, listen: false).permiso =
              rolData;
        }
      } else if (resp is Failure) {
        ProgressDialog.dissmiss(context);
        Dialogs.alert(
          context,
          tittle: 'Error',
          description: resp.messages,
        );
      }
    }
  }

  void changeObscure() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  @override
  void dispose() {
    tcEmail.dispose();
    tcPassword.dispose();
    super.dispose();
  }
}
