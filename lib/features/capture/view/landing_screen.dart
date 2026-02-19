import 'package:camera_app/core/services/shared_pref_services.dart';
import 'package:camera_app/features/capture/models/session_model.dart';
import 'package:camera_app/features/capture/view/camera_screen.dart';
import 'package:camera_app/features/capture/view/results_screen.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  SessionModel? session;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSession();
  }

  Future<void> loadSession() async {
    final data = await SharedPrefServices.getLastSession();
    setState(() {
      session = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageCount = session?.images.length ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E0E),
        title: const Text(
          "Scanner",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : session == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 70,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "No Sessions Yet",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 8),
                        const Text(
                          "Your latest scanning session will appear here once you complete a scan.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white38,
                            height: 1.5,
                          ),
                        ),

                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResultsScreen(
                                capturedImages: session!.images,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Last Session",
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "$imageCount Captured Images",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tap to view details",
                                style: const TextStyle(
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00E5CC),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CameraScreen()),
          );

          loadSession(); // refresh after new session
        },
        child: const Icon(Icons.camera_alt, color: Colors.black),
      ),
    );
  }
}
