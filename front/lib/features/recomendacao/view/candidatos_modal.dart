import 'package:flutter/material.dart';
import 'package:front/features/recomendacao/model/recomendacao_model.dart';
import 'package:front/features/recomendacao/viewmodel/recomendacao_view_model.dart';
import 'package:provider/provider.dart';

// abre o bottom sheet de candidatos vinculado ao viewmodel da vaga
void showCandidatosModal(BuildContext context, String vagaId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => RecomendacaoViewModel()..carregar(vagaId),
      child: _CandidatosSheet(vagaId: vagaId),
    ),
  );
}

class _CandidatosSheet extends StatefulWidget {
  final String vagaId;
  const _CandidatosSheet({required this.vagaId});

  @override
  State<_CandidatosSheet> createState() => _CandidatosSheetState();
}

class _CandidatosSheetState extends State<_CandidatosSheet> {
  Recomendacao? _selecionado;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        // alterna entre lista e detalhe com slide horizontal
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            final isDetalhe = child.key == const ValueKey('detalhe');
            final offset = isDetalhe ? const Offset(1, 0) : const Offset(-1, 0);
            return SlideTransition(
              position: Tween<Offset>(begin: offset, end: Offset.zero).animate(animation),
              child: child,
            );
          },
          child: _selecionado == null
              ? _Lista(
                  key: const ValueKey('lista'),
                  controller: controller,
                  onSelect: (r) => setState(() => _selecionado = r),
                  vagaId: widget.vagaId,
                )
              : _Detalhe(
                  key: const ValueKey('detalhe'),
                  recomendacao: _selecionado!,
                  onVoltar: () => setState(() => _selecionado = null),
                ),
        ),
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  final ScrollController controller;
  final ValueChanged<Recomendacao> onSelect;
  final String vagaId;

  const _Lista({
    super.key,
    required this.controller,
    required this.onSelect,
    required this.vagaId,
  });

  static const Color _purple = Color(0xFF6B21A8);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHandle(),
        _buildHeader(),
        const Divider(height: 1),
        Expanded(child: _buildBody()),
      ],
    );
  }

  // barra de arraste no topo do sheet
  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // titulo e contador de candidatos
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Row(
        children: [
          const Icon(Icons.people_outline, size: 20, color: _purple),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Candidatos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Consumer<RecomendacaoViewModel>(
            builder: (_, vm, __) {
              if (vm.isLoading || vm.recomendacoes.isEmpty) return const SizedBox.shrink();
              final n = vm.recomendacoes.length;
              return Text(
                '$n ${n == 1 ? 'candidato' : 'candidatos'}',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              );
            },
          ),
        ],
      ),
    );
  }

  // exibe loading, erro com retry, vazio ou lista de cards
  Widget _buildBody() {
    return Consumer<RecomendacaoViewModel>(
      builder: (_, vm, __) {
        if (vm.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: _purple, strokeWidth: 2),
          );
        }

        if (vm.errorMessage.isNotEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 12),
                  Text(
                    vm.errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => vm.carregar(vagaId),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Tentar novamente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (vm.recomendacoes.isEmpty) {
          return const Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 56, color: Color(0xFFBDBDBD)),
                  SizedBox(height: 12),
                  Text(
                    'Nenhum candidato ainda',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF9E9E9E)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Os candidatos aparecerão aqui',
                    style: TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: vm.recomendacoes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _CandidatoCard(
            recomendacao: vm.recomendacoes[i],
            posicao: i + 1,
            onTap: () => onSelect(vm.recomendacoes[i]),
          ),
        );
      },
    );
  }
}

class _CandidatoCard extends StatelessWidget {
  final Recomendacao recomendacao;
  final int posicao;
  final VoidCallback onTap;

  const _CandidatoCard({
    required this.recomendacao,
    required this.posicao,
    required this.onTap,
  });

  static const Color _purple = Color(0xFF6B21A8);
  static const Color _purpleLight = Color(0xFFF3E8FF);

  @override
  Widget build(BuildContext context) {
    final vm = context.read<RecomendacaoViewModel>();
    final pct = (recomendacao.compatibilidade * 100).toStringAsFixed(1);
    final cor = vm.corCompatibilidade(recomendacao.compatibilidade);
    final decidido = vm.jaDecidido(recomendacao.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          // opacidade reduzida para candidatos ja decididos
          color: decidido ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // circulo com posicao no ranking
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: decidido ? Colors.grey.shade200 : _purpleLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$posicao',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: decidido ? Colors.grey : _purple,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recomendacao.nome,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: decidido ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ),
                      // badge de status inline se ja decidido
                      if (decidido) _BadgeStatus(status: recomendacao.status, compacto: true),
                    ],
                  ),
                  if (recomendacao.cargo != null) ...[
                    const SizedBox(height: 2),
                    Text(recomendacao.cargo!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                  const SizedBox(height: 6),
                  // barra de compatibilidade acinzentada se ja decidido
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: recomendacao.compatibilidade,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        decidido ? Colors.grey.shade400 : cor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: decidido ? Colors.grey : cor,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Detalhe extends StatefulWidget {
  final Recomendacao recomendacao;
  final VoidCallback onVoltar;

  const _Detalhe({super.key, required this.recomendacao, required this.onVoltar});

  @override
  State<_Detalhe> createState() => _DetalheState();
}

class _DetalheState extends State<_Detalhe> with SingleTickerProviderStateMixin {
  static const Color _purple = Color(0xFF6B21A8);
  static const Color _purpleLight = Color(0xFFF3E8FF);

  late AnimationController _resultController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  // snapshot local do status para nao depender de rebuild externo
  late String _statusAtual;

  @override
  void initState() {
    super.initState();
    _statusAtual = widget.recomendacao.status;
    // animacao de entrada do overlay: escala elastica + fade
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(parent: _resultController, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.4, end: 1.0));
    _fadeAnim = CurvedAnimation(parent: _resultController, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
  }

  @override
  void dispose() {
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecomendacaoViewModel>();
    final pct = (widget.recomendacao.compatibilidade * 100).toStringAsFixed(1);
    final cor = vm.corCompatibilidade(widget.recomendacao.compatibilidade);
    final pendente = _statusAtual == 'pendente';
    final overlay = vm.dadosOverlay(vm.decisaoFeita ?? '');

    return Column(
      children: [
        _buildHandle(),
        _buildCabecalho(context, vm, pct, cor, pendente),
        const Divider(height: 1),
        Expanded(
          child: Stack(
            children: [
              // conteudo scrollavel do perfil
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIdentidade(),
                    const SizedBox(height: 20),
                    _buildSection('Contato', [
                      _buildInfoRow(Icons.email_outlined, widget.recomendacao.email),
                      if (widget.recomendacao.linkedin != null)
                        _buildInfoRow(Icons.link, widget.recomendacao.linkedin!),
                    ]),
                    if (widget.recomendacao.bio != null && widget.recomendacao.bio!.isNotEmpty)
                      _buildSection('Sobre', [
                        Text(
                          widget.recomendacao.bio!,
                          style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5),
                        ),
                      ]),
                    if (widget.recomendacao.formacao != null)
                      _buildSection('Formacao', [
                        _buildInfoRow(Icons.school_outlined, widget.recomendacao.formacao!),
                      ]),
                    if (widget.recomendacao.habilidades.isNotEmpty)
                      _buildSection('Habilidades', [
                        _buildChips(widget.recomendacao.habilidades, _purple, _purpleLight),
                      ]),
                    if (widget.recomendacao.certificacoes.isNotEmpty)
                      _buildSection('Certificacoes', [
                        _buildChips(widget.recomendacao.certificacoes,
                            const Color(0xFF0369A1), const Color(0xFFE0F2FE)),
                      ]),
                    // badge de status quando ja decidido, nada quando pendente
                    if (!pendente) _BadgeStatus(status: _statusAtual),
                  ],
                ),
              ),

              // overlay animado de resultado exibido logo apos a decisao
              if (vm.decisaoFeita != null)
                AnimatedBuilder(
                  animation: _resultController,
                  builder: (_, __) => Opacity(
                    opacity: _fadeAnim.value,
                    child: Container(
                      color: Colors.white.withOpacity(0.92),
                      child: Center(
                        child: Transform.scale(
                          scale: _scaleAnim.value,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: overlay.bg),
                                child: Icon(overlay.icon, size: 48, color: overlay.cor),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                overlay.titulo,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: overlay.cor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                vm.candidatoDecidido ?? '',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // cabecalho com voltar, nome/cargo e icones de acao ou badge de compatibilidade
  Widget _buildCabecalho(
    BuildContext context,
    RecomendacaoViewModel vm,
    String pct,
    Color cor,
    bool pendente,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 14),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onVoltar,
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: _purple,
            tooltip: 'Voltar',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recomendacao.nome,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                if (widget.recomendacao.cargo != null)
                  Text(
                    widget.recomendacao.cargo!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          // icones de acao ao lado do nome apenas quando pendente
          if (pendente)
            Selector<RecomendacaoViewModel, bool>(
              selector: (_, vm) => vm.isProcessando,
              builder: (_, processando, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AcaoIconButton(
                    onPressed: processando ? null : () => _decidir(context, 'rejeitado'),
                    icon: Icons.close_rounded,
                    cor: Colors.red,
                    bg: Colors.red.withOpacity(0.08),
                    loading: processando,
                    loadingColor: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  _AcaoIconButton(
                    onPressed: processando ? null : () => _decidir(context, 'aceito'),
                    icon: Icons.check_rounded,
                    cor: const Color(0xFF16A34A),
                    bg: const Color(0xFF16A34A).withOpacity(0.08),
                    loading: processando,
                    loadingColor: const Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          // badge de percentual de compatibilidade
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$pct%',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cor),
            ),
          ),
        ],
      ),
    );
  }

  // avatar, nome completo, cargo, senioridade e area
  Widget _buildIdentidade() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: _purpleLight,
          backgroundImage:
              widget.recomendacao.foto != null ? NetworkImage(widget.recomendacao.foto!) : null,
          child: widget.recomendacao.foto == null
              ? Text(
                  widget.recomendacao.nome.isNotEmpty
                      ? widget.recomendacao.nome[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _purple),
                )
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.recomendacao.nome,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              if (widget.recomendacao.cargo != null)
                Text(
                  [widget.recomendacao.senioridade, widget.recomendacao.cargo]
                      .whereType<String>()
                      .join(' · '),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              if (widget.recomendacao.area != null)
                Text(widget.recomendacao.area!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ),
      ],
    );
  }

  // secao com titulo e lista de widgets filhos
  Widget _buildSection(String titulo, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  // linha com icone a esquerda e texto expandido
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
        ],
      ),
    );
  }

  // chips coloridos para habilidades e certificacoes
  Widget _buildChips(List<String> items, Color cor, Color bg) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items
          .map((item) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                child: Text(item,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cor)),
              ))
          .toList(),
    );
  }

  // barra de arraste no topo do sheet
  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration:
            BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }

  // chama viewmodel, atualiza status local, dispara overlay e fecha apos 1.4s
  Future<void> _decidir(BuildContext context, String decisao) async {
    final vm = context.read<RecomendacaoViewModel>();

    final sucesso = await vm.decidir(
      widget.recomendacao.candidaturaId,
      decisao,
      widget.recomendacao.nome,
    );

    if (sucesso && mounted) {
      setState(() => _statusAtual = decisao);
      _resultController.forward();
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) {
        vm.limparDecisao();
        Navigator.pop(context);
      }
    }
  }
}

// badge de status reutilizavel — compacto para lista, completo para detalhe
class _BadgeStatus extends StatelessWidget {
  final String status;
  final bool compacto;

  const _BadgeStatus({required this.status, this.compacto = false});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<RecomendacaoViewModel>();
    final dados = vm.dadosBadgeStatus(status);

    if (compacto) {
      // versao pill pequena usada no card da lista
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: dados.bg, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(dados.icon, size: 12, color: dados.cor),
            const SizedBox(width: 4),
            Text(dados.label,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: dados.cor)),
          ],
        ),
      );
    }

    // versao centralizada usada no rodape do detalhe
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: dados.bg, borderRadius: BorderRadius.circular(24)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(dados.icon, size: 18, color: dados.cor),
                const SizedBox(width: 8),
                Text(dados.label,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: dados.cor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// botao de icone circular compacto com suporte a loading
class _AcaoIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color cor;
  final Color bg;
  final bool loading;
  final Color loadingColor;

  const _AcaoIconButton({
    required this.onPressed,
    required this.icon,
    required this.cor,
    required this.bg,
    required this.loading,
    required this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: loading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: loadingColor),
              )
            : Icon(icon, size: 18, color: onPressed == null ? Colors.grey : cor),
      ),
    );
  }
}