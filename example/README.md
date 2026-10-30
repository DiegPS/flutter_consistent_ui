# Ejemplo independiente

Este proyecto consume `flutter_consistent_ui` mediante `path: ../`, igual que
lo haría cualquier otra aplicación. No necesita OnAuto, un servidor ni sesión.

```powershell
flutter pub get
flutter run -d windows
# O: flutter run -d chrome
```

- Paleta: alterna color y geometría (40/48 y 44/52).
- Nuevo registro: abre un formulario fullscreen con validación.
- Probar aviso: muestra un mensaje encima del formulario.
- Guardar: valida y muestra un snackbar dentro del diálogo; no envía datos.
- Redimensionar: alterna columnas sin perder captura.
- La fuente Inter y su licencia están únicamente en este ejemplo: la biblioteca
  no obliga a instalar esa fuente en proyectos consumidores.

`flutter test` comprueba el flujo y compara dos capturas usando fuentes reales.
Hay previews en `lib/main.dart`. Para el inventario de APIs e instalación desde
otros proyectos, consulta [el README del paquete](../README.md).
