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
          "Camera Sessions",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : session == null
              ? const Center(
                  child: Text(
                    "No previous session found",
                    style: TextStyle(color: Colors.white38),
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
