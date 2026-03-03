import '../viewmodel/profile_viewmodel.dart';

class ProfileController {
  final ProfileViewModel viewModel;

  ProfileController(this.viewModel);

  Future<void> init() async {
    await viewModel.loadProfile();
  }
}