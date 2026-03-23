import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/profile_viewmodel.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController bioController;
  late TextEditingController linkedinController;
  late TextEditingController formacaoController;
  late TextEditingController novaFormacaoController;

  String? selectedCargo;
  String? selectedSenioridade;
  String? selectedArea;

  // Inicializa controllers com dados do perfil atual
  @override
  void initState() {
    super.initState();
    final vm = context.read<ProfileViewModel>();
    final profile = vm.profile!;

    bioController = TextEditingController(text: profile.bio);
    linkedinController = TextEditingController(text: profile.linkedin);
    formacaoController = TextEditingController(text: profile.formacao);
    novaFormacaoController = TextEditingController();

    selectedCargo = profile.cargo;
    selectedSenioridade = profile.senioridade;
    selectedArea = profile.area;

    // FIX: usa addPostFrameCallback para evitar setState() during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.initForm(profile);
      vm.loadChoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu perfil'),
        actions: [
          TextButton.icon(
            onPressed: vm.isLoading ? null : () => _salvar(vm),
            icon: const Icon(Icons.save, size: 16),
            label: const Text('Salvar'),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatarSection(vm),
                    const SizedBox(height: 16),
                    _buildInfoCard(vm),
                    const SizedBox(height: 16),
                    _buildHabilidadesCard(vm),
                    const SizedBox(height: 16),
                    _buildFormacaoCard(vm),
                  ],
                ),
              ),
            ),
    );
  }

  // Avatar com nome somente leitura
  Widget _buildAvatarSection(ProfileViewModel vm) {
    final profile = vm.profile!;
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
            profile.username,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }

  // Card com email readonly, bio, linkedin, formacao e dropdowns profissionais
  Widget _buildInfoCard(ProfileViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(vm.profile!.email, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 16),
          _buildTextField('Bio', bioController, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField('LinkedIn', linkedinController, hint: 'https://linkedin.com/in/...'),
          const SizedBox(height: 16),
          _buildTextField('Formação', formacaoController, hint: 'Ex: Bacharel em Design'),
          const SizedBox(height: 16),
          _buildDropdown('Cargo', vm.cargos, selectedCargo, (v) => setState(() => selectedCargo = v)),
          const SizedBox(height: 16),
          _buildDropdown('Senioridade', vm.senioridades, selectedSenioridade, (v) => setState(() => selectedSenioridade = v)),
          const SizedBox(height: 16),
          _buildDropdown('Área', vm.areas, selectedArea, (v) => setState(() => selectedArea = v)),
        ],
      ),
    );
  }

  // Card de habilidades com input e chips removíveis
  Widget _buildHabilidadesCard(ProfileViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Habilidades',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: vm.habilidadeController,
                  decoration: InputDecoration(
                    hintText: 'Ex: Figma',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: vm.addHabilidade,
                icon: const Icon(Icons.add, color: Colors.deepPurple),
              ),
            ],
          ),
          if (vm.habilidades.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: vm.habilidades
                  .map((h) => _chipRemovivel(h, () => vm.removeHabilidade(h)))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  // Card de formação acadêmica com input e lista removível
  Widget _buildFormacaoCard(ProfileViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Formação',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: novaFormacaoController,
                  decoration: InputDecoration(
                    hintText: 'Ex: Bacharel em Design - Univ...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  final value = novaFormacaoController.text.trim();
                  if (value.isNotEmpty) {
                    vm.addCertificacao();
                    novaFormacaoController.clear();
                  }
                },
                icon: const Icon(Icons.add, color: Colors.deepPurple),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...vm.certificacoes
              .map((c) => _formacaoEditavel(c, () => vm.removeCertificacao(c)))
              .toList(),
        ],
      ),
    );
  }

  // Item de formação com botão remover
  Widget _formacaoEditavel(String text, VoidCallback onRemove) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text)),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 18),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  // Chip roxo com botão X
  Widget _chipRemovivel(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }

  // Campo de texto padrão com borda arredondada
  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  // Dropdown para seleção de opções vindas da API
  Widget _buildDropdown(
    String label,
    List<Map<String, dynamic>> options,
    String? value,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text('Selecione $label'),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: options
              .map((e) => DropdownMenuItem<String>(
                    value: e["value"],
                    child: Text(e["label"]),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Salva perfil e volta para tela anterior
  Future<void> _salvar(ProfileViewModel vm) async {
    await vm.updateProfile(
      cargo: selectedCargo ?? '',
      senioridade: selectedSenioridade ?? '',
      area: selectedArea ?? '',
      bio: bioController.text.trim(),
      linkedin: linkedinController.text.trim(),
      formacao: formacaoController.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  // Decoração padrão dos cards
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    );
  }

  // Libera controllers ao destruir a tela
  @override
  void dispose() {
    bioController.dispose();
    linkedinController.dispose();
    formacaoController.dispose();
    novaFormacaoController.dispose();
    super.dispose();
  }
}