# flutter_consistent_ui

Biblioteca Flutter **independiente** para dejar de resolver en cada proyecto la
misma diferencia de tamaños entre inputs, selectores y botones. Extrae también
las composiciones que los rodean: formularios adaptables, listas, tarjetas,
cabeceras, métricas, navegación, estados vacíos, diálogos y avisos.

No depende de OnAuto, Riverpod, Dio, una base de datos, una API o un servicio.
La única dependencia de ejecución es el SDK de Flutter. No registra fuentes,
no incluye logos y no obliga a usar los colores de otro producto.

## Estado y ubicación

- Paquete independiente: `C:/Users/dpahu/Documents/flutter_consistent_ui`.
- API inicial: `0.1.0`, distribuida por Git (`publish_to: none` evita publicar en pub.dev).
- Flutter mínimo **3.47.0**, Dart **3.13.0**. Se declara el SDK realmente probado;
  no se promete compatibilidad con versiones antiguas sin verificarlas.
- Repositorio público: https://github.com/DiegPS/flutter_consistent_ui.
- No está publicado en pub.dev.
- OnAuto conserva sus dependencias actuales. No se introdujo una ruta local que
  deje de existir cuando su CI clone únicamente el repositorio de OnAuto.

## Instalar desde GitHub

```yaml
dependencies:
  flutter_consistent_ui:
    git:
      url: https://github.com/DiegPS/flutter_consistent_ui.git
      ref: v0.1.0
```

Ejecuta `flutter pub get`. El tag fija la versión para que una modificación de
`main` no cambie inesperadamente los componentes de tus proyectos.

## Desarrollo local

En el `pubspec.yaml` del proyecto consumidor:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_consistent_ui:
    path: C:/Users/dpahu/Documents/flutter_consistent_ui
```

También puedes usar una ruta relativa si los repositorios están uno al lado del
otro. Ejecuta `flutter pub get`. La ruta es del consumidor: **no hay que copiar
los archivos de la biblioteca a cada proyecto**.

Para equipos/CI usa la dependencia Git anterior, no una ruta de tu PC.

## Inicio mínimo

```dart
import 'package:flutter/material.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';

final theme = UiTheme.apply(
  ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    fontFamily: 'LaFuenteDeMiProyecto', // Registrar en TU pubspec, si la usas.
  ),
  geometry: const UiThemeData(
    controlHeight: 40,
    compactControlHeight: 48,
    compactBreakpoint: 600,
    fontSize: 14,
    lineHeight: 20,
    controlRadius: 6,
    formSpacing: 20,
  ),
);

// MaterialApp(theme: theme, home: ...)
```

`UiTheme.apply` conserva el esquema de colores, fuentes y extensiones del tema
recibido. Añade el perfil geométrico y los contornos. También es posible instalar
solamente `UiThemeData` en `ThemeData.extensions`, conservando todos los demás
estilos del consumidor. Sin extensión, los componentes usan el perfil por defecto.

### Controles

```dart
UiFormFields(children: [
  UiControls.formInput(
    controller: nameController,
    decoration: const InputDecoration(
      labelText: 'Nombre *',
      helperText: 'Las ayudas tienen su propio espacio debajo del borde.',
    ),
    validator: (value) => value!.isEmpty ? 'Captura el nombre.' : null,
  ),
  UiControls.select<String>(
    initialValue: 'active',
    decoration: const InputDecoration(labelText: 'Estado'),
    items: const [DropdownMenuItem(value: 'active', child: Text('Activo'))],
    onChanged: (value) {},
  ),
  UiControls.primaryIcon(
    onPressed: save,
    icon: const Icon(Icons.save_outlined),
    label: const Text('Guardar'),
  ),
]);
```

Los constructores devuelven controles nativos de Flutter. Las claves quedan en
el nativo, y una clave estable en su frontera conserva estado/foco al reordenar.
El consumidor sigue siendo dueño de sus controladores y debe disponerlos cuando
corresponda. Se conservan validadores, callbacks, formatters, teclado, autofill
de formularios, `readOnly`, `onSaved` y opciones documentadas en las firmas.
No se recrea el sistema de edición de texto ni se altera el backend.

Acciones: `primary`, `primaryIcon`, `tonal`, `tonalIcon`, `secondary`,
`secondaryIcon`, `quiet`, `quietIcon`. Todas aceptan estilos de color/forma;
la geometría central gana frente a un `fixedSize`, padding o mínimo aislado.
Para cambiar medidas, cambia el perfil, no cada botón.

## Qué significa «misma altura»

Se iguala el **borde pintado de InputDecorator** con la **superficie Material del
botón**, no la altura exterior del widget. Un dropdown denso aún tiene un mínimo
interno de 24 y recibe otro padding vertical; copiarle el de TextField lo agranda.

Por defecto son 40 unidades lógicas en ancho >=600 y 48 en compacto. Son valores
configurables, no píxeles físicos ni promesas del tamaño predeterminado del SO.
TextScaler aumenta la altura; no se limita ni se usa FittedBox para encoger texto.
La tipografía escala de forma conjunta con la geometría del perfil.

Ayudas, errores, contadores, contenido multilínea y acciones con texto largo
conservan su altura natural. Un icono/child personalizado gigante puede necesitar
más espacio; la biblioteca no recorta arbitrariamente widgets suministrados por
el consumidor. Los mínimos táctiles nativos de Material se conservan.

## Componentes incluidos

| Familia | API |
| --- | --- |
| Geometría y tema | `UiTheme`, `UiThemeData`, `UiControlMetrics`, `UiControlScope` |
| Colores semánticos | `UiTone`, `UiSemanticColors`; configurables, con bases clara/oscura |
| Formularios | `UiFormFields`, `UiFormGrid`, `UiFormSection` |
| Listas y filtros | `UiCollectionPage`, `UiCollectionToolbar`, `UiSearchField`, `UiCollectionList.builder`, `UiCollectionItem`, `UiCollectionBadge`, `UiCollectionDetail`, `UiPagination` |
| Métricas | `UiMetricGrid`, `UiMetricCard`, `UiSparkline`, `UiCountUpText` |
| Estructura | `UiPage`, `UiPageHeader`, `UiPageToolbar`, `UiLayoutBuilder`, `UiLayout` |
| Navegación | `UiBottomNavigation`, `UiBottomNavigationItem`, `UiSegmentedControl`, `UiSegment` |
| Estados | `UiEmptyState`; errores de dominio se traducen en el consumidor |
| Diálogos | `showUiFullscreenDialog`, `UiFullscreenDialog` |
| Avisos | `UiNoticeController`, `UiNoticeHost`, `UiNotice` |

`UiFormGrid` necesita ancho limitado, como los campos nativos; calcula columnas
con el espacio local y TextScaler. Mantiene la misma estructura y claves al
redimensionar. `UiMetricGrid` ocupa el ancho completo con 1/2/4 columnas y altura
natural. Usar listas builder para catálogos grandes; el constructor con `children`
es para listas pequeñas que el consumidor ya construyó.

Los textos de negocio, traducciones, confirmaciones destructivas, números,
permisos, rutas y peticiones pertenecen al consumidor. Se suministran como texto,
widgets o callbacks. Ninguna tarjeta «sabe» qué es una orden, una factura o un tenant.

### Mensajes dentro de fullscreen

```dart
showUiFullscreenDialog<void>(
  context: context,
  builder: (dialogContext) => UiFullscreenDialog(
    title: const Text('Editar'),
    content: UiControls.secondary(
      onPressed: () => ScaffoldMessenger.of(dialogContext).showSnackBar(
        const SnackBar(content: Text('Revisa los datos.')),
      ),
      child: const Text('Validar'),
    ),
  ),
);
```

Usa el contexto del builder, no el de la pantalla de atrás. El helper instala un
ScaffoldMessenger propio en la ruta. Para avisos que deban estar sobre cualquier
modal, monta `UiNoticeHost` en `MaterialApp.builder` y conserva un
`UiNoticeController` por aplicación/ventana (disponerlo al cerrar). No hay singleton
estático compartido. Los callbacks de una notificación pueden crear otra sin que
un temporizador anterior la elimine.

### Valores de métricas y animación

`UiMetricCard` recibe valores **ya formateados** y por defecto no los anima. La
utilidad opcional `UiCountUpText` admite la notación decimal con punto y miles
con coma; no es un formateador monetario internacional. Para otros formatos,
mostrar el valor estático o aportar una composición/animación del consumidor.

## Ejemplo ejecutable

```powershell
git clone https://github.com/DiegPS/flutter_consistent_ui.git
cd flutter_consistent_ui/example
flutter pub get
flutter run -d windows
# O: flutter run -d chrome
```

El ejemplo cambia entre dos identidades y perfiles de tamaños con el botón de
paleta. Incluye listas, formulario fullscreen, validación y aviso encima del
formulario. No necesita credenciales ni servidor. Hay previews de escritorio y
móvil en `example/lib/main.dart`.

Se incluyen los runners Windows/web. En otra máquina puedes generar los otros
runners con `flutter create --platforms=macos,linux,android,ios .` dentro de example
según las herramientas de ese host. Eso no significa que se hayan probado esos
sistemas físicamente.

## Verificación local

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test example/lib
dart analyze --fatal-infos
flutter test --coverage
cd example
flutter pub get
flutter test
flutter build web
```

Las pruebas heredadas de geometría se ejecutan contra **este paquete**, no contra
OnAuto. Se agregan pruebas de perfiles distintos, colores/fuentes, claro/oscuro,
validación, callbacks, paginación, búsqueda sin controlador externo, listas lazy,
foco/captura y mensajes encima de fullscreen. La cobertura se genera en
`coverage/lcov.info`; no se ocultan archivos con directivas para inflar el porcentaje.

## Distribución y mantenimiento

Es una base Material, no Fluent UI ni Cupertino nativo, y no afirma que todos los
controles estándar de Flutter se puedan pasar con parámetros arbitrarios. Las
firmas públicas documentan las opciones disponibles; una nueva opción se añade
al adaptador con su prueba. Cambios incompatibles requieren incrementar versión.
Al compartirla mediante Git, fija un tag/commit por proyecto; evita depender de
`main` flotante o editar copias divergentes de los mismos componentes.

El repositorio incluye código, documentación, tests y ejemplo; no incluye builds,
credenciales ni archivos temporales. No hay workflows de GitHub Actions ni cambios
en las dependencias de producción de OnAuto.

El código fuente se hace público sin añadir en esta versión una licencia de
redistribución para terceros. La fuente Inter del ejemplo conserva su propia
licencia OFL en `example/assets/fonts/LICENSE.txt`.
