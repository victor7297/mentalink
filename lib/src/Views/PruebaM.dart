import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String icheckappAPI =
      'https://i-checkapp.com.ar/inicio/api-consulta.php';

  List<dynamic> plans = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('i-CheckApp Subscription Plans'),
      ),
      body: Center(
        child: plans.isEmpty
            ? ElevatedButton(
                onPressed: () {
                  _fetchSubscriptionPlans();
                },
                child: Text('Show Subscription Plans'),
              )
            : ListView.builder(
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  return _buildPlanCard(context, plans[index]);
                },
              ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, dynamic plan) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(plan['reason']),
        subtitle: Text('Price: \$${plan['auto_recurring']['transaction_amount']} ARS'),
        trailing: ElevatedButton(
          onPressed: () {
            _launchURL(plan['init_point']);
          },
          child: Text('Pay'),
        ),
      ),
    );
  }

  void _fetchSubscriptionPlans() async {
    try {
      final response = await http.get(Uri.parse(icheckappAPI));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<dynamic> results = jsonData['results'];

        setState(() {
          plans = results;
        });
      } else {
        throw Exception('Failed to load subscription plans');
      }
    } catch (e) {
      debugPrint('Error fetching subscription plans: $e');
      _showErrorDialog();
    }
  }

  void _launchURL(String url) async {
  final theme = Theme.of(context);
  try {
    await launchUrl(
      Uri.parse(url),      
      customTabsOptions: CustomTabsOptions(
        colorSchemes: CustomTabsColorSchemes.defaults(
          toolbarColor: theme.colorScheme.surface,
        ),
        shareState: CustomTabsShareState.on,
        urlBarHidingEnabled: true,
        showTitle: true,
        closeButton: CustomTabsCloseButton(
          icon: CustomTabsCloseButtonIcons.back,
        ),
      ),                    
      safariVCOptions: SafariViewControllerOptions(
        preferredBarTintColor: theme.colorScheme.surface,
        preferredControlTintColor: theme.colorScheme.onSurface,
        barCollapsingEnabled: true,
        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,        
      ),
    );
  } catch (e) {
    // If the URL launch fails, an exception will be thrown. (For example, if no browser app is installed on the Android device.)
    debugPrint(e.toString());
  }
}

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to load subscription plans.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
