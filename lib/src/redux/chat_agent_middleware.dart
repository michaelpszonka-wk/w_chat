import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:w_chat/src/module/chat_agent_events.dart';
import 'package:w_module/w_module.dart';

import '../clients/ai_service_client/chat_ai_service_client.dart';
import '../models/chat_model_utils.dart';
import 'chat_agent_actions.dart';
import 'chat_agent_view_state.sg.dart';

Iterable<Middleware<ChatAgentViewState>> chatAgentMiddlewares({
  @required DispatchKey dispatchKey,
  @required ChatAgentEvents events,
  @required ChatAiServiceClient chatClient,
}) =>
    [
      onTrainAgent(dispatchKey, events, chatClient),
      onUserPromptSubmission(dispatchKey, events, chatClient),
      onUserPromptSubmissionSuccess(dispatchKey, events),
    ];

TypedMiddleware<ChatAgentViewState, UserPromptSubmission>
    onUserPromptSubmission(DispatchKey key, ChatAgentEvents events,
            ChatAiServiceClient chatClient) =>
        TypedMiddleware((Store<ChatAgentViewState> store,
            UserPromptSubmission action, NextDispatcher next) {
          events.onUserSubmission(action.message, key);

          // the real thing
          chatClient.converse(action.message.text).then((res) {
            store.dispatch(UserPromptSubmissionSuccess(store.state.currentAgent.buildChatMessage(res.aiResponse)));
          }).catchError((e, st) {
            store.dispatch(UserPromptSubmissionFailed(action.message, 'Error conversing with ai agent'));
          });

          next(action);
        });

TypedMiddleware<ChatAgentViewState, UserPromptSubmissionSuccess>
    onUserPromptSubmissionSuccess(DispatchKey key, ChatAgentEvents events) =>
        TypedMiddleware((Store<ChatAgentViewState> store,
            UserPromptSubmissionSuccess action, NextDispatcher next) {
          events.onAgentResponse(action.agentResponse, key);
          next(action);
        });

TypedMiddleware<ChatAgentViewState, TrainAgent> onTrainAgent(DispatchKey key,
        ChatAgentEvents events, ChatAiServiceClient chatAiServiceClient) =>
    TypedMiddleware((Store<ChatAgentViewState> store, TrainAgent action,
        NextDispatcher next) {
      // Real service call
      chatAiServiceClient.trainModel(action.trainingData).then((_) {
      store.dispatch(TrainAgentSuccess());
      }).catchError((e, stackTrace) {
        // TODO model training failed
      });

      next(action);
    });

TypedMiddleware<ChatAgentViewState, TrainAgentSuccess> onTrainAgentSuccess(
        DispatchKey key, ChatAgentEvents events) =>
    TypedMiddleware((Store<ChatAgentViewState> store, TrainAgentSuccess action,
        NextDispatcher next) {
      events.onAgentTrained(null, key);

      next(action);
    });
