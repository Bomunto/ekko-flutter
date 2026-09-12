import 'dart:io' show Platform;

import 'package:ekko_flutter/ekko_flutter.dart';
import 'package:flutter/material.dart';

const _ekkoPurple = Color(0xFF7C5CFF);

/// Set on the simulator (`--dart-define=EKKO_OPEN_SHEET=true`) to capture the
/// report sheet: `simctl` cannot tap, so the app opens it after the first frame.
const _openSheetAtLaunch = bool.fromEnvironment('EKKO_OPEN_SHEET');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Ekko.configure(
    publicKey: 'pk_live_23c7a3df52fa85c444a2790b9a896802',
    teamId: '3TX26K8VZ8',
    baseUrl: Platform.isAndroid ? 'http://10.0.2.2:3035' : 'http://192.168.1.55:3035',
  );
  if (_openSheetAtLaunch) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The scene has to be foreground-active before the sheet can be presented.
      Future<void>.delayed(const Duration(seconds: 2), Ekko.present);
    });
  }
  runApp(const ImaraApp());
}

class ImaraApp extends StatelessWidget {
  const ImaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Imara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _ekkoPurple),
        useMaterial3: true,
      ),
      navigatorObservers: [EkkoNavigatorObserver()],
      initialRoute: '/',
      routes: {'/': (_) => const ImaraHome()},
    );
  }
}

class ImaraHome extends StatefulWidget {
  const ImaraHome({super.key});

  @override
  State<ImaraHome> createState() => _ImaraHomeState();
}

class _ImaraHomeState extends State<ImaraHome> {
  int _tab = 0;

  static const _titles = ['Boutique', 'Panier', 'Compte'];

  @override
  void initState() {
    super.initState();
    Ekko.screen(_titles[_tab]);
  }

  void _selectTab(int index) {
    setState(() => _tab = index);
    // Tabs are not routes: the observer never sees them, so name them here.
    Ekko.screen(_titles[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_tab]),
        backgroundColor: _ekkoPurple,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _tab,
        children: const [ShopTab(), CartTab(), AccountTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Boutique'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Panier'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Compte'),
        ],
      ),
    );
  }
}

class Article {
  const Article(this.name, this.price, this.icon);
  final String name;
  final String price;
  final IconData icon;
}

class ShopTab extends StatelessWidget {
  const ShopTab({super.key});

  static const _articles = [
    Article('Sac Wax Douala', '18 500 F', Icons.shopping_basket_outlined),
    Article('Chemise Kente', '12 000 F', Icons.checkroom_outlined),
    Article('Sandales Bamenda', '9 500 F', Icons.hiking_outlined),
    Article('Foulard Bogolan', '6 000 F', Icons.dry_cleaning_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _articles.length,
      itemBuilder: (context, i) {
        final article = _articles[i];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                settings: RouteSettings(name: 'Article ${article.name}'),
                builder: (_) => ArticlePage(article: article),
              ),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  color: _ekkoPurple.withValues(alpha: 0.12),
                  child: Icon(article.icon, size: 56, color: _ekkoPurple),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(article.price, style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.name),
        backgroundColor: _ekkoPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 220,
            color: _ekkoPurple.withValues(alpha: 0.12),
            child: Icon(article.icon, size: 96, color: _ekkoPurple),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(article.price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class CartTab extends StatefulWidget {
  const CartTab({super.key});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  bool _ordering = false;
  bool _failed = false;

  Future<void> _order() async {
    setState(() {
      _ordering = true;
      _failed = false;
    });
    await Ekko.log('Commande envoyée — total 20 000 F');
    final started = DateTime.now();
    await Future<void>.delayed(const Duration(seconds: 2));
    await Ekko.recordRequest(
      method: 'POST',
      url: 'https://api.imara.cm/orders',
      status: 503,
      durationMs: DateTime.now().difference(started).inMilliseconds,
    );
    await Ekko.log('Paiement indisponible (503)', level: 'error');
    if (!mounted) return;
    setState(() {
      _ordering = false;
      _failed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_failed)
          Container(
            width: double.infinity,
            color: const Color(0xFFD32F2F),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Text(
              'Paiement indisponible (503)',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        const ListTile(
          leading: Icon(Icons.shopping_basket_outlined),
          title: Text('Sac Wax Douala'),
          trailing: Text('18 500 F'),
        ),
        const ListTile(
          leading: Icon(Icons.local_shipping_outlined),
          title: Text('Livraison Akwa, demain'),
          trailing: Text('1 500 F'),
        ),
        const Divider(),
        const ListTile(
          title: Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
          trailing: Text('20 000 F', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _ordering ? null : _order,
              style: FilledButton.styleFrom(backgroundColor: _ekkoPurple),
              child: _ordering
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Commander'),
            ),
          ),
        ),
      ],
    );
  }
}

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const ListTile(
          leading: CircleAvatar(child: Text('A')),
          title: Text('Aïcha Ngo'),
          subtitle: Text('aicha@imara.cm'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.bug_report_outlined),
          title: const Text('Signaler un bug'),
          onTap: Ekko.present,
        ),
        ListTile(
          leading: const Icon(Icons.vibration),
          title: const Text('Simuler la secousse'),
          onTap: Ekko.present,
        ),
      ],
    );
  }
}
