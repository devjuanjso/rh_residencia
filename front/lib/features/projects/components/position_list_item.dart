import 'package:flutter/material.dart';
import '../../position/model/position_model.dart';

class PositionListItem extends StatefulWidget {
  final Position position;
  final VoidCallback? onViewDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onApply;
  final bool showActions;
  final bool showEducation;
  final bool showCertifications;
  final bool applied;

  const PositionListItem({
    super.key,
    required this.position,
    this.onViewDetails,
    this.onEdit,
    this.onDelete,
    this.onApply,
    this.showActions = true,
    this.showEducation = false,
    this.showCertifications = false,
    this.applied = false,
  });

  @override
  State<PositionListItem> createState() => _PositionListItemState();
}

class _PositionListItemState extends State<PositionListItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (_expanded) _buildExpandedContent(),
        ],
      ),
    );
  }

  // Linha principal: nome + badge senioridade + chevron
  Widget _buildHeader() {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.position.titulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (widget.position.senioridade != null &&
                widget.position.senioridade!.isNotEmpty)
              _buildSeniorityBadge(widget.position.senioridade!),
            const SizedBox(width: 8),
            Icon(
              _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  // Badge de senioridade estilo da imagem (fundo escuro/cinza)
  Widget _buildSeniorityBadge(String senioridade) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF5B4FCF), // roxo igual ao design
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        senioridade,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Conteúdo expandido com detalhes da vaga
  Widget _buildExpandedContent() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDescription(),
          _buildEducationInfo(),
          _buildRequiredSkills(),
          _buildCertifications(),
          if (widget.showActions) _buildActionsRow(),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    if (widget.position.descricao == null || widget.position.descricao!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        widget.position.descricao!,
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildEducationInfo() {
    if (!widget.showEducation ||
        widget.position.formacaoDesejada == null ||
        widget.position.formacaoDesejada!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.school, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Formação: ${widget.position.formacaoDesejada!}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredSkills() {
    if (widget.position.habilidadesRequeridas.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildChipsSection(
      title: 'Habilidades:',
      items: widget.position.habilidadesRequeridas,
      chipColor: Colors.green[50]!,
    );
  }

  Widget _buildCertifications() {
    if (!widget.showCertifications ||
        widget.position.certificacoesRequeridas.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildChipsSection(
      title: 'Certificações:',
      items: widget.position.certificacoesRequeridas,
      chipColor: Colors.orange[50]!,
    );
  }

  Widget _buildChipsSection({
    required String title,
    required List<String> items,
    required Color chipColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: items
                .map((item) => Chip(
                      label: Text(item,
                          style: const TextStyle(fontSize: 12)),
                      backgroundColor: chipColor,
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildApplyButton(),
        _buildActionIcons(),
      ],
    );
  }

  Widget _buildApplyButton() {
    if (widget.onApply == null && !widget.applied) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton.icon(
        onPressed: widget.applied ? null : widget.onApply,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        icon: Icon(widget.applied ? Icons.description : Icons.send),
        label: Text(widget.applied ? 'Enviado' : 'Candidatar-se'),
      ),
    );
  }

  Widget _buildActionIcons() {
    final actions = <Widget>[];

    if (widget.onViewDetails != null) {
      actions.add(_buildIconBtn(
        icon: Icons.visibility,
        onPressed: widget.onViewDetails!,
        tooltip: 'Ver detalhes',
      ));
    }
    if (widget.onEdit != null) {
      actions.add(_buildIconBtn(
        icon: Icons.edit,
        onPressed: widget.onEdit!,
        tooltip: 'Editar',
      ));
    }
    if (widget.onDelete != null) {
      actions.add(_buildIconBtn(
        icon: Icons.delete,
        onPressed: widget.onDelete!,
        tooltip: 'Excluir',
        color: Colors.red,
      ));
    }

    return Row(children: actions);
  }

  Widget _buildIconBtn({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20, color: color),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
    );
  }
}