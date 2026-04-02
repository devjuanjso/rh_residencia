import 'package:flutter/material.dart';
import 'package:front/features/position/model/recomendacao_model.dart';
import 'package:front/features/projects/viewmodel/recomendacao_view_model.dart';
import 'package:provider/provider.dart';

// Abre o modal de candidatos para a vaga informada
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

class _CandidatosSheet extends StatelessWidget {
  const _CandidatosSheet();

  static const Color _purple = Color(0xFF6B21A8);
  static const Color _purpleLight = Color(0xFFF3E8FF);

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
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            const Divider(height: 1),
            Expanded(child: _buildBody(controller)),
          ],
        ),
      ),
    );
  }

  // Indicador visual de arraste no topo do modal
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
          // Exibe o total apos o carregamento
          Consumer<RecomendacaoViewModel>(
            builder: (_, vm, __) {
              if (vm.isLoading || vm.recomendacoes.isEmpty) {
                return const SizedBox.shrink();
              }
              return Text(
                '${vm.recomendacoes.length} ${vm.recomendacoes.length == 1 ? 'candidato' : 'candidatos'}',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ScrollController controller) {
    return Consumer<RecomendacaoViewModel>(
      builder: (_, vm, __) {
        if (vm.isLoading) return _buildLoading();
        if (vm.errorMessage.isNotEmpty) return _buildError(vm);
        if (vm.recomendacoes.isEmpty) return _buildEmpty();
        return _buildList(vm.recomendacoes, controller);
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: _purple,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildError(RecomendacaoViewModel vm) {
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
              onPressed: () => vm.carregar,
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

  Widget _buildEmpty() {
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
            'Os candidatos aparecerao aqui',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Recomendacao> lista, ScrollController controller) {
    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: lista.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _CandidatoCard(
        recomendacao: lista[i],
        posicao: i + 1,
      ),
    );
  }
}

class _CandidatoCard extends StatelessWidget {
  final Recomendacao recomendacao;
  final int posicao;

  const _CandidatoCard({
    required this.recomendacao,
    required this.posicao,
  });

  static const Color _purple = Color(0xFF6B21A8);
  static const Color _purpleLight = Color(0xFFF3E8FF);

  @override
  Widget build(BuildContext context) {
    final pct = (recomendacao.compatibilidade * 100).toStringAsFixed(1);
    final compatibilidade = recomendacao.compatibilidade;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Avatar com posicao no ranking
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
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
                // ID truncado do usuario
                Text(
                  'Candidato ${recomendacao.usuarioId.substring(0, 8)}...',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                // Barra de progresso de compatibilidade
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: compatibilidade,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_colorForPct(compatibilidade)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Percentual numerico
          Text(
            '$pct%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _colorForPct(compatibilidade),
            ),
          ),
        ],
      ),
    );
  }

  // Cor da barra varia conforme a compatibilidade
  Color _colorForPct(double valor) {
    if (valor >= 0.7) return const Color(0xFF16A34A);
    if (valor >= 0.4) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }
}