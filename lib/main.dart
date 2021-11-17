import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Estados {
  int cases = 0;
  int deaths = 0;
  String state = "";

  Estados({required this.cases, required this.deaths, required this.state});

  Estados.fromJson(Map<String, dynamic> json) {
    cases = json['cases'];
    deaths = json['deaths'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cases'] = this.cases;
    data['deaths'] = this.deaths;
    data['state'] = this.state;
    return data;
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Busca Covid',
    theme: ThemeData(primarySwatch: Colors.red),
    home: Prova(),
  ));
}

class Prova extends StatefulWidget {
  @override
  FormularioProva createState() {
    return FormularioProva();
  }
}

class FormularioProva extends State<Prova> {
  final formKey = GlobalKey<FormState>();
  final messengerKey = GlobalKey<ScaffoldMessengerState>();
  String nome = "";
  String cidade = "";
  String estado = "";
  var contexto;

  @override
  Widget build(BuildContext context) {
    contexto = context;
    return MaterialApp(
        scaffoldMessengerKey: messengerKey,
        home: Scaffold(
            appBar: AppBar(
                title: new Text("Insira seus dados")),
            body: SingleChildScrollView(
                child: Container(
              margin: new EdgeInsets.all(15.0),
              child: Form(key: formKey, child: FormularioProvaUI(this)),
            ))));
  }
}

// ignore: non_constant_identifier_names
Widget FormularioProvaUI(var formularioProva) {
  return Column(children: [
    Text("Tiago de Freitas"),
    TextFormField(
        decoration: InputDecoration(labelText: "Nome:"),
        onSaved: (String? val) {
          formularioProva.setState(() {
            formularioProva.nome = val!;
          });
        }),
    TextFormField(
        decoration: InputDecoration(labelText: "Cidade:"),
        onSaved: (String? val) {
          formularioProva.setState(() {
            formularioProva.cidade = val!;
          });
        }),
    TextFormField(
        decoration: InputDecoration(labelText: "UF:"),
        onSaved: (String? val) {
          formularioProva.setState(() {
            formularioProva.estado = val!;
          });
        }),
    RaisedButton(
        child: Text("Consultar"),
        onPressed: () {
          formularioProva.formKey.currentState.save();

          if (formularioProva.nome != "" &&
              formularioProva.cidade != "" &&
              formularioProva.estado != "") {
            Navigator.push(
                formularioProva.contexto,
                MaterialPageRoute(
                    builder: (context) => SegundaRota(
                          estado: formularioProva.estado,
                        )));
          } else {
            formularioProva.messengerKey.currentState.showSnackBar(
                SnackBar(content: Text("Preencha todos os dados!")));
          }
        })
  ]);
}

Future<List<Estados>> fetchEstados() async {
  final response = await http
      .get(Uri.parse("https://covid19-brazil-api.vercel.app/api/report/v1"));

  if (response.statusCode == 200) {
    return (json.decode(response.body)["data"] as List)
        .map((i) => Estados.fromJson(i))
        .toList();
  } else {
    throw Exception("Pane Geral");
  }
}

// ignore: must_be_immutable
class SegundaRota extends StatefulWidget {
  final String estado;
  SegundaRota({required this.estado});

  @override
  _SegundaRota createState() => _SegundaRota();
}

class _SegundaRota extends State<SegundaRota> {
  late Future<List<Estados>> futureEstados;

  @override
  void initState() {
    super.initState();
    futureEstados = fetchEstados();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: Text("Dados")),
            body: Center(
                child: FutureBuilder<List<Estados>>(
                    future: futureEstados,
                    builder: (context, snapshot) => ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data![index];
                          return ListTile(
                            title: Text("Casos de covid em/no ${item.state}: ${item.cases}"),
                            subtitle: Text(
                                "Total de Mortes por covid: ${item.deaths}"),
                            isThreeLine: true,
                          );
                        })))));
  }
}
