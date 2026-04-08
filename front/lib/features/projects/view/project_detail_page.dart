import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/loading_overlay.dart';
import '../../../core/layout/empty_state.dart';
import '../components/project_card.dart';
import '../components/position_list_item.dart';
import '../../recomendacao/view/candidatos_modal.dart';
import '../../position/model/position_model.dart';
import '../../position/view/position_form_page.dart';
import '../../position/view/position_detail_page.dart';
import '../../position/controller/position_controller.dart';
import '../model/project_model.dart';
import '../controller/project_controller.dart';

class ProjectDetailPage extends StatefulWidget {
  final Project project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  // Lista local de vagas carregadas para este projeto
  final List<Position> _positions = [];

  bool _isLoading = false;
  bool _isTogglingStatus = false;
  String _errorMessage = '';

  // Espelha o status de rascunho do projeto localmente para refletir mudancas sem recarregar
  late bool _isRascunho;

  static const Color _purple = Color(0xFF6B21A8);
  static const Color _purpleLight = Color(0xFFF3E8FF);

  @override
  void initState() {
    super.initState();
    _isRascunho = widget.project.rascunho;
    _loadPositions();
  }

  // Busca as vagas do projeto atual e atualiza o estado
  Future<void> _loadPositions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final positions =
          await ProjectController.buscarVagasPorProjeto(widget.project.id);
      setState(() {
        _positions.clear();
        _positions.addAll(positions);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar vagas: $e';
        _positions.clear();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Alterna o status do projeto entre publicado e rascunho
  Future<void> _handleToggleStatus() async {
    final novoStatus = !_isRascunho;
    setState(() => _isTogglingStatus = true);

    try {
      final sucesso = await ProjectController.atualizarProjetoParcial(
        projetoId: widget.project.id,
        rascunho: novoStatus,
      );

      if (sucesso && mounted) {
        setState(() => _isRascunho = novoStatus);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              novoStatus
                  ? 'Projeto movido para rascunho'
                  : 'Projeto publicado com sucesso!',
            ),
            backgroundColor: novoStatus ? Colors.orange : Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao atualizar status do projeto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingStatus = false);
    }
  }

  // Exibe dialogo de confirmacao antes de excluir a vaga
  void _showDeleteDialog(Position position) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir vaga'),
        content: Text('Tem certeza que deseja excluir "${position.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                // Exclui a vaga e recarrega a lista em caso de sucesso
                await PositionController.delete(position.id);
                if (mounted) await _loadPositions();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao excluir vaga: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCoverImage(),
                    _buildProjectInfo(),
                    const Divider(height: 1),
                    _buildPositionsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Barra superior com botao de voltar, titulo e botao de adicionar vaga
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          _CircleButton(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.chevron_left,
                size: 22, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.project.nome,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          // Botao para navegar ao formulario de criacao de vaga
          GestureDetector(
            onTap: _handleAddPosition,
            child: Container(
              width: 36,
              height: 36,
              decoration:
                  const BoxDecoration(color: _purple, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // Exibe a imagem de capa do projeto ou um placeholder cinza
  Widget _buildCoverImage() {
    if (widget.project.imagem != null && widget.project.imagem!.isNotEmpty) {
      return SizedBox(
        height: 160,
        width: double.infinity,
        child: Image.network(
          widget.project.imagem!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderCover(),
        ),
      );
    }
    return _placeholderCover();
  }

  // Placeholder exibido quando nao ha imagem ou ocorre erro de carregamento
  Widget _placeholderCover() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey[900],
      child: const Center(
          child: Icon(Icons.image_outlined, color: Colors.white30, size: 48)),
    );
  }

  // Secao com nome, descricao, metadados e toggle de status do projeto
  Widget _buildProjectInfo() {
    final p = widget.project;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  p.nome,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
              const SizedBox(width: 10),
              _buildRascunhoBadge(_isRascunho),
            ],
          ),
          const SizedBox(height: 8),
          Text(p.descricao,
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 14),
          if (p.tipo != null)
            _buildMetaRow(Icons.info_outline, _formatTipo(p.tipo!)),
          if (p.dataInicio != null) ...[
            const SizedBox(height: 6),
            _buildMetaRow(Icons.calendar_today_outlined,
                'Inicio: ${_formatDate(p.dataInicio!)}'),
          ],
          if (p.criadoPorNome != null) ...[
            const SizedBox(height: 6),
            _buildMetaRow(
                Icons.people_outline, 'Criado por ${p.criadoPorNome!}'),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          _buildStatusToggle(),
        ],
      ),
    );
  }

  // Card com switch para publicar ou mover o projeto para rascunho
  Widget _buildStatusToggle() {
    final isPublicado = !_isRascunho;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isPublicado ? const Color(0xFFF3E8FF) : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPublicado
              ? const Color(0xFFD8B4FE)
              : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPublicado ? Icons.public : Icons.public_off_outlined,
            size: 20,
            color: isPublicado ? _purple : Colors.orange.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPublicado ? 'Projeto publicado' : 'Projeto em rascunho',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isPublicado ? _purple : Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPublicado
                      ? 'Visivel para candidatos'
                      : 'Nao visivel para candidatos',
                  style: TextStyle(
                    fontSize: 11,
                    color: isPublicado
                        ? Colors.purple.shade400
                        : Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Mostra loading enquanto a requisicao de toggle esta em andamento
          _isTogglingStatus
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isPublicado ? _purple : Colors.orange.shade700,
                  ),
                )
              : Switch(
                  value: isPublicado,
                  onChanged: (_) => _handleToggleStatus(),
                  activeColor: _purple,
                  activeTrackColor: const Color(0xFFD8B4FE),
                  inactiveThumbColor: Colors.orange.shade400,
                  inactiveTrackColor: Colors.orange.shade100,
                ),
        ],
      ),
    );
  }

  // Badge visual que indica se o projeto esta publicado ou em rascunho
  Widget _buildRascunhoBadge(bool rascunho) {
    return Container(
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
  }

  // Linha de metadado com icone e texto truncado
  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Secao que lista as vagas do projeto com cabecalho e contador
  Widget _buildPositionsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vagas disponiveis',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              // Exibe o total de vagas somente apos o carregamento
              if (!_isLoading && _positions.isNotEmpty)
                Text(
                  '${_positions.length} ${_positions.length == 1 ? 'vaga' : 'vagas'}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPositionsContent(),
        ],
      ),
    );
  }

  // Decide qual widget renderizar com base no estado atual das vagas
  Widget _buildPositionsContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(color: _purple, strokeWidth: 2),
        ),
      );
    }
    if (_errorMessage.isNotEmpty) return _buildErrorState();
    if (_positions.isEmpty) return _buildEmptyState();
    return Column(children: _positions.map(_buildVagaCard).toList());
  }

  // Estado de erro com mensagem e botao para tentar novamente
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 12),
            Text(_errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPositions,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Estado vazio com instrucao e atalho para criar a primeira vaga
  Widget _buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('Nenhuma vaga disponivel',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500])),
            const SizedBox(height: 6),
            Text('Adicione a primeira vaga para este projeto',
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _handleAddPosition,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Criar vaga'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card individual de vaga com acoes de editar, excluir e ver detalhes
  Widget _buildVagaCard(Position position) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        // Toque no card inteiro abre o modal de candidatos
        onTap: () => _handleViewDetails(position),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                position.titulo,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botao de editar vaga
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _handleEditPosition(position),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.edit_outlined,
                          color: _purple, size: 18),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Botao de excluir vaga
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showDeleteDialog(position),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.delete_outline,
                          color: Colors.red, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botao ver detalhes abre o modal de candidatos da vaga
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _handleViewDetails(position),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                          color: _purpleLight,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text(
                        'Ver detalhes',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _purple),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navega para o formulario de criacao de vaga e recarrega a lista ao retornar
  Future<void> _handleAddPosition() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PositionFormPage(
            projetoId: widget.project.id,
            projetoNome: widget.project.nome),
      ),
    );
    if (result == true && mounted) await _loadPositions();
  }

  // Abre o modal de candidatos recomendados para a vaga selecionada
  void _handleViewDetails(Position position) {
    showCandidatosModal(context, position.id);
  }

  // Navega para o formulario de edicao da vaga e recarrega a lista ao retornar
  Future<void> _handleEditPosition(Position position) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PositionFormPage(
            vaga: position,
            projetoId: widget.project.id,
            projetoNome: widget.project.nome),
      ),
    );
    if (result == true && mounted) await _loadPositions();
  }

  // Converte o valor do campo tipo para um label legivel
  String _formatTipo(String tipo) {
    const labels = {
      'produto_digital': 'Produto digital',
      'servico': 'Servico',
      'pesquisa': 'Pesquisa',
      'outro': 'Outro',
    };
    return labels[tipo] ?? tipo;
  }

  // Formata uma data no padrao dd/mm/aaaa
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// Botao circular generico com borda e filho customizavel
class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _CircleButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300)),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}