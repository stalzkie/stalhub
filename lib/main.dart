import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Models
import 'package:stalhub/data/models/task_model.dart';
import 'package:stalhub/data/models/invoice_model.dart';

// ViewModels
import 'view_model/auth/login_view_model.dart';
import 'view_model/tasks/task_view_model.dart';
import 'view_model/sales/invoice_view_model.dart';
import 'view_model/tickets/ticket_view_model.dart';
import 'view_model/profile/profile_view_model.dart';

// Views
import 'package:stalhub/view/auth/login_screen.dart';
import 'package:stalhub/view/dashboard/dashboard_screen.dart';
import 'package:stalhub/view/tasks/task_management_screen.dart';
import 'package:stalhub/view/tasks/task_analytics_screen.dart';
import 'package:stalhub/view/tasks/all_tasks_screen.dart';
import 'package:stalhub/view/tasks/add_task_screen.dart';
import 'package:stalhub/view/tasks/edit_task_screen.dart';
import 'package:stalhub/view/sales/sales_screen.dart';
import 'package:stalhub/view/sales/invoices_screen.dart';
import 'package:stalhub/view/sales/all_invoices_screen.dart';
import 'package:stalhub/view/sales/add_invoice_screen.dart';
import 'package:stalhub/view/sales/edit_invoice_screen.dart';
import 'package:stalhub/view/tickets/customer_tickets_screen.dart';
import 'package:stalhub/view/tickets/all_customer_tickets_screen.dart';
import 'package:stalhub/view/tickets/add_ticket_screen.dart';
import 'package:stalhub/view/profile/profile_settings_screen.dart';
import 'package:stalhub/view/profile/export_csv_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const String supabaseUrl = 'https://uolinrriyhezsqzefkpi.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVvbGlucnJpeWhlenNxemVma3BpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA2MTUyNTksImV4cCI6MjA1NjE5MTI1OX0.Wzz2IkcnwsbS9i2_0Ny-l7Y8e0dGWnVVseJSGgI93Kc';
const String oneSignalAppId = '91da2ac0-2551-491f-98ca-5d43667edf9e';
const String oneSignalApiKey = 'os_v2_app_shncvqbfkfer7ggklvbwm7w7ty2y2r3idg5un4fppemo3vkim64qflaqyqvtauentpikmokpup7s4sf7b5dw7fqfuo4sqglqh4b3tky';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    final client = Supabase.instance.client;
    final now = DateTime.now();

    try {
      final tasks = await client.from('tasks').select();
      for (var task in tasks) {
        final dueDate = DateTime.parse(task['due_date']);
        final status = task['status'];
        final hoursRemaining = dueDate.difference(now).inHours;

        if (status != 'Delivered' && (hoursRemaining == 24 || hoursRemaining == 12)) {
          final playerId = inputData?['playerId'] ?? '';
          if (playerId.isNotEmpty) {
            await http.post(
              Uri.parse('https://onesignal.com/api/v1/notifications'),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Basic $oneSignalApiKey',
              },
              body: jsonEncode({
                'app_id': oneSignalAppId,
                'include_player_ids': [playerId],
                'headings': {'en': '⏰ Task Reminder'},
                'contents': {'en': 'Task "${task['task_name']}" is due in $hoursRemaining hours!'},
              }),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Background error: $e');
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(oneSignalAppId);
  await OneSignal.Notifications.requestPermission(true);
  OneSignal.User.pushSubscription.optIn();

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    event.preventDefault();
    event.notification.display();
  });

  OneSignal.Notifications.addClickListener((event) {
    debugPrint("🔔 Notification clicked: ${event.jsonRepresentation()}");
    final data = event.notification.additionalData;
    if (data != null && data['target_screen'] != null) {
      navigatorKey.currentState?.pushNamed('/${data['target_screen']}');
    }
  });

  final playerId = OneSignal.User.pushSubscription.id ?? '';
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

  if (playerId.isNotEmpty) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask(
      'taskReminder',
      'checkDueTasks',
      frequency: const Duration(hours: 1),
      inputData: {'playerId': playerId},
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  runApp(StalHubApp(userId: userId, playerId: playerId));
}

class StalHubApp extends StatelessWidget {
  final String userId;
  final String playerId;

  const StalHubApp({super.key, required this.userId, required this.playerId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => TaskViewModel(userId: userId, playerId: playerId)),
        ChangeNotifierProvider(create: (_) => InvoiceViewModel(userId: userId, playerId: playerId)),
        ChangeNotifierProvider(create: (_) => TicketViewModel(userId: userId, playerId: playerId)),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'StalHub',
        theme: ThemeData(
          fontFamily: 'Figtree',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: userId.isEmpty ? '/' : '/dashboard',
        routes: {
          '/': (_) => const LoginScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/tasks': (_) => const TaskManagementScreen(),
          '/task-analytics': (_) => const TaskAnalyticsScreen(),
          '/all-tasks': (_) => const AllTasksScreen(),
          '/add-task': (_) => const AddTaskScreen(),
          '/sales': (_) => const SalesScreen(),
          '/add-invoice': (_) => const AddInvoiceScreen(),
          '/invoices': (_) => const InvoiceScreen(),
          '/all-invoices': (_) => const AllInvoicesScreen(),
          '/tickets': (_) => const CustomerTicketsScreen(),
          '/all-tickets': (_) => const AllCustomerTicketsScreen(),
          '/add-ticket': (_) => const AddTicketScreen(),
          '/profile': (_) => const ProfileSettingsScreen(),
          '/export': (_) => const ExportCsvScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/edit-task') {
            final task = settings.arguments as Task;
            return MaterialPageRoute(builder: (_) => EditTaskScreen(task: task));
          }
          if (settings.name == '/edit-invoice') {
            final invoice = settings.arguments as Invoice;
            return MaterialPageRoute(builder: (_) => EditInvoiceScreen(invoice: invoice));
          }
          return null;
        },
      ),
    );
  }
}
