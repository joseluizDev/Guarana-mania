import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:guarana_mania/utils/extensions.dart';

import '../../model/pedidos.dart';

class CreateRelatorioVendas extends StatelessWidget {
  List<Pedidos> pedidosPDF;
  DateTime inicio;
  DateTime fim;
  CreateRelatorioVendas({
    Key? key,
    required this.pedidosPDF,
    required this.inicio,
    required this.fim,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: PdfPreview(
        maxPageWidth: 700,
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canDebug: false,
        build: (format) => makePdf(format, pedidosPDF, inicio, fim),
      ),
    );
  }

  // ignore: long-method
  Future<Uint8List> makePdf(
    PdfPageFormat format,
    List<Pedidos> pedidosPDF,
    DateTime inicio,
    DateTime fim,
  ) async {
    final imagenAgronomic =
        (await rootBundle.load('assets/logo_pdf.png')).buffer.asUint8List();
    final fontRoboto = await PdfGoogleFonts.robotoLight();
    final fontRobotoRegular = await PdfGoogleFonts.robotoRegular();
    final pdf = pw.Document();
    // for (int i = 0; i < 10; i++) {
    //   pedidosPDF.add(pedidosPDF[i]);
    // }
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(children: [
                    pw.Spacer(),
                    pw.Image(
                      pw.MemoryImage(imagenAgronomic),
                      height: 40,
                    ),
                  ]),
                  pw.SizedBox(height: 20),
                  pw.Center(
                    child: pw.Text(
                      'Relatorio De Vendas',
                      style: pw.TextStyle(
                        fontSize: 20,
                        font: fontRoboto,
                      ),
                    ),
                  ),
                  pw.Text(
                    'Data Inicial : ${inicio.dataFormatted}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      font: fontRobotoRegular,
                    ),
                  ),
                  pw.Text(
                    'Data Final : ${fim.dataFormatted}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      font: fontRobotoRegular,
                    ),
                  ),
                  line(),
                  pw.SizedBox(height: 20),
                  ...criaTabela(pedidosPDF),
                ],
              ),
            )
          ];
        },
      ),
    );

    return pdf.save();
  }

  List<pw.Widget> criaTabela(pedidosPDF) {
    List<pw.Widget> lista = [];
    //ordenar lista
    for (Pedidos pdf in pedidosPDF) {
      lista.add(
        pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Nome: ${pdf.nome == '' ? 'Nenhuma nome informado' : pdf.nome}'
                  .toUpperCase(),
              style: const pw.TextStyle(
                fontSize: 12,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              pdf.data.dataFormatted,
              style: const pw.TextStyle(
                fontSize: 10,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'forma de pagamento: ${pdf.pagamento}'.toUpperCase(),
              style: const pw.TextStyle(
                fontSize: 10,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.ListView.builder(
              itemCount: pdf.produtos.length,
              itemBuilder: (pw.Context context, int index) {
                return pw.Column(
                  children: [
                    pw.Text(
                      'Produto: ${pdf.produtos[index].tipo}'.toUpperCase(),
                      style: const pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      '${pdf.produtos[index].nome} x ${pdf.produtos[index].qtde.toInt().toString()}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                  ],
                );
              },
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Total: ${pdf.total.formatted}',
              style: const pw.TextStyle(
                fontSize: 12,
              ),
            ),
            line(),
          ],
        ),
      );
    }
    return lista;
  }

  tabe(produtosPedido) {}

  line() {
    return pw.Divider(
      thickness: 0.5,
      height: 20,
    );
  }

  dualline(widget1, widget2) {
    return pw.Row(children: [
      widget1,
      pw.Spacer(),
      widget2,
    ]);
  }

  textCustom(
    String title,
    String tipo,
    String qtde, {
    PdfColor? color,
    pw.Font? font,
  }) {
    return pw.Column(
      children: [
        pw.FittedBox(
          fit: pw.BoxFit.contain,
          child: pw.Text(
            tipo,
            style: pw.TextStyle(
              color: color,
              font: font,
            ),
          ),
        ),
        pw.FittedBox(
          fit: pw.BoxFit.contain,
          child: pw.Text(
            title,
            style: pw.TextStyle(
              color: color,
              font: font,
            ),
          ),
        ),
        pw.FittedBox(
          fit: pw.BoxFit.contain,
          child: pw.Text(
            qtde.toString(),
            style: pw.TextStyle(
              color: color,
              font: font,
            ),
          ),
        )
      ],
    );
  }
}