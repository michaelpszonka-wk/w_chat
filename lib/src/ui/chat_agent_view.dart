import 'package:over_react/over_react.dart';
import 'package:react_material_ui/react_material_ui.dart' as mui;
import 'package:react_material_ui/styles/theme_provider.dart' as mui_theme;
import 'package:w_chat/src/models/chat_models.sg.dart';

import '../redux/chat_agent_actions.dart';
import '../redux/chat_agent_view_context.dart';
import 'chat_agent_dialog.dart';

part 'chat_agent_view.over_react.g.dart';

typedef OnUserSubmission = void Function(String userMessage);

mixin ChatAgentViewProps on UiProps {}

// ignore: non_constant_identifier_names
UiFactory<ChatAgentViewProps> ChatAgentView = uiFunction((props) {
  final messages = useChatAgentSelector((s) => s.messages);
  final isLoading = useChatAgentSelector((s) => s.isLoading);
  final dispatch = useChatAgentDispatch();

  final StateHook<String> userInput = useState('');

  void _handleInput(SyntheticFormEvent event) {
    userInput.set(event.target.value as String);
  }

  ChatMessage _buildMessage() => ChatMessage((b) => b
    ..text = userInput?.value?.trim() ?? ''
    ..author = User((b) => b
      ..fullName = 'Michael Pszonka'
      ..resourceId = 'V0ZVc2VyHzUwNTUyMzY4MDMzOTU1ODQ'));

  void _onSubmit() {
    final currentMsg = _buildMessage();

    if (currentMsg.text.isEmpty) return;

    userInput.set('');

    dispatch(UserPromptSubmission(currentMsg));
  }

  return (mui_theme.UnifyThemeProvider()
    ..key = 'chat-gpt-section'
    ..style = {'width': '100%'})(
    (mui.Box())(
      (ChatAgentDialog()
        ..isLoading = isLoading
        ..messages = messages.toSet())(),
      (mui.Stack())(
        (mui.TextField()
          ..sx = {'marginBottom': '10px'}
          ..name = 'title'
          ..value = userInput.value
          ..onChange = _handleInput
          ..size = mui.TextFieldSize.small
          ..fullWidth = true
          ..multiline = true
          ..rows = 5)(),
        (mui.Button()
          ..sx = {'float': 'right'}
          ..onClick = ((_) => _onSubmit)
          ..color = mui.ButtonColor.primary
          ..size = mui.ButtonSize.large)('Submit'),
      ),
    ),
  );
}, _$ChatAgentViewConfig);
