import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';

class AdminCrudHost<C extends AdminCrudCubit<T>, T> extends StatefulWidget {
  const AdminCrudHost({
    super.key,
    required this.createRequests,
    required this.onCreate,
    required this.builder,
  });

  final Stream<void> createRequests;
  final void Function(BuildContext context) onCreate;
  final Widget Function(BuildContext context, AdminCrudState<T> state) builder;

  @override
  State<AdminCrudHost<C, T>> createState() => _AdminCrudHostState<C, T>();
}

class _AdminCrudHostState<C extends AdminCrudCubit<T>, T>
    extends State<AdminCrudHost<C, T>> {
  StreamSubscription<void>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.createRequests.listen((_) {
      if (mounted) widget.onCreate(context);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<C, AdminCrudState<T>>(
      listenWhen: (previous, current) =>
          current.error != null && current.error != previous.error,
      listener: (_, state) =>
          NotificationsService.showError(state.error!.message),
      child: BlocBuilder<C, AdminCrudState<T>>(builder: widget.builder),
    );
  }
}
