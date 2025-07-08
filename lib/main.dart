import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // dibawah ini adalah judul dari aplikasi yang akan dibuat
      title: 'Joke Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Joke Generator'),
    );
  }
}

// disini menggunakan stateful widget untuk membuat halaman utama
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
// state dari halaman utama dan user interface (ui)
class _MyHomePageState extends State<MyHomePage> {
  String joke = "";
  bool loading = false;
  List<String> jokes = [];
// perintah dibawah ini untuk mengambil joke dari API
  Future<String> _fetchJoke() async {
    final res = await http.get(
      Uri.parse(
        'https://v2.jokeapi.dev/joke/Any?type=single&blacklistFlags=racist',
      ),
    );
    if (res.statusCode == 200) {
      final joke = jsonDecode(res.body);
      return joke['joke'];
    } else {
      throw Exception("Refresh to get fresh joke 😁");
    }
  }
// lalu untuk perintah dibawah ini untuk mengambil joke baru dan update state joke
  Future<void> _getJoke() async {
    setState(() {
      loading = true;
    });

    try {
      final currentJoke = await _fetchJoke();
      setState(() {
        joke = currentJoke;
        jokes.add(currentJoke);
      });
    } catch (e) {
      setState(() {
        joke = "Refresh to get fresh joke 😁";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }
// untuk perintah selanjutnya untuk menghapus joke berdasarkan index
  void _deleteJoke(int index) {
    setState(() {
      jokes.removeAt(index);
    });
  }
// perintah dibawah ini akan secara otomatis mengambil 1 joke saat aplikasi dibuka
  @override
  void initState() {
    super.initState();
    _getJoke();
  }
// untuk perintah berikut membuat user interface (UI) 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // membuat AppBar dan warnanya
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // dan dibawah ini widget card untuk menampilkan joke utama
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child:
                    loading
                        ? const CircularProgressIndicator()
                        : Text(
                          joke,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 20),
                        ),
              ),
            ),
            // untuk program dibawah untuk membuat tombol button refresh joke
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                ),
                onPressed: _getJoke,
                child: const Text("Refresh Joke"),
              ),
            ),
            // untuk program dibawah ini untuk menampilkan judul untuk list joke
            const Text(
              "Previous Jokes:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            // lalu untuk program dibawah menggunakan ListView builder untuk menampilkan semua joke
            Expanded(
              child:
                  jokes.isEmpty
                      ? const Center(child: Text("No previous jokes yet."))
                      : ListView.builder(
                        itemCount: jokes.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.mood),
                            // program berikut widget untuk teks joke
                            title: Text(jokes[index]),
                            // dan program dibawah ini untuk membuat tombol button delete per joke
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteJoke(index),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
