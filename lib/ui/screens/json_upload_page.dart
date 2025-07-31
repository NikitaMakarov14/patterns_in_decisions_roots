import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../business_logic/bloc/json_upload_bloc.dart';
import '../../business_logic/bloc/json_upload_event.dart';
import '../../business_logic/bloc/json_upload_state.dart';
import '../../business_logic/provider/locale_provider.dart';
import '../../core/constants/index.dart';
import '../widgets/chat_bubble_widget.dart';
import '../widgets/matrix_display_widget.dart';
import '../widgets/message_input_widget.dart';

class JsonUploadPage extends StatelessWidget {
  const JsonUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JsonUploadBloc(),
      child: const _JsonUploadView(),
    );
  }
}

class _JsonUploadView extends StatefulWidget {
  const _JsonUploadView();

  @override
  State<_JsonUploadView> createState() => _JsonUploadViewState();
}

class _JsonUploadViewState extends State<_JsonUploadView> {
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // Функция по преобразованию ключа ошибки в локализованный текст
  String _getErrorText(String errorKey, AppLocalizations loc) {
    switch (errorKey) {
      case 'jsonError':
        return loc.jsonError;
      case 'serverError':
        return loc.serverError;
      case 'awaitedFormat':
        return loc.awaitedFormat;
      case 'inputHint':
        return loc.inputHint;
      case 'sendError':
        return loc.sendError;
      case 'noPatterns':
        return loc.noPatterns;
      default:
        return errorKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<JsonUploadBloc>();
    final loc = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: true);

    return Scaffold(
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.defaultPadding),
            child: BlocConsumer<JsonUploadBloc, JsonUploadState>(
              listener: (context, state) => _handleStateErrors(state, loc),
              builder: (context, state) {
                _updateDescriptionController(state);
                return Stack(
                  children: [
                    Column(
                      children: [
                        if (state.showInputPanel)
                          _buildLanguageSelector(localeProvider),
                        const SizedBox(height: AppDimensions.smallPadding),
                        _buildMainContent(state, loc, bloc),
                        if (state.showInputPanel) ...[
                          const SizedBox(height: AppDimensions.defaultPadding),
                          _buildMessageInput(state, loc, bloc),
                        ],
                      ],
                    ),
                    if (!state.showInputPanel)
                      _buildResetButton(
                        buttonText: loc.newRequest,
                        onPressed: () => bloc.add(ResetEvent()),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryDark,
            AppColors.secondaryDark,
            AppColors.accentPurple,
            AppColors.lightPurple,
          ],
          stops: const [0.0, 0.4, 0.8, 1.0],
        ),
      );

  // Функция обработки ошибок состояния через SnackBar
  void _handleStateErrors(JsonUploadState state, AppLocalizations loc) {
    if (state.errorKey != null) {
      final errorMessage = _getErrorText(state.errorKey!, loc);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            left: AppDimensions.defaultPadding * 4,
            right: AppDimensions.defaultPadding * 16,
            bottom: 530,
          ),
        ),
      );
    }
  }

  // Синхронизация текстового контроллера с состоянием
  void _updateDescriptionController(JsonUploadState state) {
    if (_descriptionController.text != state.description) {
      _descriptionController.text = state.description;
    }
  }

  // Виджет переключателя языка
  Widget _buildLanguageSelector(LocaleProvider localeProvider) => Align(
        alignment: Alignment.topRight,
        child: PopupMenuButton<Locale>(
          icon: const Icon(Icons.language, color: AppColors.white),
          onSelected: (locale) async {
            await localeProvider.setLocale(locale);
            if (mounted) setState(() {});
          },
          tooltip: '',
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<Locale>(
              value: const Locale('ru'),
              child: Text('RU', style: AppTextStyles.monospace()),
            ),
            PopupMenuItem<Locale>(
              value: const Locale('en'),
              child: Text('EN', style: AppTextStyles.monospace()),
            ),
          ],
        ),
      );

  // Основная контентная область с анимацией переключения состояний
  Widget _buildMainContent(
    JsonUploadState state,
    AppLocalizations loc,
    JsonUploadBloc bloc,
  ) =>
      Expanded(
        flex: 8,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.largePadding,
            horizontal: AppDimensions.mediumPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            border: Border.all(color: AppColors.white24),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            child: state.isLoading
                ? _buildLoadingIndicator()
                : state.interpretation.isEmpty
                    ? _buildEmptyState(loc)
                    : _buildResultsState(state),
          ),
        ),
      );

  // Индикатор загрузки данных
  Widget _buildLoadingIndicator() => const Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildEmptyState(AppLocalizations loc) => Column(
        key: const ValueKey('empty'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload_outlined,
              size: 48, color: AppColors.white54),
          const SizedBox(height: AppDimensions.mediumPadding),
          Text(
            loc.uploadHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.monospace(
              color: AppColors.white54,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppDimensions.defaultPadding),
        ],
      );

  // Виджет для отображения результатов анализа
  Widget _buildResultsState(JsonUploadState state) => Column(
        key: const ValueKey('results'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 8,
            child: ListView(
              children: [
                // Контекст от пользователя
                ChatBubbleWidget(
                  text: state.description,
                  isUser: true,
                ),
                const SizedBox(height: AppDimensions.smallPadding),
                if (state.algorithmResponse != null)
                  Expanded(
                    flex: 3,
                    child: MatrixDisplayWidget(
                      matrices: state.matrices!,
                      algorithmResponse: state.algorithmResponse!,
                    ),
                  ),
                const SizedBox(height: AppDimensions.mediumPadding),
                // Интерпретация языковой моделью
                ChatBubbleWidget(
                  text: state.interpretation,
                  isUser: false,
                  isInterpretation: true,
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildMessageInput(
    JsonUploadState state,
    AppLocalizations loc,
    JsonUploadBloc bloc,
  ) =>
      MessageInputWidget(
        descriptionController: _descriptionController,
        hasFile: state.matrices != null,
        onPickFile: () => bloc.add(PickJsonFileEvent()),
        onSend: () => bloc.add(SendDataEvent()),
        onDescriptionChanged: (value) =>
            bloc.add(UpdateDescriptionEvent(value)),
        hintText: loc.enterDesc,
      );

  Widget _buildResetButton({
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: AppDimensions.smallPadding,
          right: AppDimensions.smallPadding,
        ),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.refresh, color: AppColors.white),
          label: Text(
            buttonText,
            style: AppTextStyles.monospace(fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blueGrey,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.mediumPadding,
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
