import 'package:get_it/get_it.dart';

import '../feature/hand_tracker/data/datasources/hand_detection_local_data_source.dart';
import '../feature/hand_tracker/data/repositories/hand_detection_repository.dart';
import '../feature/hand_tracker/data/repositories/hand_detection_repository_impl.dart';
import '../feature/hand_tracker/presentation/viewmodels/hand_tracker_viewmodel.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<HandDetectionLocalDataSource>(
    () => HandDetectionLocalDataSource(),
  );

  sl.registerLazySingleton<HandDetectionRepository>(
    () =>
        HandDetectionRepositoryImpl(source: sl<HandDetectionLocalDataSource>()),
  );

  sl.registerFactory<HandTrackerViewModel>(
    () => HandTrackerViewModel(repository: sl<HandDetectionRepository>()),
  );
}
