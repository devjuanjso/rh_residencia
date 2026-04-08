import 'package:flutter/material.dart';
import 'package:front/features/recomendacao/model/recomendacao_model.dart';
import 'package:front/features/recomendacao/viewmodel/recomendacao_view_model.dart';
import 'package:provider/provider.dart';

// abre o bottom sheet de candidatos da vaga
void showCandidatosModal(BuildContext context, String vagaId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => RecomendacaoViewModel()..carregar(vagaId),
      child: const _CandidatosSheet(),
    ),
  );
}

class _CandidatosSheet extends StatefulWidget {
  const _CandidatosSheet();

  @override
  State<_CandidatosSheet> createState() => _CandidatosSheetState();
}

class _CandidatosSheetState extends State<_CandidatosSheet> {
  Recomendacao? _selecionado;

  static const Color _purple = Color(0xFF6B21A8);

  // alterna entre lista e detalhe com slide
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            final isDetalhe = child.key == const ValueKey('detalhe');
            final offset = isDetalhe
                ? const Offset(1, 0)
                : const Offset(-1, 0);
            return SlideTransition(
              position: Tween<Offset>(begin: offset, end: Offset.zero)
                  .animate(animation),
              child: child,
            );
          },
          child: _selecionado == null
              ? _Lista(
                  key: const ValueKey('lista'),
                  controller: controller,
                  onSelect: (r) => setState(() => _selecionado = r),
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

  const _Lista({
    super.key,
    required this.controller,
    required this.onSelect,
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

  // barra de arraste do sheet
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

  // titulo e contagem de candidatos
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Consumer<RecomendacaoViewModel>(
            builder: (_, vm, __) {
              if (vm.isLoading || vm.recomendacoes.isEmpty) {
                return const SizedBox.shrink();
              }
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

  // loading, erro, vazio ou lista de cards
  Widget _buildBody() {
    return Consumer<RecomendacaoViewModel>(
      builder: (_, vm, __) {
        if (vm.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: _purple,
              strokeWidth: 2,
            ),
          );
        }
        if (vm.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
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
                    onPressed: vm.carregar as void Function()?,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Tentar novamente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (vm.recomendacoes.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'Nenhum candidato ainda',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Os candidatos aparecerão aqui',
                  style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                ),
              ],
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

  // card com ranking, nome, cargo, barra de compatibilidade e percentual
  @override
  Widget build(BuildContext context) {
    final pct = (recomendacao.compatibilidade * 100).toStringAsFixed(1);
    final cor = _colorForPct(recomendacao.compatibilidade);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: _purpleLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$posicao',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _purple,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recomendacao.nome,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (recomendacao.cargo != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      recomendacao.cargo!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: recomendacao.compatibilidade,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(cor),
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
                    color: cor,
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

  // verde acima de 70%, amarelo acima de 40%, vermelho abaixo
  Color _colorForPct(double valor) {
    if (valor >= 0.7) return const Color(0xFF16A34A);
    if (valor >= 0.4) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }
}

class _Detalhe extends StatelessWidget {
  final Recomendacao recomendacao;
  final VoidCallback onVoltar;

  const _Detalhe({
    super.key,
    required this.recomendacao,
    required this.onVoltar,
  });

  static const Color _purple = Color(0xFF6B21A8);
  static const Color _purpleLight = Color(0xFFF3E8FF);

  // perfil completo do candidato selecionado
  @override
  Widget build(BuildContext context) {
    final pct = (recomendacao.compatibilidade * 100).toStringAsFixed(1);
    final cor = _colorForPct(recomendacao.compatibilidade);

    return Column(
      children: [
        _buildHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 14),
          child: Row(
            children: [
              IconButton(
                onPressed: onVoltar,
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                color: _purple,
                tooltip: 'Voltar',
              ),
              const Expanded(
                child: Text(
                  'Perfil do Candidato',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: cor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: _purpleLight,
                      backgroundImage: recomendacao.foto != null
                          ? NetworkImage(recomendacao.foto!)
                          : null,
                      child: recomendacao.foto == null
                          ? Text(
                              recomendacao.nome.isNotEmpty
                                  ? recomendacao.nome[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _purple,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recomendacao.nome,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (recomendacao.cargo != null)
                            Text(
                              [
                                recomendacao.senioridade,
                                recomendacao.cargo,
                              ]
                                  .whereType<String>()
                                  .join(' · '),
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600]),
                            ),
                          if (recomendacao.area != null)
                            Text(
                              recomendacao.area!,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildSection('Contato', [
                  _buildInfoRow(Icons.email_outlined, recomendacao.email),
                  if (recomendacao.linkedin != null)
                    _buildInfoRow(Icons.link, recomendacao.linkedin!),
                ]),

                if (recomendacao.bio != null && recomendacao.bio!.isNotEmpty)
                  _buildSection('Sobre', [
                    Text(
                      recomendacao.bio!,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.5),
                    ),
                  ]),

                if (recomendacao.formacao != null)
                  _buildSection('Formação', [
                    _buildInfoRow(
                        Icons.school_outlined, recomendacao.formacao!),
                  ]),

                if (recomendacao.habilidades.isNotEmpty)
                  _buildSection('Habilidades', [
                    _buildChips(recomendacao.habilidades, _purple, _purpleLight),
                  ]),

                if (recomendacao.certificacoes.isNotEmpty)
                  _buildSection('Certificações', [
                    _buildChips(recomendacao.certificacoes,
                        const Color(0xFF0369A1), const Color(0xFFE0F2FE)),
                  ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // barra de arraste do sheet
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

  // secao com titulo e filhos
  Widget _buildSection(String titulo, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  // linha com icone e texto
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  // chips coloridos para listas de texto
  Widget _buildChips(List<String> items, Color cor, Color bg) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items
          .map(
            (item) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: cor,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // verde acima de 70%, amarelo acima de 40%, vermelho abaixo
  Color _colorForPct(double valor) {
    if (valor >= 0.7) return const Color(0xFF16A34A);
    if (valor >= 0.4) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }
}