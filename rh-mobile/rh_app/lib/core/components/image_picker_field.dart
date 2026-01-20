import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerField extends StatefulWidget {
  final String label;
  final ValueChanged<File?> onImageSelected;
  final File? initialImage;
  final String? imageUrl;
  final bool showKeepCurrentOption;
  final bool keepCurrentImage;
  final ValueChanged<bool>? onKeepCurrentChanged;

  const ImagePickerField({
    super.key,
    required this.label,
    required this.onImageSelected,
    this.initialImage,
    this.imageUrl,
    this.showKeepCurrentOption = false,
    this.keepCurrentImage = false,
    this.onKeepCurrentChanged,
  });

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  File? _selectedImage;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  Future<void> _pickImage() async {
    if (_isPicking) return;

    setState(() => _isPicking = true);

    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        final file = File(pickedImage.path);
        setState(() => _selectedImage = file);
        widget.onImageSelected(file);
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      setState(() => _isPicking = false);
    }
  }

  void _removeImage() {
    setState(() => _selectedImage = null);
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(),
        const SizedBox(height: 8),
        _buildKeepCurrentOption(),
        _buildImageContainer(),
        _buildRemoveButton(),
      ],
    );
  }

  // Rótulo do campo
  Widget _buildLabel() {
    return Text(
      widget.label,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  // Opção para manter imagem atual
  Widget _buildKeepCurrentOption() {
    if (!widget.showKeepCurrentOption || widget.imageUrl == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: widget.keepCurrentImage,
              onChanged: (value) {
                widget.onKeepCurrentChanged?.call(value ?? false);
              },
            ),
            const Expanded(
              child: Text('Manter imagem atual'),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // Container da imagem com gesto de toque
  Widget _buildImageContainer() {
    return GestureDetector(
      onTap: _isPicking ? null : _pickImage,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _buildImagePreview(),
      ),
    );
  }

  // Botão para remover imagem
  Widget _buildRemoveButton() {
    if (_selectedImage == null || _isPicking) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        onPressed: _removeImage,
        icon: const Icon(Icons.delete, size: 20),
        label: const Text('Remover imagem selecionada'),
      ),
    );
  }

  // Pré-visualização da imagem
  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return _buildFileImage();
    }

    if (widget.keepCurrentImage && widget.imageUrl != null) {
      return _buildNetworkImage();
    }

    return _buildPlaceholder();
  }

  // Imagem de arquivo local
  Widget _buildFileImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(_selectedImage!, fit: BoxFit.cover),
    );
  }

  // Imagem da URL atual
  Widget _buildNetworkImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        widget.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      ),
    );
  }

  // Placeholder quando não há imagem
  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 40,
            color: _isPicking ? Colors.grey : null,
          ),
          const SizedBox(height: 8),
          Text(
            _isPicking ? 'Aguarde...' : 'Toque para adicionar foto',
            style: TextStyle(color: _isPicking ? Colors.grey : null),
          ),
        ],
      ),
    );
  }

  // Mostra snackbar de erro
  void _showErrorSnackbar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao selecionar imagem: $error')),
    );
  }
}