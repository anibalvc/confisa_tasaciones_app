import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tasaciones_app/views/alarmas/alarmas_view.dart';
import 'package:tasaciones_app/core/models/solicitudes/solicitudes_get_response.dart';
import 'package:tasaciones_app/views/auth/confirm_password/confirm_password_view.dart';
import 'package:tasaciones_app/views/auth/recover_password/recovery_password_view.dart';
import 'package:tasaciones_app/views/entidades_generales/acciones_pendientes/acciones_pendientes_view.dart';
import 'package:tasaciones_app/views/entidades_generales/parametros_servidor_email/parametros_servidor_email_view.dart';
import 'package:tasaciones_app/views/entidades_generales/suplidores/suplidores_view.dart';
import 'package:tasaciones_app/views/entidades_generales/suplidores_default/suplidores_default_view.dart';
import 'package:tasaciones_app/views/entidades_generales/tipos_adjuntos/tipos_adjuntos_view.dart';
import 'package:tasaciones_app/views/entidades_seguridad/acciones/acciones_view.dart';
import 'package:tasaciones_app/views/entidades_seguridad/endpoints/endpoints_view.dart';
import 'package:tasaciones_app/views/entidades_seguridad/roles/roles_view.dart';
import 'package:tasaciones_app/views/entidades_seguridad/usuarios/usuarios_view.dart';
import 'package:tasaciones_app/views/entidades_solicitudes/accesorios/accesorios_view.dart';
import 'package:tasaciones_app/views/entidades_solicitudes/componentes_vehiculo/componentes_vehiculo_view.dart';
import 'package:tasaciones_app/views/entidades_solicitudes/condiciones_componentes_vehiculo.dart/condiciones_componentes_vehiculo_view.dart';
import 'package:tasaciones_app/views/entidades_solicitudes/periodo_eliminacion_data_grafica/periodo_eliminacion_data_grafica_view.dart';
import 'package:tasaciones_app/views/entidades_solicitudes/segmentos_accesorios_vehiculos/segmentos_accesorios_vehiculos_view.dart';
import 'package:tasaciones_app/views/entidades_solicitudes/segmentos_componentes_vehiculos/segmentos_componentes_vehiculos_view.dart';
import 'package:tasaciones_app/views/entidades_solicitudes/vencimiento_estados/vencimiento_estados_view.dart';
import 'package:tasaciones_app/views/notas/notas_view.dart';
import 'package:tasaciones_app/views/solicitudes/cola_solicitudes/cola_solicitudes_view.dart';
import 'package:tasaciones_app/views/solicitudes/solicitud_estimacion/solicitud_estimacion_view.dart';
import 'package:tasaciones_app/widgets/escaner.dart';

import '../views/Perfil_de_usuario/perfil_view.dart';
import '../views/auth/login/login_view.dart';
import '../views/entidades_seguridad/modulos/modulos_view.dart';
import '../views/entidades_seguridad/permisos/permisos_view.dart';
import '../views/entidades_seguridad/recursos/recursos_view.dart';
import '../views/entidades_solicitudes/componentes_vehiculo_suplidor/componentes_vehiculo_suplidor_view.dart';
import '../views/home/home_view.dart';
import '../views/solicitudes/solicitud_tasacion/solicitud_tasacion_view.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case HomeView.routeName:
      return MaterialPageRoute(builder: (context) => const HomeView());

    case LoginView.routeName:
      return MaterialPageRoute(builder: (context) => const LoginView());

    case RecoveryPasswordView.routeName:
      return MaterialPageRoute(
          builder: (context) => const RecoveryPasswordView());

    case ConfirmPasswordView.routeName:
      return MaterialPageRoute(
          builder: (context) => const ConfirmPasswordView());

    case PerfilView.routeName:
      return CupertinoPageRoute(builder: (context) => const PerfilView());

    case AccionesView.routeName:
      return CupertinoPageRoute(builder: (context) => const AccionesView());

    case ModulosView.routeName:
      return CupertinoPageRoute(builder: (context) => const ModulosView());

    case RecursosView.routeName:
      return CupertinoPageRoute(builder: (context) => const RecursosView());

    case PermisosView.routeName:
      return CupertinoPageRoute(builder: (context) => const PermisosView());

    case UsuariosView.routeName:
      return CupertinoPageRoute(builder: (context) => const UsuariosView());

    case EndpointsView.routeName:
      return CupertinoPageRoute(builder: (context) => const EndpointsView());

    case RolesView.routeName:
      return CupertinoPageRoute(builder: (context) => const RolesView());

    case TiposAdjuntosView.routeName:
      return CupertinoPageRoute(
          builder: (context) => const TiposAdjuntosView());

    case AccionesPendientesView.routeName:
      return CupertinoPageRoute(
          builder: (context) => const AccionesPendientesView());

    case ComponentesVehiculoSuplidorView.routeName:
      return CupertinoPageRoute(
          builder: (context) => const ComponentesVehiculoSuplidorView());

    case ComponentesVehiculoView.routeName:
      return CupertinoPageRoute(
          builder: (context) => const ComponentesVehiculoView());

    case SegmentosComponentesVehiculosView.routeName:
      return CupertinoPageRoute(
          builder: (context) => const SegmentosComponentesVehiculosView());

    case SegmentosAccesoriosVehiculosView.routeName:
      return CupertinoPageRoute(
          builder: (context) => const SegmentosAccesoriosVehiculosView());

    case CondicionesComponentesVehiculoView.routeName:
      return CupertinoPageRoute(
          builder: (context) => const CondicionesComponentesVehiculoView());

    case AccesoriosView.routeName:
      return CupertinoPageRoute(builder: (context) => const AccesoriosView());

    case SuplidoresView.routeName:
      return CupertinoPageRoute(builder: (context) => const SuplidoresView());

    case SuplidoresDefaultView.routeName:
      return CupertinoPageRoute(
          builder: (context) => const SuplidoresDefaultView());

    case ParametrosServidorEmailView.routeName:
      return CupertinoPageRoute(
          builder: (context) => const ParametrosServidorEmailView());

    case ColaSolicitudesView.routeName:
      return CupertinoPageRoute(
          builder: (context) => const ColaSolicitudesView());

    case SolicitudEstimacionView.routeName:
      final args = settings.arguments as SolicitudesData;
      return CupertinoPageRoute(
          builder: (context) => SolicitudEstimacionView(solicitudData: args));

    case SolicitudTasacionView.routeName:
      return CupertinoPageRoute(
          builder: (context) => const SolicitudTasacionView());

    case EscanerPage.routeName:
      return CupertinoPageRoute(builder: (context) => const EscanerPage());

    case AlarmasView.routeName:
      return CupertinoPageRoute(builder: (context) => const AlarmasView());

    case NotasView.routeName:
      return CupertinoPageRoute(builder: (context) => const NotasView());

    case VencimientoEstadosView.routeName:
      return CupertinoPageRoute(
          builder: (context) => const VencimientoEstadosView());

    case PeriodoEliminacionDataGraficaView.routeName:
      return CupertinoPageRoute(
          builder: (context) => const PeriodoEliminacionDataGraficaView());

    default:
      return MaterialPageRoute(builder: (context) => const HomeView());
  }
}
