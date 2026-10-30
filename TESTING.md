# Verificación del paquete 0.2.1

Entorno utilizado: Windows, Flutter 3.47.2 y Dart 3.13.2.

## Resultado local

- 46 pruebas de unidad/widgets del paquete aprobadas.
- 2 recorridos del ejemplo consumidor aprobados (390/1280), incluyendo cambio
  de identidad, validación, captura, aviso global y snackbar del fullscreen.
- Cobertura de líneas: **1,050/1,188 = 88.4 %**, sin exclusiones para inflar la cifra.
- `dart analyze --fatal-infos` y formato verificables desde la raíz.
- Compilación Windows debug del ejemplo aprobada (39.8 s). Ejecutable en
  `example/build/windows/x64/runner/Debug/consistent_ui_example.exe`.
- Ejemplo ejecutado en Windows con Impeller y hot reload correcto (432 ms).
- Compilación web release del ejemplo comprobada. Flutter emitió un aviso de
  fuente Cupertino no incluida por el ejemplo Material; los iconos Material
  utilizados sí están incluidos. No se añadió una dependencia de iconos al
  paquete para silenciar un aviso del consumidor.

El porcentaje mide líneas ejecutadas, no exhaustividad de comportamientos ni
la inexistencia de bugs. Los tests no son 45 recorridos de una API: el paquete
no necesita servidor. También se prueba UiStatCard (vertical/compacta) y
UiSplitView con navegación/acciones a 360/1200.

## Casos cubiertos

- Borde visible de inputs, formularios, dropdowns y ocho variantes de botones;
  390/1200 y texto 1/1.5/2.
- Perfil alternativo 44/52, fuente/color del consumidor y claro/oscuro.
- Ayudas, errores y multilínea fuera del borde; acciones largas que crecen.
- Claves, texto y foco al reordenar y redimensionar.
- Validación, Form.save y formatters nativos.
- Grids de formulario a 320/600/760/1200 y texto ampliado.
- Métricas sin FittedBox, ancho aprovechado y altura natural.
- Familias semánticas con contraste AA por defecto en claro/oscuro.
- Listas lazy, búsqueda sin controlador externo, selección y paginación.
- Región de aviso y acciones sobre fullscreen; messenger local de la ruta.
- Cancelación de temporizadores al reemplazar avisos.
- Componentes públicos de presentación, navegación, gráficos y estados vacíos.
- Guarda de independencia: sin imports del proyecto de origen, Dio, Riverpod
  ni dart:io en el runtime del paquete.

## Ejecutar

```powershell
flutter pub get
dart analyze --fatal-infos
flutter test --coverage
dart format --output=none --set-exit-if-changed lib test example/lib example/test
cd example
flutter pub get
flutter test
flutter build web --release
flutter build windows --debug
```

La cobertura se escribe en `coverage/lcov.info`. Las referencias visuales del
ejemplo están en `example/test/goldens`, con fuentes e iconos reales cargados.
La fuente del ejemplo tiene su licencia adjunta y no se impone a consumidores.

No se ha comprobado físicamente Android/iOS/macOS/Linux. No hay plugins nativos
en la biblioteca, pero eso no sustituye probar cada aplicación en sus plataformas.
