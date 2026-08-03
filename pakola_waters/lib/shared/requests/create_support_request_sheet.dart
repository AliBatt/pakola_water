import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:uuid/uuid.dart';

import 'request_image_uploader.dart';
import 'support_requests_controller.dart';

Future<void> showCreateSupportRequestSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const CreateSupportRequestSheet(),
  );
}

class CreateSupportRequestSheet extends StatefulWidget {
  const CreateSupportRequestSheet({super.key});

  @override
  State<CreateSupportRequestSheet> createState() =>
      _CreateSupportRequestSheetState();
}

class _CreateSupportRequestSheetState extends State<CreateSupportRequestSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uploader = RequestImageUploader();
  XFile? _picked;
  Uint8List? _previewBytes;
  bool _uploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _uploader.pickImage();
    if (file == null) return;
    final bytes = await _uploader.compress(file);
    if (!mounted) return;
    setState(() {
      _picked = file;
      _previewBytes = bytes;
    });
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty) {
      AppSnackBar.warning(context, l10n.titleRequired);
      return;
    }
    if (description.isEmpty) {
      AppSnackBar.warning(context, l10n.descriptionRequired);
      return;
    }

    setState(() => _uploading = true);
    String? imageUrl;
    try {
      if (_previewBytes != null) {
        imageUrl = await _uploader.upload(
          requestKey: const Uuid().v4(),
          bytes: _previewBytes!,
        );
      }
      if (!mounted) return;
      final controller = context.read<SupportRequestsController>();
      final result = await controller.createRequest(
        title: title,
        description: description,
        imageUrl: imageUrl,
      );
      if (!mounted) return;
      setState(() => _uploading = false);
      switch (result) {
        case Success():
          Navigator.pop(context);
          AppSnackBar.success(context, l10n.requestSentToAdmin);
        case FailureResult(:final failure):
          AppSnackBar.error(context, failure.message);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _uploading = false);
      AppSnackBar.error(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = context.watch<SupportRequestsController>();
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final busy = _uploading || controller.isSubmitting;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg + bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.newRequest,
              style: context.texts.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.newRequestSubtitle,
              style: context.texts.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _titleController,
              labelText: l10n.requestTitle,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _descriptionController,
              labelText: l10n.requestDescription,
              maxLines: 5,
            ),
            const SizedBox(height: AppSpacing.md),
            if (_previewBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Image.memory(
                  _previewBytes!,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: busy ? null : _pickImage,
                icon: const Icon(Icons.image_outlined),
                label: Text(l10n.addImageOptional),
              ),
            if (_picked != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: busy
                    ? null
                    : () => setState(() {
                          _picked = null;
                          _previewBytes = null;
                        }),
                child: Text(l10n.removeImage),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: busy ? null : _submit,
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.sendRequest),
            ),
          ],
        ),
      ),
    );
  }
}
