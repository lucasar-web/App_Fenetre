import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'dart:convert';
import '../models/chantier.dart';

class DxfExportService {
  static Future<void> genererDxfChassis(Chassis chassis) async {
    final buffer = StringBuffer();

    // En-tête minimal DXF
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('ENTITIES');

    // Dessiner chaque élément comme un rectangle
    for (var el in chassis.elements) {
      _drawRectangle(buffer, el.x, -el.y, el.largeur, el.hauteur); // Y est inversé en CAO
    }

    // Fin du fichier DXF
    buffer.writeln('0');
    buffer.writeln('ENDSEC');
    buffer.writeln('0');
    buffer.writeln('EOF');

    final String dxfContent = buffer.toString();
    final Uint8List bytes = Uint8List.fromList(utf8.encode(dxfContent));

    await FileSaver.instance.saveFile(
      name: 'Chassis_${chassis.nom}_${DateTime.now().millisecondsSinceEpoch}.dxf',
      bytes: bytes,
      mimeType: MimeType.text, // ou application/dxf
    );
  }

  static void _drawRectangle(StringBuffer buffer, double x, double y, double width, double height) {
    // Coins du rectangle
    // (x, y) est le coin haut gauche (avant inversion y). En CAO classique, le bas est Y=0.
    // Ici on simplifie :
    // P1: (x, y)
    // P2: (x + w, y)
    // P3: (x + w, y - h)
    // P4: (x, y - h)

    _drawLine(buffer, x, y, x + width, y);
    _drawLine(buffer, x + width, y, x + width, y - height);
    _drawLine(buffer, x + width, y - height, x, y - height);
    _drawLine(buffer, x, y - height, x, y);
  }

  static void _drawLine(StringBuffer buffer, double x1, double y1, double x2, double y2) {
    buffer.writeln('0');
    buffer.writeln('LINE');
    buffer.writeln('8'); // Layer
    buffer.writeln('0'); // Nom du layer
    buffer.writeln('10'); // X start
    buffer.writeln(x1.toStringAsFixed(2));
    buffer.writeln('20'); // Y start
    buffer.writeln(y1.toStringAsFixed(2));
    buffer.writeln('30'); // Z start
    buffer.writeln('0.0');
    buffer.writeln('11'); // X end
    buffer.writeln(x2.toStringAsFixed(2));
    buffer.writeln('21'); // Y end
    buffer.writeln(y2.toStringAsFixed(2));
    buffer.writeln('31'); // Z end
    buffer.writeln('0.0');
  }
}
