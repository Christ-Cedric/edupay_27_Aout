// =============================================================================
// FEATURES/AGENT/SCREENS/AG_NOTIFICATIONS_SCREEN.DART — Inbox de l'agent
// =============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/notification_model.dart';
import '../../../core/providers/agent_provider.dart';
import '../../../core/theme/app_theme.dart';

class AgNotificationsScreen extends StatefulWidget {
  const AgNotificationsScreen({super.key});

  @override
  State<AgNotificationsScreen> createState() => _AgNotificationsScreenState();
}

class _AgNotificationsScreenState extends State<AgNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgentProvider>().loadMyNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final agentState = context.watch<AgentProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back,
                      color: AppColors.white70, size: 22),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 22),
              ],
            ),
          ),
          Expanded(
            child: agentState.isLoadingMyNotifications && agentState.myNotifications.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.green))
                : RefreshIndicator(
                    onRefresh: () => context.read<AgentProvider>().loadMyNotifications(),
                    color: AppColors.green,
                    backgroundColor: AppColors.cardBg,
                    child: agentState.myNotifications.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 80),
                              Icon(Icons.notifications_off_outlined,
                                  size: 56, color: AppColors.white50),
                              const SizedBox(height: 12),
                              Center(
                                child: Text(
                                  'Aucune notification',
                                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                                      color: AppColors.white50, fontSize: 13),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(14),
                            itemCount: agentState.myNotifications.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, i) => _NotificationTile(
                              notif: agentState.myNotifications[i],
                              onTap: () => context
                                  .read<AgentProvider>()
                                  .markMyNotificationRead(agentState.myNotifications[i].id),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notif, required this.onTap});

  final NotificationModel notif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notif.isRead ? AppColors.cardBg : AppColors.green.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white05,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(notif.icon, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.shortLabel,
                            style: GoogleFonts.montserrat(
                                fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.body,
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(notif.createdAt),
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 9, color: AppColors.white50),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
