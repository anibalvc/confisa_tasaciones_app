library alarmas_view;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import 'package:tasaciones_app/core/providers/profile_permisos_provider.dart';
import 'package:tasaciones_app/theme/theme.dart';
import 'package:tasaciones_app/widgets/appbar_widget.dart';
import 'package:tasaciones_app/widgets/progress_widget.dart';
import '../../../widgets/refresh_widget.dart';
import 'alarmas_view_model.dart';

part 'alarmas_mobile.dart';

class AlarmasView extends StatelessWidget {
  static const routeName = 'Alarmas';
  final bool showCreate;
  final int idSolicitud;
  const AlarmasView({
    Key? key,
    required this.showCreate,
    required this.idSolicitud,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AlarmasViewModel viewModel = AlarmasViewModel(idSolicitud: idSolicitud);
    viewModel.profilePermisoResponse =
        Provider.of<ProfilePermisosProvider>(context, listen: false)
            .profilePermisos;
    return ViewModelBuilder<AlarmasViewModel>.reactive(
        viewModelBuilder: () => viewModel,
        onModelReady: (viewModel) {
          viewModel.onInit(context);
          // Do something once your viewModel is initialized
        },
        builder: (context, viewModel, child) {
          return _AlarmasMobile(viewModel, showCreate, idSolicitud);
        });
  }
}
