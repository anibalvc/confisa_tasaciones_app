import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../base_widgets/base_form_widget.dart';
import '../../../base_widgets/base_text_field_widget.dart';
import '../../consultar_modificar_view_model.dart';

class GeneralesA extends StatelessWidget {
  const GeneralesA(
    this.vm, {
    Key? key,
  }) : super(key: key);

  final ConsultarModificarViewModel vm;

  @override
  Widget build(BuildContext context) {
    return BaseFormWidget(
      iconHeader: Icons.add_chart_sharp,
      titleHeader: 'Generales',
      iconBack: Icons.arrow_back_ios,
      labelBack: 'Cancelar',
      onPressedBack: () => Navigator.of(context).pop(),
      iconNext: Icons.arrow_forward_ios,
      labelNext: 'Siguiente',
      isValoracion: (vm.solicitud.tipoTasacion != 21 &&
                  vm.solicitud.estadoTasacion == 9) ||
              (vm.solicitud.estadoTasacion == 10 && vm.isOficial)
          ? true
          : false,
      onPressedNext: () => vm.currentForm = 2,
      child: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.white,
        child: Column(
          children: [
            BaseTextFieldNoEdit(
              label: 'Tipo de Solicitud',
              initialValue: vm.solicitud.descripcionTipoTasacion ?? '',
            ),
            BaseTextFieldNoEdit(
              label: 'Fecha de Solicitud',
              initialValue: DateFormat.yMMMMd('es')
                  .format(vm.solicitud.fechaCreada!)
                  .toUpperCase(),
            ),
            BaseTextFieldNoEdit(
              label: 'No. de Solicitud',
              initialValue: vm.solicitud.noSolicitudCredito.toString(),
            ),
            BaseTextFieldNoEdit(
              label: 'No. de Tasación',
              initialValue: vm.solicitud.noTasacion.toString(),
            ),
            BaseTextFieldNoEdit(
              label: 'Entidad Solicitante',
              initialValue: vm.solicitud.descripcionEntidad ?? '',
            ),
            BaseTextFieldNoEdit(
              label: 'Cédula del Cliente',
              initialValue: vm.solicitud.identificacion ?? '',
            ),
            BaseTextFieldNoEdit(
              label: 'Nombre del Cliente',
              initialValue: vm.solicitud.nombreCliente ?? '',
            ),
            BaseTextFieldNoEdit(
              label: 'Oficial de Negocios',
              initialValue: vm.solicitud.nombreOficial ?? 'No disponible',
            ),
            BaseTextFieldNoEdit(
              label: 'Sucursal',
              initialValue: vm.solicitud.descripcionSucursal ?? '',
            ),
          ],
        ),
      ),
    );
  }
}
