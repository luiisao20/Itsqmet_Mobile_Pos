import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/tipo_identificacion.dart';

class RegisterState extends Equatable {
  const RegisterState({
    this.tipoIdentificacion = TipoIdentificacion.cedula,
    this.loading = false,
    this.errorMessage,
  });

  final TipoIdentificacion tipoIdentificacion;
  final bool loading;
  final String? errorMessage;

  @override
  List<Object?> get props => [tipoIdentificacion, loading, errorMessage];
}
