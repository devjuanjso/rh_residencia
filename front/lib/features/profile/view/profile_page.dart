import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/features/profile/controller/profile_controller.dart';
import 'package:front/features/profile/view/edit_profile_page.dart';
import 'package:front/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:front/features/auth/view/login_page.dart';
import 'package:front/features/auth/viewmodel/auth_viewmodel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<ProfileViewModel>();
      final controller = ProfileController(viewModel);

      try {
        await controller.init();
      } catch (e) {
        final msg = e.toString().toLowerCase();
        final isSessionExpired = msg.contains('expir') ||
            msg.contains('token_not_valid') ||
            msg.contains('sessão expirada') ||
            msg.contains('session');

        if (isSessionExpired) {
          await context.read<AuthViewModel>().logout();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao carregar perfil: $e')),
            );
          }
        }
      }
    });
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthViewModel>().logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final profile = viewModel.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu perfil'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Editar'),
          ),
          IconButton(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
              ? const Center(child: Text('Erro ao carregar perfil'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(profile),
                      const SizedBox(height: 24),
                      _buildInfoCard(profile),
                      const SizedBox(height: 16),
                      _buildHabilidadesCard(profile),
                      const SizedBox(height: 16),
                      _buildFormacaoCard(profile),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader(profile) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.deepPurple,
            backgroundImage: profile.foto != null ? NetworkImage(profile.foto!) : null,
            child: profile.foto == null
                ? const Icon(Icons.person, size: 48, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            profile.nomeCompleto, // exibe nome completo, fallback para username
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (profile.cargo != null) _chip(profile.cargo!),
              if (profile.senioridade != null) _chip(profile.senioridade!),
              if (profile.area != null) _chip(profile.area!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Email', profile.email),
          const SizedBox(height: 12),
          _buildInfoRow('Bio', profile.bio?.isNotEmpty == true ? profile.bio! : '—'),
          const SizedBox(height: 12),
          _buildInfoRow('Formação', profile.formacao?.isNotEmpty == true ? profile.formacao! : '—'),
          const SizedBox(height: 12),
          const Text('LinkedIn', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          profile.linkedin?.isNotEmpty == true
              ? Text(
                  'Ver perfil no LinkedIn',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    decoration: TextDecoration.underline,
                  ),
                )
              : const Text('—', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }

  Widget _buildHabilidadesCard(profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Habilidades',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 12),
          profile.habilidades.isEmpty
              ? const Text('Nenhuma habilidade cadastrada', style: TextStyle(color: Colors.grey))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (profile.habilidades as List<String>)
                      .map((h) => _chip(h))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildFormacaoCard(profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Formação',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 12),
          profile.certificacoes.isEmpty
              ? const Text('Nenhuma formação cadastrada', style: TextStyle(color: Colors.grey))
              : Column(
                  children: (profile.certificacoes as List<String>)
                      .map((c) => _formacaoItem(c))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _formacaoItem(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Text(text),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    );
  }
}