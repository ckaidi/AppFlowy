import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/image/embed_image_url_widget.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/image/open_ai_image_widget.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/image/stability_ai_image_widget.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/image/unsplash_image_widget.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/image/upload_image_file_widget.dart';
import 'package:appflowy/user/application/user_service.dart';
import 'package:appflowy/util/platform_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flowy_infra_ui/style_widget/hover.dart';
import 'package:flutter/material.dart';

enum UploadImageType {
  local,
  url,
  unsplash,
  stabilityAI,
  openAI;

  String get description {
    switch (this) {
      case UploadImageType.local:
        return LocaleKeys.document_imageBlock_upload_label.tr();
      case UploadImageType.url:
        return LocaleKeys.document_imageBlock_embedLink_label.tr();
      case UploadImageType.unsplash:
        return 'Unsplash';
      case UploadImageType.openAI:
        return LocaleKeys.document_imageBlock_ai_label.tr();
      case UploadImageType.stabilityAI:
        return LocaleKeys.document_imageBlock_stability_ai_label.tr();
    }
  }
}

class UploadImageMenu extends StatefulWidget {
  const UploadImageMenu({
    super.key,
    required this.onSelectedLocalImage,
    required this.onSelectedAIImage,
    required this.onSelectedNetworkImage,
    this.supportTypes = UploadImageType.values,
  });

  final void Function(String? path) onSelectedLocalImage;
  final void Function(String url) onSelectedAIImage;
  final void Function(String url) onSelectedNetworkImage;
  final List<UploadImageType> supportTypes;

  @override
  State<UploadImageMenu> createState() => _UploadImageMenuState();
}

class _UploadImageMenuState extends State<UploadImageMenu> {
  late final List<UploadImageType> values;
  int currentTabIndex = 0;
  bool supportOpenAI = false;
  bool supportStabilityAI = false;

  @override
  void initState() {
    super.initState();

    values = widget.supportTypes;
    UserBackendService.getCurrentUserProfile().then(
      (value) {
        final supportOpenAI = value.fold(
          (l) => false,
          (r) => r.openaiKey.isNotEmpty,
        );
        final supportStabilityAI = value.fold(
          (l) => false,
          (r) => r.stabilityAiKey.isNotEmpty,
        );
        if (supportOpenAI != this.supportOpenAI ||
            supportStabilityAI != this.supportStabilityAI) {
          setState(() {
            this.supportOpenAI = supportOpenAI;
            this.supportStabilityAI = supportStabilityAI;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: values.length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            onTap: (value) => setState(() {
              currentTabIndex = value;
            }),
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
            overlayColor: MaterialStatePropertyAll(
              Theme.of(context).colorScheme.secondary,
            ),
            padding: EdgeInsets.zero,
            tabs: values
                .map(
                  (e) => FlowyHover(
                    style: const HoverStyle(borderRadius: BorderRadius.zero),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 12.0,
                        right: 12.0,
                        bottom: 8.0,
                        top: PlatformExtension.isMobile ? 0 : 8.0,
                      ),
                      child: FlowyText(e.description),
                    ),
                  ),
                )
                .toList(),
          ),
          const Divider(
            height: 2,
          ),
          _buildTab(),
        ],
      ),
    );
  }

  Widget _buildTab() {
    final type = UploadImageType.values[currentTabIndex];
    switch (type) {
      case UploadImageType.local:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: UploadImageFileWidget(
            onPickFile: widget.onSelectedLocalImage,
          ),
        );
      case UploadImageType.url:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: EmbedImageUrlWidget(
            onSubmit: widget.onSelectedNetworkImage,
          ),
        );
      case UploadImageType.unsplash:
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: UnsplashImageWidget(
              onSelectUnsplashImage: widget.onSelectedNetworkImage,
            ),
          ),
        );
      case UploadImageType.openAI:
        return supportOpenAI
            ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OpenAIImageWidget(
                    onSelectNetworkImage: widget.onSelectedAIImage,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlowyText(
                  LocaleKeys.document_imageBlock_pleaseInputYourOpenAIKey.tr(),
                ),
              );
      case UploadImageType.stabilityAI:
        return supportStabilityAI
            ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StabilityAIImageWidget(
                    onSelectImage: widget.onSelectedLocalImage,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlowyText(
                  LocaleKeys.document_imageBlock_pleaseInputYourStabilityAIKey
                      .tr(),
                ),
              );
    }
  }
}