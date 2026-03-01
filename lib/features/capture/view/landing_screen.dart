import 'package:camera_app/core/utils/app_colors.dart';
import 'package:camera_app/features/capture/provider/last_seesion_provider.dart';
import 'package:camera_app/features/capture/view/camera_screen.dart';
import 'package:camera_app/features/capture/view/results_screen.dart';
import 'package:camera_app/features/capture/widgets/circular_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(lastSessionProvider);

    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: darkBackgroundColor,
        title: const Text("Scanner", style: TextStyle(color: whiteColor)),
      ),
      body: sessionAsync.when(
        loading: () => Center(
            child: LoaderWidget(
          color: primaryColor,
        )),
        error: (e, _) => const Center(
            child: Text("Something went wrong",
                style: TextStyle(color: whiteColor))),
        data: (session) {
          if (session == null) {
            return Center(
              child: Text("No Sessions Yet",
                  style: TextStyle(color: whiteColor70)),
            );
          }

          final imageCount = session.images.length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultsScreen(
                          capturedImages: session.images,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: darkGreyColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: whiteColor12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Last Session",
                            style:
                                TextStyle(color: whiteColor38, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text("$imageCount Captured Images",
                            style: const TextStyle(
                                color: whiteColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text("Tap to view details",
                            style: TextStyle(color: whiteColor54)),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () async {
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CameraScreen()),
          );

          if (updated == true) {
            ref.invalidate(lastSessionProvider);
          }
        },
        child: const Icon(Icons.camera_alt, color: blackColor),
      ),
    );
  }
}
