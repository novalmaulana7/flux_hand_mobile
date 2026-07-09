import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di.dart';
import '../viewmodels/hand_tracker_viewmodel.dart';
import '../widgets/hand_tracker_camera_view.dart';
import '../widgets/hand_tracker_permission_view.dart';

class HandTrackerPage extends StatefulWidget {
  const HandTrackerPage({super.key});

  @override
  State<HandTrackerPage> createState() => _HandTrackerPageState();
}

class _HandTrackerPageState extends State<HandTrackerPage> {
  late final HandTrackerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<HandTrackerViewModel>();
    _viewModel.initializeSession();
  }

  @override
  void dispose() {
    _viewModel.disposeSession();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HandTrackerViewModel>.value(
      value: _viewModel,
      child: Consumer<HandTrackerViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: const Color(0xFF121414),
            body: model.permissionGranted
                ? HandTrackerCameraView(
                    model: model,
                    onToggleStreaming: model.toggleStreaming,
                  )
                : HandTrackerPermissionView(
                    onGrantPermission: model.initializeSession,
                  ),
          );
        },
      ),
    );
  }
}
