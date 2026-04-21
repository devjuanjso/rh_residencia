import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_controller.dart';
import '../viewmodel/profile_viewmodel.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController bioController;
  late TextEditingController linkedinController;
  late TextEditingController formacaoController;
  late TextEditingController novaFormacaoController;

  String? selectedCargo;
  String? selectedSenioridade;
  String? selectedArea;

  @override
  void initState() {
    super.initState();
    final vm = context.read<ProfileViewModel>();
    final profile = vm.profile!;

    firstNameController = TextEditingController(text: profile.firstName);
    lastNameController = TextEditingController(text: profile.lastName);
    emailController = TextEditingController(text: profile.email);
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

  bool _loadingCurriculo = false;

  Future<void> _importarCurriculo(ProfileViewModel vm) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    setState(() => _loadingCurriculo = true);

    final r = await AiController.analisarCurriculo(File(result.files.single.path!));

    setState(() => _loadingCurriculo = false);

    if (!mounted) return;

    if (r.erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(r.erro!), backgroundColor: Colors.red),
      );
      return;
    }

    final dados = r.dados!;

    if (firstNameController.text.isEmpty && dados['nome'] != null) {
      final partes = dados['nome'].toString().split(' ');
      firstNameController.text = partes.first;
      if (partes.length > 1) lastNameController.text = partes.skip(1).join(' ');
    }
    if (emailController.text.isEmpty && dados['email'] != null) {
      emailController.text = dados['email'].toString();
    }
    if (formacaoController.text.isEmpty && dados['formacao'] != null) {
      formacaoController.text = dados['formacao'].toString();
    }
    if (bioController.text.isEmpty && dados['resumo_profissional'] != null) {
      bioController.text = dados['resumo_profissional'].toString();
    }

    vm.importarDoCurriculo(dados);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados importados! Revise e salve.'),
        backgroundColor: Colors.green,
      ),
    );
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
                    _buildCurriculoBanner(vm),
                    const SizedBox(height: 16),
                    _buildAvatarSection(vm),
                    const SizedBox(height: 16),
                    _buildInfoCard(vm),
                    const SizedBox(height: 16),
                    _buildHabilidadesCard(vm),
                    const SizedBox(height: 16),
                    _buildFormacaoCard(vm),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCurriculoBanner(ProfileViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.deepPurple.shade400, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Importar currículo',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple)),
                SizedBox(height: 2),
                Text('A IA extrai habilidades, formação e dados do PDF',
                    style: TextStyle(fontSize: 11, color: Colors.deepPurple)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _loadingCurriculo
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.deepPurple),
                )
              : TextButton.icon(
                  onPressed: () => _importarCurriculo(vm),
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('Importar PDF'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    backgroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.deepPurple),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

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
            profile.nomeCompleto, // exibe nome completo, fallback para username
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ProfileViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Nome', firstNameController, hint: 'Seu nome'),
          const SizedBox(height: 16),
          _buildTextField('Sobrenome', lastNameController, hint: 'Seu sobrenome'),
          const SizedBox(height: 16),
          _buildTextField('Email', emailController, hint: 'seuemail@exemplo.com'),
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

  Future<void> _salvar(ProfileViewModel vm) async {
    await vm.updateProfile(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      cargo: selectedCargo ?? '',
      senioridade: selectedSenioridade ?? '',
      area: selectedArea ?? '',
      bio: bioController.text.trim(),
      linkedin: linkedinController.text.trim(),
      formacao: formacaoController.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    bioController.dispose();
    linkedinController.dispose();
    formacaoController.dispose();
    novaFormacaoController.dispose();
    super.dispose();
  }
}