import 'package:flutter/material.dart';
import 'package:front/features/profile/controller/profile_controller.dart';
import 'package:front/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:provider/provider.dart';
import 'my_projects_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ProfileViewModel>();
    final controller = ProfileController(viewModel);
    controller.init();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final profile = viewModel.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
              ? const Center(child: Text("Erro ao carregar perfil"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// FOTO + NOME
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.blue,
                              backgroundImage: profile.foto != null
                                  ? NetworkImage(profile.foto!)
                                  : null,
                              child: profile.foto == null
                                  ? const Icon(Icons.person,
                                      size: 60, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              profile.username,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              profile.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// INFORMAÇÕES PROFISSIONAIS
                      _sectionTitle("Informações profissionais"),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _capsule(profile.cargo),
                          _capsule(profile.senioridade),
                          _capsule(profile.area),
                          _capsule(profile.role),
                        ],
                      ),

                      const SizedBox(height: 32),

                      /// HABILIDADES
                      _sectionTitle("Habilidades"),
                      const SizedBox(height: 12),
                      profile.habilidades.isEmpty
                          ? _emptyCapsule("Nenhuma habilidade cadastrada")
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: profile.habilidades
                                  .map((h) => _capsule(h))
                                  .toList(),
                            ),

                      const SizedBox(height: 32),

                      /// CERTIFICAÇÕES
                      _sectionTitle("Certificações"),
                      const SizedBox(height: 12),
                      profile.certificacoes.isEmpty
                          ? _emptyCapsule("Nenhuma certificação cadastrada")
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: profile.certificacoes
                                  .map((c) => _capsule(c))
                                  .toList(),
                            ),

                      const SizedBox(height: 40),

                      /// BOTÕES
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyProjectsPage(),
                              ),
                            );
                          },
                          child: const Text("Meus Projetos"),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text("Editar Perfil"),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  /// TÍTULO DE SEÇÃO
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// CÁPSULA PADRÃO
  Widget _capsule(String? text) {
    if (text == null || text.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.blue.shade200),
        color: Colors.blue.shade50,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// CÁPSULA VAZIA
  Widget _emptyCapsule(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade100,
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }
}