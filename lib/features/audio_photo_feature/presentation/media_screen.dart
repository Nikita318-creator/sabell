import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'package:flutter_sabel/features/audio_photo_feature/logic/media_bloc.dart';
import 'package:flutter_sabel/features/audio_photo_feature/models/media_item_model.dart';
import 'package:flutter_sabel/features/audio_photo_feature/repositories/media_repository.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  late final ScrollController _scrollController;
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Подписка на событие скролла
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        debugPrint('Доскроллили до самого конца!');
      }
    });
  }

  @override
  void dispose() {
    // Очищаем ScrollController и Recorder для избежания утечек памяти
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null && mounted) {
      context.read<MediaBloc>().add(
        AddMediaEvent(File(pickedFile.path), MediaType.photo),
      );
    }
  }

  Future<void> _toggleAudioRecord() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      if (mounted) setState(() => _isRecording = false);
      if (path != null && mounted) {
        context.read<MediaBloc>().add(
          AddMediaEvent(File(path), MediaType.audio),
        );
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final filePath = p.join(
          tempDir.path,
          'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
        );

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );
        if (mounted) setState(() => _isRecording = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MediaBloc(MediaRepositoryImpl())..add(LoadMediaEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Media Storage')),
        body: BlocBuilder<MediaBloc, MediaState>(
          builder: (context, state) {
            if (state is MediaLoadingState) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (state is MediaLoadedState) {
              if (state.items.isEmpty) {
                return const Center(child: Text('Галерея пуста'));
              }
              return ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return _MediaTile(item: item);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: Builder(
          builder: (innerContext) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_library, size: 32),
                      onPressed: () {
                        final picker = ImagePicker();
                        picker.pickImage(source: ImageSource.gallery).then((
                          pickedFile,
                        ) {
                          if (pickedFile != null && mounted) {
                            innerContext.read<MediaBloc>().add(
                              AddMediaEvent(
                                File(pickedFile.path),
                                MediaType.photo,
                              ),
                            );
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, size: 32),
                      onPressed: () {
                        final picker = ImagePicker();
                        picker.pickImage(source: ImageSource.camera).then((
                          pickedFile,
                        ) {
                          if (pickedFile != null && mounted) {
                            innerContext.read<MediaBloc>().add(
                              AddMediaEvent(
                                File(pickedFile.path),
                                MediaType.photo,
                              ),
                            );
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _isRecording ? Icons.stop_circle : Icons.mic,
                        color: _isRecording ? Colors.red : Colors.black,
                        size: 32,
                      ),
                      onPressed: () async {
                        if (_isRecording) {
                          final path = await _audioRecorder.stop();
                          if (mounted) setState(() => _isRecording = false);
                          if (path != null && mounted) {
                            innerContext.read<MediaBloc>().add(
                              AddMediaEvent(File(path), MediaType.audio),
                            );
                          }
                        } else {
                          if (await _audioRecorder.hasPermission()) {
                            final tempDir = await getTemporaryDirectory();
                            final filePath = p.join(
                              tempDir.path,
                              'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
                            );

                            await _audioRecorder.start(
                              const RecordConfig(encoder: AudioEncoder.aacLc),
                              path: filePath,
                            );
                            if (mounted) setState(() => _isRecording = true);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Отдельный виджет тайла
class _MediaTile extends StatefulWidget {
  final MediaItemModel item;
  const _MediaTile({required this.item});

  @override
  State<_MediaTile> createState() => _MediaTileState();
}

class _MediaTileState extends State<_MediaTile> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.type == MediaType.photo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          widget.item.file,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.audiotrack),
          title: Text(
            'Запись ${widget.item.createdAt.toString().split('.')[0]}',
          ),
          trailing: IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () async {
              if (_isPlaying) {
                await _audioPlayer.pause();
                if (mounted) setState(() => _isPlaying = false);
              } else {
                await _audioPlayer.play(DeviceFileSource(widget.item.filePath));
                if (mounted) setState(() => _isPlaying = true);
              }
            },
          ),
        ),
      );
    }
  }
}
