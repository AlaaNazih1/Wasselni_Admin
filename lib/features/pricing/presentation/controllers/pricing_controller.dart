import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/service_area_model.dart';
import '../../data/repositories/pricing_repository.dart';

// Repository Provider
final pricingRepositoryProvider = Provider<PricingRepository>((ref) {
  return PricingRepository();
});

// Watch Service Areas
final serviceAreasProvider = StreamProvider<List<ServiceArea>>((ref) {
  final repository = ref.watch(pricingRepositoryProvider);
  return repository.watchServiceAreas();
});

// Actions Controller Provider
final pricingActionsProvider = Provider<PricingActionsController>((ref) {
  final repository = ref.watch(pricingRepositoryProvider);

  return PricingActionsController(repository);
});

class PricingActionsController {
  final PricingRepository _repository;

  PricingActionsController(this._repository);

  Future<void> addServiceArea(ServiceArea area) {
    return _repository.addServiceArea(area);
  }

  Future<void> updateServiceArea(ServiceArea area) {
    return _repository.updateServiceArea(area);
  }

  Future<void> toggleServiceArea(String areaId, bool isActive) {
    return _repository.toggleServiceArea(areaId, isActive);
  }

  Future<void> deleteServiceArea(String areaId) {
    return _repository.deleteServiceArea(areaId);
  }
}
