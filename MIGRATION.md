# Adoptar la biblioteca en otro proyecto

## Sin romper builds de otros equipos

Para probar en tu PC, usa una dependencia `path`. Para integrar en una rama
compartida/CI, usa el repositorio público
`https://github.com/DiegPS/flutter_consistent_ui.git` con el tag `v0.3.0` o un
commit fijado. No integres un `C:/Users/...` en un
pubspec que otro equipo vaya a resolver.

La biblioteca no modifica automáticamente sus consumidores. Cada aplicación
integra explícitamente el paquete y comprueba sus propios flujos. OnAuto ya
utiliza adaptadores con nombres de producto para resolver las implementaciones
de controles, formularios, listas, métricas y navegación desde este paquete.

## Secuencia recomendada

1. Añade la dependencia y el import público
   `package:flutter_consistent_ui/flutter_consistent_ui.dart`.
2. Conserva tus colores, fuentes y extensiones. Instala
   `UiTheme.apply(tuThemeData)` en MaterialApp. Si no quieres los contornos del
   tema, instala únicamente `UiThemeData` en `ThemeData.extensions`.
3. Sustituye los controles. Conserva los mismos controllers, claves, foco,
   validadores, callbacks, permisos y estados de carga. No crees un controller
   nuevo dentro de cada build.
4. Compón campos relacionados con `UiFormFields`/`UiFormGrid`. Quita las alturas
   fijas que envolvían campos completos: su ayuda/error no debe caber dentro de
   una caja de 40. No retires ayudas para que las cosas «quepan».
5. Sustituye estructuras de listas y métricas. Pasa tus modelos convertidos en
   widgets/valores; no importes modelos de negocio dentro del paquete.
6. Al migrar un diálogo, conserva primero la política de guardar/cerrar. Usa
   el contexto del builder de `showUiFullscreenDialog` para SnackBars locales,
   o un `UiNoticeController` de la aplicación para mensajes sobre todas las rutas.
7. Ejecuta los tests de tus flujos. La biblioteca prueba la geometría y sus
   interacciones; no puede probar que tus importes, permisos o API sean correctos.

## Correspondencias de extracción desde OnAuto

| Implementación de origen | API independiente |
| --- | --- |
| OnAutoControls | UiControls |
| OnAutoControlMetrics | UiControlMetrics + UiThemeData |
| OnAutoCollectionControlScope | UiControlScope |
| OnAutoFormFields / Grid / Section | UiFormFields / Grid / Section |
| OnAutoMetricGrid / Card | UiMetricGrid / Card |
| OnAutoCollectionList / Item / Badge / Detail | UiCollectionList / Item / Badge / Detail |
| OnAutoPage / Header / Toolbar | UiPage / Header / Toolbar |
| OnAutoEmptyState | UiEmptyState |
| OnAutoSegmentedControl / Segment | UiSegmentedControl / Segment |
| OnAutoBottomNavigation / Item | UiBottomNavigation / Item |
| OnAutoFullscreenDialog | UiFullscreenDialog + showUiFullscreenDialog |
| Host global estático de avisos | UiNoticeHost + UiNoticeController por aplicación |

No todas las firmas tienen que ser idénticas al origen: se quitaron parámetros
que competían con la geometría y se agregaron opciones nativas útiles como
formatters y `readOnly`. Los textos de error de OnAuto, sus traducciones de
estados, sus permisos, navegación, IA y persistencia **no se extrajeron**.

## Contratos que debe respetar el consumidor

- Los controles estándar usan Material 3 y las métricas del perfil. No se
  garantiza que cualquier widget arbitrario tenga una altura idéntica.
- El contenido de una colección tiene que recibir altura acotada; coloca
  `UiCollectionPage` en el body/Expanded, no en un scroll vertical sin límite.
- `UiFormGrid` necesita ancho acotado. Usa las constraints locales, no el
  tamaño físico del monitor para forzar columnas.
- Usa claves estables basadas en la identidad de la entidad si reordenas
  campos. Ni Flutter ni esta biblioteca identifican un campo por su etiqueta.
- Un widget oculto visualmente no reemplaza controles de permisos del servidor.
- No sobrescribas TextScaler para hacer caber un formulario. Cambia composición,
  longitud de etiquetas o el perfil de diseño y conserva accesibilidad.
- Antes de enviar un formulario, la aplicación conserva su propia política de
  validación, reintentos, idempotencia, confirmación y recuperación de borradores.
