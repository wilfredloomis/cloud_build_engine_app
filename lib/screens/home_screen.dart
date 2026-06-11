import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../app/routes.dart';
import '../controllers/home_controller.dart';
import '../widgets/build_card.dart';
import '../widgets/build_counter_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final controller = context.read<HomeController>();
    controller.loadJobs();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => controller.refreshRunningJobs(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final controller = context.read<HomeController>();
      controller.checkAndDownloadCompleted().then((_) {
        if (!mounted) return;
        final downloaded = controller.downloadedOnResume;
        if (downloaded.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                downloaded.length == 1
                    ? '${downloaded.first} APK downloaded'
                    : '${downloaded.length} APKs downloaded while away',
              ),
              duration: const Duration(seconds: 4),
            ),
          );
          controller.clearDownloadedOnResume();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<HomeController>(
          builder: (context, controller, _) {
            return RefreshIndicator(
              onRefresh: () async {
                await controller.loadJobs();
                await controller.refreshRunningJobs();
              },
              child: CustomScrollView(
                slivers: [
                  _buildHeader(),
                  _buildCounters(controller),
                  if (controller.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (controller.jobs.isEmpty)
                    _buildEmptyState()
                  else
                    _buildJobList(controller),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.newBuild);
          if (mounted) {
            context.read<HomeController>().loadJobs();
          }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Build',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
              ),
              child: const Icon(Icons.cloud_circle, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              'Cloud Build Engine',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.settings);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounters(HomeController controller) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            BuildCounterCard(
              label: 'Total',
              count: controller.totalBuilds,
              icon: Icons.layers_outlined,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            BuildCounterCard(
              label: 'Running',
              count: controller.runningBuilds,
              icon: Icons.play_circle_outline,
              color: AppTheme.secondaryColor,
            ),
            const SizedBox(width: 8),
            BuildCounterCard(
              label: 'Success',
              count: controller.successBuilds,
              icon: Icons.check_circle_outline,
              color: AppTheme.successColor,
            ),
            const SizedBox(width: 8),
            BuildCounterCard(
              label: 'Failed',
              count: controller.failedBuilds,
              icon: Icons.error_outline,
              color: AppTheme.errorColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No builds yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "New Build" to get started',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList(HomeController controller) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 16, 4),
              child: Text(
                'Build History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            );
          }

          final job = controller.jobs[index - 1];
          return BuildCard(
            job: job,
            onTap: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.buildDetails,
                arguments: {'jobId': job.jobId},
              );
              if (mounted) {
                controller.loadJobs();
              }
            },
          );
        },
        childCount: controller.jobs.length + 1,
      ),
    );
  }
}
