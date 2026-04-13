import 'package:flutter/material.dart';
import 'package:front/features/candidatura/viewmodel/candidatura_viewmodel.dart';
import 'package:front/features/projects/components/candidatura_card.dart';
import 'package:provider/provider.dart';
import '../../candidatura/model/candidatura_model.dart';
import '../../projects/model/project_model.dart';
import '../../projects/view/project_detail_page.dart';
import '../../projects/view/project_form_page.dart';
import '../../projects/viewmodel/project_list_viewmodel.dart';
import '../../position/viewmodel/position_list_viewmodel.dart';

class MyProjectsPage extends StatefulWidget {
  const MyProjectsPage({super.key});

  @override
  State<MyProjectsPage> createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends State<MyProjectsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Todos';
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  final List<String> _filters = ['Todos', 'Publicado', 'Rascunho', 'Candidaturas'];

  static const Color _purple = Color(0xFF6B21A8);

  bool get _isCandidaturas => _selectedFilter == 'Candidaturas';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtra projetos por texto de busca e filtro de status selecionado.
  List<Project> _applyFilters(List<Project> projetos) {
    return projetos.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.descricao.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'Todos' ||
          (_selectedFilter == 'Rascunho' && p.rascunho == true) ||
          (_selectedFilter == 'Publicado' && p.rascunho == false);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // Retorna a fatia da página atual para a lista de projetos.
  List<Project> _paginate(List<Project> filtered) {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, filtered.length);
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end);
  }

  // Retorna a fatia da página atual para a lista de candidaturas.
  List<Candidatura> _paginateCandidaturas(List<Candidatura> filtered) {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, filtered.length);
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end);
  }

  // Recarrega projetos e candidaturas simultaneamente.
  Future<void> _onRefresh(ProjectListViewModel projectVm, CandidaturaListViewModel candidaturaVm) async {
    await Future.wait([
      projectVm.carregarMeusProjetos(),
      candidaturaVm.carregar(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProjectListViewModel()..carregarMeusProjetos(),
        ),
        ChangeNotifierProvider(create: (_) => PositionListViewModel()),
        ChangeNotifierProvider(
          create: (_) => CandidaturaListViewModel()..carregar(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer2<ProjectListViewModel, CandidaturaListViewModel>(
            builder: (context, projectVm, candidaturaVm, _) {
              // Sincroniza o texto de busca com o viewmodel de candidaturas.
              if (candidaturaVm.searchQuery != _searchQuery) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  candidaturaVm.setSearch(_searchQuery);
                });
              }

              final filtered = _isCandidaturas ? <Project>[] : _applyFilters(projectVm.projetos);
              final filteredCandidaturas = candidaturaVm.filtradas;

              final totalItems = _isCandidaturas ? filteredCandidaturas.length : filtered.length;
              final totalPages = (totalItems / _itemsPerPage).ceil().clamp(1, 999);

              final paginatedProjetos = _isCandidaturas ? <Project>[] : _paginate(filtered);
              final paginatedCandidaturas = _isCandidaturas
                  ? _paginateCandidaturas(filteredCandidaturas)
                  : <Candidatura>[];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, projectVm),
                  const SizedBox(height: 16),
                  _buildSearchBar(candidaturaVm),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Expanded(
                    child: RefreshIndicator(
                      color: _purple,
                      onRefresh: () => _onRefresh(projectVm, candidaturaVm),
                      child: _isCandidaturas
                          ? _buildCandidaturasList(candidaturaVm, paginatedCandidaturas, filteredCandidaturas)
                          : _buildProjetosList(projectVm, filtered, paginatedProjetos),
                    ),
                  ),
                  if (totalItems > 0) _buildPagination(totalPages),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Constrói o cabeçalho com botão de voltar e botão de novo projeto.
  Widget _buildHeader(BuildContext context, ProjectListViewModel projectVm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (Navigator.of(context).canPop())
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.chevron_left, size: 22, color: Colors.black87),
                    ),
                  ),
                ),
              const Text(
                'Meus projetos',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          if (!_isCandidaturas)
            ElevatedButton.icon(
              onPressed: () => _navigateToAddProject(context, projectVm),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Novo projeto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }

  // Constrói o campo de busca e propaga o valor para o vm de candidaturas.
  Widget _buildSearchBar(CandidaturaListViewModel candidaturaVm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        onChanged: (v) {
          setState(() {
            _searchQuery = v;
            _currentPage = 1;
          });
          candidaturaVm.setSearch(v);
        },
        decoration: InputDecoration(
          hintText: 'Buscar',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // Renderiza os chips de filtro animados.
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _filters.map((f) {
          final selected = _selectedFilter == f;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedFilter = f;
              _currentPage = 1;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? _purple : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? _purple : Colors.grey.shade300),
              ),
              child: Text(
                f,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Exibe a lista paginada de projetos com estados de loading e vazio.
  Widget _buildProjetosList(ProjectListViewModel vm, List<Project> filtered, List<Project> paginated) {
    if (vm.loading && vm.projetos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.projetos.isEmpty) return _buildEmpty(isCandidatura: false);
    if (filtered.isEmpty) return _buildNenhumEncontrado();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: paginated.length,
      itemBuilder: (ctx, i) => _buildProjectCard(ctx, paginated[i], vm),
    );
  }

  // Exibe a lista paginada de candidaturas com estados de loading e vazio.
  Widget _buildCandidaturasList(
    CandidaturaListViewModel vm,
    List<Candidatura> paginated,
    List<Candidatura> filtered,
  ) {
    if (vm.loading) return const Center(child: CircularProgressIndicator());
    if (vm.candidaturas.isEmpty) return _buildEmpty(isCandidatura: true);
    if (filtered.isEmpty) return _buildNenhumEncontrado();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: paginated.length,
      itemBuilder: (_, i) => CandidaturaCard(candidatura: paginated[i]),
    );
  }

  // Tela de estado vazio diferenciada para projetos e candidaturas.
  Widget _buildEmpty({required bool isCandidatura}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCandidatura ? Icons.inbox_outlined : Icons.folder_open,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            isCandidatura ? 'Nenhuma candidatura ainda' : 'Nenhum projeto encontrado',
            style: TextStyle(fontSize: 18, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            isCandidatura
                ? 'Candidate-se a vagas para vê-las aqui'
                : 'Clique em "+ Novo projeto" para começar',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Tela exibida quando a busca não retorna resultados.
  Widget _buildNenhumEncontrado() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('Nenhum resultado encontrado',
              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  // Card de projeto com ações de editar, excluir e badge de rascunho.
  Widget _buildProjectCard(BuildContext context, Project projeto, ProjectListViewModel vm) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToProjectDetail(context, projeto),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoverImage(projeto),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(projeto.nome,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ),
                      GestureDetector(
                        onTap: () => _navigateToEditProject(context, projeto, vm),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.edit_outlined, color: _purple, size: 20),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _confirmDelete(context, projeto, vm),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildRascunhoBadge(projeto.rascunho),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(projeto.descricao,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  if (projeto.tipo != null)
                    _buildInfoRow(Icons.info_outline, _formatTipo(projeto.tipo!)),
                  const SizedBox(height: 6),
                  if (projeto.dataInicio != null)
                    _buildInfoRow(Icons.calendar_today_outlined, 'Início: ${_formatDate(projeto.dataInicio!)}'),
                  const SizedBox(height: 6),
                  if (projeto.criadoPorNome != null)
                    _buildInfoRow(Icons.people_outline, 'Criado por ${projeto.criadoPorNome!}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Exibe a imagem de capa do projeto ou um placeholder escuro.
  Widget _buildCoverImage(Project projeto) {
    if (projeto.imagem != null && projeto.imagem!.isNotEmpty) {
      return SizedBox(
        height: 160,
        width: double.infinity,
        child: Image.network(projeto.imagem!,
            fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholderCover()),
      );
    }
    return _placeholderCover();
  }

  Widget _placeholderCover() => Container(
        height: 160,
        width: double.infinity,
        color: Colors.grey[900],
        child: const Center(child: Icon(Icons.image_outlined, color: Colors.white30, size: 48)),
      );

  // Badge colorido indicando se o projeto é rascunho ou publicado.
  Widget _buildRascunhoBadge(bool rascunho) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: rascunho ? Colors.orange.shade100 : _purple,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          rascunho ? 'Rascunho' : 'Publicado',
          style: TextStyle(
            color: rascunho ? Colors.orange.shade800 : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  // Linha de informação com ícone à esquerda e texto truncado.
  Widget _buildInfoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 15, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );

  // Converte a chave interna do tipo para label legível.
  String _formatTipo(String tipo) {
    const labels = {
      'produto_digital': 'Produto digital',
      'servico': 'Serviço',
      'pesquisa': 'Pesquisa',
      'outro': 'Outro',
    };
    return labels[tipo] ?? tipo;
  }

  // Formata DateTime para o padrão dd/MM/yyyy.
  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  // Controles de paginação com botões anterior, páginas numeradas e próximo.
  Widget _buildPagination(int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PageButton(
            icon: Icons.chevron_left,
            onTap: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
          ),
          const SizedBox(width: 4),
          ...List.generate(totalPages, (i) {
            final page = i + 1;
            final isSelected = page == _currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => setState(() => _currentPage = page),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? _purple : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Text('$page',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      )),
                ),
              ),
            );
          }),
          const SizedBox(width: 4),
          _PageButton(
            icon: Icons.chevron_right,
            onTap: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
          ),
        ],
      ),
    );
  }

  // Navega para a página de detalhe do projeto selecionado.
  void _navigateToProjectDetail(BuildContext context, Project projeto) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectDetailPage(project: projeto)));
  }

  // Navega para o formulário de edição e recarrega a lista ao voltar.
  void _navigateToEditProject(BuildContext context, Project projeto, ProjectListViewModel vm) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectFormPage(projetoId: projeto.id)))
        .then((updated) {
      if (updated == true && context.mounted) vm.carregarMeusProjetos();
    });
  }

  // Navega para o formulário de criação e recarrega a lista ao voltar.
  void _navigateToAddProject(BuildContext context, ProjectListViewModel vm) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectFormPage()))
        .then((value) {
      if (value == true && context.mounted) vm.carregarMeusProjetos();
    });
  }

  // Exibe diálogo de confirmação antes de excluir o projeto.
  void _confirmDelete(BuildContext context, Project projeto, ProjectListViewModel vm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir projeto'),
        content: Text('Tem certeza que deseja excluir "${projeto.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final sucesso = await vm.excluirProjeto(projeto.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(sucesso ? 'Projeto excluído' : 'Erro ao excluir'),
                  backgroundColor: sucesso ? Colors.green : Colors.red,
                ));
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _PageButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: onTap != null ? Colors.black87 : Colors.grey[300]),
      ),
    );
  }
}