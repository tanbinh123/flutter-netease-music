import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/media/tracks/track_list.dart';
import 'package:quiet/navigation/common/like_button.dart';
import 'package:quiet/providers/fm_playlist_provider.dart';
import 'package:quiet/providers/player_provider.dart';
import 'package:quiet/repository.dart';

import 'lyric_layout.dart';

class PageFmPlaying extends ConsumerWidget {
  const PageFmPlaying({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmPlaylist = ref.watch(fmPlaylistProvider);
    final playingList = ref.watch(playingListProvider);
    final Track? track;
    if (playingList.isFM) {
      track = ref.watch(playingTrackProvider);
    } else {
      track = fmPlaylist.firstOrNull;
    }

    if (track == null) {
      return Material(
        color: context.colorScheme.background,
        child: const Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Material(
      color: context.colorScheme.background,
      child: Row(
        children: [
          Flexible(flex: 5, child: _CoverLayout(track: track)),
          Flexible(flex: 5, child: LyricLayout(track: track)),
        ],
      ),
    );
  }
}

class _CoverLayout extends StatelessWidget {
  const _CoverLayout({
    Key? key,
    required this.track,
  }) : super(key: key);

  final Track track;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 80),
        SizedBox.square(
          dimension: 300,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(image: CachedImage(track.imageUrl!)),
              ),
              _CoverPlayPauseButton(track: track)
            ],
          ),
        ),
        const Spacer(),
        _FmButtonBars(track: track),
        const Spacer(),
      ],
    );
  }
}

class _CoverPlayPauseButton extends ConsumerWidget {
  const _CoverPlayPauseButton({
    Key? key,
    required this.track,
  }) : super(key: key);

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFmPlaying = ref
        .watch(playerStateProvider.select((value) => value.playingList.isFM));
    final isPlaying = ref.watch(isPlayingProvider);

    final playing = isFmPlaying && isPlaying;

    return AnimatedAlign(
      alignment: playing ? Alignment.bottomRight : Alignment.center,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: SizedBox.square(
              dimension: 56,
              child: Material(
                color: Colors.white24,
                child: IconButton(
                  tooltip:
                      playing ? context.strings.pause : context.strings.play,
                  icon: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: context.colorScheme.primary,
                    size: 40,
                  ),
                  onPressed: () {
                    final player = ref.read(playerProvider);
                    if (playing) {
                      player.pause();
                    } else if (isFmPlaying) {
                      player.play();
                    } else {
                      final fmPlaylist = ref.read(fmPlaylistProvider);
                      player
                        ..setTrackList(TrackList.fm(tracks: fmPlaylist))
                        ..playFromMediaId(track.id);
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FmButtonBars extends ConsumerWidget {
  const _FmButtonBars({
    Key? key,
    required this.track,
  }) : super(key: key);

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        LikeButton(music: track, iconSize: 24),
        IconButton(
          splashRadius: 24,
          iconSize: 24,
          onPressed: () {},
          icon: const Icon(Icons.delete_rounded),
        ),
        IconButton(
          splashRadius: 24,
          iconSize: 24,
          onPressed: () {},
          icon: const Icon(Icons.skip_next_rounded),
        ),
        IconButton(
          splashRadius: 24,
          iconSize: 24,
          onPressed: () {},
          icon: const Icon(Icons.more_horiz),
        ),
      ],
    );
  }
}
