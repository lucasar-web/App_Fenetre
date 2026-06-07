import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_selector/file_selector.dart';
import 'package:printing/printing.dart';
import '../models/chantier.dart';

class PdfExportService {
  static Future<void> genererPdfProduction(Chantier chantier) async {
    // Chargement d'une police supportant l'Unicode pour éviter l'erreur Helvetica
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: fontBold,
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(chantier),
            pw.SizedBox(height: 20),
            _buildChassisSummary(chantier),
            pw.SizedBox(height: 20),
            _buildListeDebit(chantier),
            pw.SizedBox(height: 20),
            _buildListeVitrage(chantier),
          ];
        },
      ),
    );

    final Uint8List bytes = await pdf.save();

    final FileSaveLocation? saveLocation = await getSaveLocation(
      suggestedName: 'Prod_${chantier.nom}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    if (saveLocation != null) {
      final XFile xFile = XFile.fromData(bytes, mimeType: 'application/pdf');
      await xFile.saveTo(saveLocation.path);
    }
  }

  static pw.Widget _buildHeader(Chantier chantier) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('LISTE DE PRODUCTION', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.Divider(),
        pw.Text('Chantier: ${chantier.nom}', style: const pw.TextStyle(fontSize: 18)),
        pw.Text('Généré par: ${chantier.creePar} le ${DateTime.now().toString().split('.')[0]}'),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Essence: ${chantier.essenceBois}'),
            pw.Text('Vitrage: ${chantier.vitrage}'),
            pw.Text('Finition: ${chantier.finition}'),
            pw.Text('Épaisseur: ${chantier.epaisseurBois}mm'),
          ],
        ),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildChassisSummary(Chantier chantier) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Récapitulatif des Châssis et Visuels', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Wrap(
          spacing: 20,
          runSpacing: 20,
          children: chantier.chassis.map((c) => _buildPdfChassisVisuel(c)).toList(),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfChassisVisuel(Chassis chassis) {
    const double maxSize = 100.0;

    if (chassis.hauteur == 0 || chassis.largeur == 0 || chassis.elements.isEmpty) {
      return pw.Container(
        width: maxSize,
        height: maxSize + 20,
        child: pw.Column(
          children: [
            pw.Text(chassis.nom, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('${chassis.largeur} x ${chassis.hauteur} (${chassis.quantite}x)', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 10),
            pw.Text('[Aucun élément dessiné]'),
          ],
        ),
      );
    }

    double scale = maxSize / chassis.hauteur;
    if (scale * chassis.largeur > maxSize) {
      scale = maxSize / chassis.largeur;
    }

    final double scaledWidth = chassis.largeur * scale;
    final double scaledHeight = chassis.hauteur * scale;

    return pw.Container(
      width: maxSize + 20,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(chassis.nom, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('${chassis.largeur} x ${chassis.hauteur} (${chassis.quantite}x)', style: const pw.TextStyle(fontSize: 10)),
          if (chassis.vitrageOverride != null) pw.Text('Vitrage: ${chassis.vitrageOverride}', style: const pw.TextStyle(fontSize: 8)),
          pw.SizedBox(height: 5),
          pw.Container(
            width: scaledWidth,
            height: scaledHeight,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1),
            ),
            child: pw.Stack(
              children: chassis.elements.map((el) {
                return pw.Positioned(
                  left: el.x * scale,
                  top: el.y * scale,
                  width: el.largeur * scale,
                  height: el.hauteur * scale,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.brown800, width: 0.5),
                      color: PdfColors.brown200,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildListeDebit(Chantier chantier) {
    // Calcul simplifié du débit: on prend juste tous les éléments du builder
    List<List<String>> debitData = [];
    for (var chassis in chantier.chassis) {
      for (var el in chassis.elements) {
        // Quantité de cette pièce = 1 * quantité de chassis
        debitData.add([
          chassis.nom,
          el.type,
          chassis.quantite.toString(),
          el.largeur.toStringAsFixed(1),
          el.hauteur.toStringAsFixed(1),
        ]);
      }
    }

    if (debitData.isEmpty) {
      return pw.Text('Aucune pièce définie dans les châssis.');
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Liste de Débit (Bois)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          context: null,
          headers: ['Châssis', 'Type', 'Qte totale', 'Largeur (mm)', 'Longueur (mm)'],
          data: debitData,
        ),
      ],
    );
  }

  static pw.Widget _buildListeVitrage(Chantier chantier) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Liste de Vitrage', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          context: null,
          headers: ['Châssis', 'Type de Vitrage', 'Quantité', 'Dim. approx (LxH)'],
          data: chantier.chassis.map((c) => [
            c.nom,
            c.vitrageOverride ?? chantier.vitrage,
            c.quantite.toString(),
            '${c.largeur - 100} x ${c.hauteur - 100}' // Simplification pour la démo
          ]).toList(),
        ),
      ],
    );
  }
}
