import 'package:flutter/material.dart';
import 'package:pwa_install/pwa_install.dart';
import 'package:pwa_update_listener/pwa_update_listener.dart';

import 'models/post.dart';
import 'services/dummy_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String routeName = 'home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Boilerplate')),
      body: PwaUpdateListener(
        onReady: () {
          debugPrint('Readdy!');

          /// Show a snackbar to get users to reload into a newer version
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Expanded(child: Text('A new update is ready')),
                  TextButton(
                    onPressed: reloadPwa,
                    child: Text('UPDATE'),
                  ),
                ],
              ),
              duration: Duration(days: 365),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: FutureBuilder(
          future: DummyService.getPostsWithCaching(),
          builder: (context, AsyncSnapshot<List<Post>> snapshot) {
            if (snapshot.hasData) {
              return RefreshIndicator(
                onRefresh: () async => setState(() {}),
                child: ListView.separated(
                  separatorBuilder: (context, idx) => const Divider(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${snapshot.data![index].id}'),
                      ),
                      title: Text(snapshot.data![index].title!),
                      subtitle: Text(snapshot.data![index].body!),
                    );
                  },
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: (!PWAInstall().installPromptEnabled)
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                try {
                  PWAInstall().promptInstall_();
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
              label: const Text('Install'),
              icon: const Icon(Icons.download_for_offline),
            ),
    );
  }
}
