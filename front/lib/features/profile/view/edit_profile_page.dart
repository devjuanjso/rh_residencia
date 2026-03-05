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

  late TextEditingController cargoController;
  late TextEditingController senioridadeController;
  late TextEditingController areaController;
  late TextEditingController formacaoController;
  late TextEditingController bioController;

  /*
  Inicializa os controllers com os dados atuais do perfil
  */
  @override
  void initState() {
    super.initState();

    final vm = context.read<ProfileViewModel>();
    final profile = vm.profile!;

    cargoController = TextEditingController(text: profile.cargo);
    senioridadeController = TextEditingController(text: profile.senioridade);
    areaController = TextEditingController(text: profile.area);
    formacaoController = TextEditingController(text: profile.formacao);
    bioController = TextEditingController(text: profile.bio);

    // Inicializa listas editáveis no ViewModel
    vm.initForm(profile);
  }

  /*
  Constrói a tela principal
  */
  @override
  Widget build(BuildContext context) {

    final viewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
      ),

      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),

              child: Form(
                key: _formKey,

                child: ListView(
                  children: [

                    _buildField("Cargo", cargoController),
                    _buildField("Senioridade", senioridadeController),
                    _buildField("Área", areaController),
                    _buildField("Formação", formacaoController),
                    _buildField("Bio", bioController, maxLines: 3),

                    const SizedBox(height: 24),

                    // Campo de habilidades
                    _buildSkillSection(
                      "Habilidades",
                      viewModel.habilidadeController,
                      viewModel.habilidades,
                      viewModel.addHabilidade,
                      viewModel.removeHabilidade,
                    ),

                    const SizedBox(height: 24),

                    // Campo de certificações
                    _buildSkillSection(
                      "Certificações",
                      viewModel.certificacaoController,
                      viewModel.certificacoes,
                      viewModel.addCertificacao,
                      viewModel.removeCertificacao,
                    ),

                    const SizedBox(height: 30),

                    /*
                    Botão de salvar perfil
                    */
                    ElevatedButton(
                      onPressed: () async {

                        if (_formKey.currentState!.validate()) {

                          await viewModel.updateProfile(
                            cargo: cargoController.text,
                            senioridade: senioridadeController.text,
                            area: areaController.text,
                            formacao: formacaoController.text,
                            bio: bioController.text,
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text("Salvar"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /*
  Campo padrão de formulário
  */
  Widget _buildField(
    String label,
    TextEditingController controller,
    {int maxLines = 1}
  ) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: TextFormField(
        controller: controller,
        maxLines: maxLines,

        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Campo obrigatório";
          }
          return null;
        },

        decoration: InputDecoration(
          labelText: label,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /*
  Seção dinâmica de habilidades ou certificações
  */
  Widget _buildSkillSection(
    String title,
    TextEditingController controller,
    List<String> items,
    VoidCallback onAdd,
    Function(String) onRemove,
  ) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [

            Expanded(
              child: TextField(
                controller: controller,

                decoration: const InputDecoration(
                  hintText: "Digite e clique +",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: Colors.blue,
              ),

              onPressed: onAdd,
            ),
          ],
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,

          children: items
              .map(
                (item) => Chip(
                  label: Text(item),

                  deleteIcon: const Icon(Icons.close),

                  onDeleted: () => onRemove(item),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}