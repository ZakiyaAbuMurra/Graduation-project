import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recyclear/cubits/auth_cubit/auth_cubit.dart';
import 'package:recyclear/cubits/chat_cubit/chat_cubit.dart';
import 'package:recyclear/utils/route/app_routes.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = BlocProvider.of<ChatCubit>(context, listen: false);
    cubit.getMessages(); // Fetch messages when the ChatPage is initialized
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<ChatCubit>(context);
    final authCubit = BlocProvider.of<AuthCubit>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        bloc: authCubit,
        listenWhen: (previous, current) => current is AuthSuccess,
        listener: (context, state) {
          if (state is AuthLoggedOut) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.homeLogin);
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  bloc: cubit,
                  buildWhen: (previous, current) =>
                      current is ChatSuccess || current is ChatFailure,
                  builder: (context, state) {
                    print('The state of chat is $state ...... ');
                    if (state is ChatSuccess) {
                      if (state.messages.isEmpty) {
                        return const Center(
                          child: Text('No messages'),
                        );
                      }
                      return ListView.builder(
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                message.senderPhotoUrl ?? '',
                              ),
                              radius: 40,
                            ),
                            title: Text(message.message ?? ''),
                            subtitle: Text(message.senderName ?? ''),
                          );
                        },
                      );
                    } else if (state is ChatFailure) {
                      return Center(
                        child: Text(state.message),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: const OutlineInputBorder(),
                  suffixIcon: BlocConsumer<ChatCubit, ChatState>(
                    bloc: cubit,
                    listenWhen: (previous, current) =>
                        current is ChatMessageSent,
                    listener: (context, state) {
                      if (state is ChatMessageSent) {
                        _messageController.clear();
                      }
                    },
                    buildWhen: (previous, current) =>
                        current is ChatMessageSending ||
                        current is ChatMessageSent,
                    builder: (context, state) {
                      if (state is ChatMessageSending) {
                        return const CircularProgressIndicator.adaptive();
                      }
                      return IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          await cubit.sendMessage(_messageController.text);
                          print('The message send --------- state $state');
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
