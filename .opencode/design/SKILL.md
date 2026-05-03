# Diseño Arquitectónico y Estético del Sistema

## Identidad Visual y Experiencia de Usuario (UX/UI)

### Concepto: "Friendly & Secure Sharing"

La aplicación está diseñada bajo una **vibe friendly (amistosa)**, buscando que el intercambio de imágenes se sienta como un espacio seguro y cercano entre amigos.

### Paleta de Colores

- **Fondo de Aplicación**: Gris neutral (Grey 50/100 para modo claro o BlueGrey 900 para modo oscuro), proporcionando un lienzo que no cansa la vista y hace resaltar el contenido multimedia.
- **Color Primario (Acción y Confianza)**: Azul (p. ej., `Colors.blueAccent` o `Colors.lightBlue`), utilizado para botones de acción principal, navegación y elementos de seguridad.
- **Color Secundario (Cercanía y Éxito)**: Verde (p. ej., `Colors.greenAccent` o `Colors.teal`), aplicado en indicadores de "amigo conectado", confirmaciones de envío exitoso y elementos de validación positiva.
- **Tipografía**: Fuentes redondeadas (como _Quicksand_ o _Nunito_) para reforzar la sensación de amigabilidad.

## Principios Arquitectónicos Aplicados

### Clean Architecture

Se mantiene la separación clara de capas siguiendo principios de **Clean Architecture** adaptados a Flutter:

1. **Modelos (Entities)**: Estructuras de datos puras como `Usuario`, `Imagen`.
2. **Dominio (Use Cases)**: Lógica de negocio (ej: `EnviarImagen`, `ValidarContenido`).
3. **Data Layer**: Implementaciones de Firebase (Firestore/Storage) y consumo de APIs REST.
4. **Presentación (UI & Providers)**: Widgets estilizados con la paleta Azul/Verde y manejo de estado reactivo con `Riverpod`.

## Patrones de Diseño Empleados

- **Theme Pattern**: Uso de un `ThemeData` centralizado para asegurar que los colores Azul, Verde y el fondo Gris se apliquen consistentemente en toda la app.
- **Repository Pattern**: Abstracción de la lógica de datos.
- **Dependency Injection**: Implementada mediante `Riverpod` para una gestión eficiente de dependencias.

## Estrategia de Seguridad y Moderación

- **Seguridad**: Reglas de Firestore para acceso privado.
- **Moderación Inteligente**: Integración de API externa para detección NSFW, asegurando que la "vibe friendly" no se vea comprometida por contenido inapropiado.

## Componentes Visuales Destacados

- **Tarjetas de Imagen (Cards)**: Bordes muy redondeados y sombras suaves para una estética moderna y amigable.
- **Botón Flotante (FAB)**: Color verde vibrante para invitar a la acción de compartir.
- **Feedback**: Uso de micro-animaciones en azul para procesos de carga y verde para confirmaciones.

## Estrategia de Almacenamiento y Performance

- **Imágenes**: Optimización de carga mediante `CachedNetworkImage` para evitar consumo excesivo de datos.
- **Paginación**: Scroll infinito en el feed de amigos para mantener la fluidez de la interfaz.

---

> El diseño visual busca equilibrar la robustez técnica de Firebase con una interfaz que invite a la interacción social positiva, utilizando una paleta de colores que transmite calma (azul) y vitalidad (verde) sobre una base sólida y moderna (gris).

> Para que esto se refleje de inmediato en el proyecto, te sugiero definir tu tema en main.dart de esta forma:

dart
// Ejemplo de configuración de tema para cumplir con el diseño propuesto
final appTheme = ThemeData(
brightness: Brightness.light,
primaryColor: Colors.blue,
scaffoldBackgroundColor: Colors.grey[100], // Fondo gris friendly
colorScheme: ColorScheme.fromSwatch().copyWith(
secondary: Colors.green, // Color verde para acentos
),
appBarTheme: const AppBarTheme(
backgroundColor: Colors.blue,
foregroundColor: Colors.white,
elevation: 0,
),
cardTheme: CardTheme(
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
elevation: 2,
),
);
