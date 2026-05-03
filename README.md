# proyecto_final_apps (VibeShare)

Aplicación Flutter para compartir imágenes entre amigos, utilizando Firebase para autenticación y datos, Imgur para almacenamiento de imágenes, y Riverpod para gestión de estado.

## Características

- **Autenticación**: Registro e inicio de sesión con email/password (Firebase Auth)
- **Compartir imágenes**: Selecciona fotos de galería y envíalas a amigos
- **Feed de imágenes**: Ver imágenes recibidas de amigos
- **Galería personal**: Historial de imágenes enviadas
- **Perfil**: Información del usuario actual
- **Selección de amigos**: Elegir a quién enviar la imagen
- **Diseño friendly**: Tema gris/azul/verde con bordes redondeados

## Estructura del Proyecto

```
lib/
├── main.dart                           # Punto de entrada con Riverpod
├── core/
│   └── constants.dart                  # Constantes de diseño y colores
├── modelos/                            # Entidades del dominio
│   ├── usuario.dart
│   ├── imagen.dart
│   └── friend.dart
├── dominio/                            # Contratos e interfaces
│   ├── repositorios/
│   │   ├── auth_repo.dart
│   │   ├── user_repo.dart
│   │   └── image_repo.dart
│   └── casos_uso/
│       ├── iniciar_sesion.dart
│       ├── registrar_usuario.dart
│       ├── cargar_imagen.dart
│       └── validar_imagen.dart         # Scaffold para IA NSFW
├── data/                               # Implementaciones concretas
│   ├── firebase/
│   │   ├── auth_servicio.dart          # Firebase Auth
│   │   └── firestore_servicio.dart     # Firestore DB
│   ├── imgur/
│   │   └── imgur_servicio.dart         # Imgur API (imágenes)
│   └── repositorios/
│       ├── auth_repo_impl.dart
│       ├── user_repo_impl.dart
│       └── image_repo_impl.dart
├── presentacion/                       # UI y Estado
│   ├── vistas/
│   │   ├── login_page.dart             # Login/Registro
│   │   ├── home_page.dart              # Feed de recibidas
│   │   ├── gallery_page.dart           # Imágenes enviadas
│   │   ├── profile_page.dart           # Perfil usuario
│   │   └── home_shell.dart             # Shell con navegación
│   ├── widgets/
│   │   ├── custom_button.dart
│   │   ├── image_card.dart
│   │   └── friend_selector.dart
│   └── providers/
│       ├── auth_provider.dart          # Estado Auth (Riverpod)
│       ├── image_provider.dart         # Estado Imágenes (Riverpod)
│       └── friends_provider.dart       # Estado Amigos (Riverpod)
└── utils/
    ├── validators.dart
    └── helpers.dart
```

## Arquitectura

La app sigue **Clean Architecture** con separación de capas:

1. **Modelos**: Entidades puras (Usuario, Imagen, Friend)
2. **Dominio**: Contratos de repositorios y casos de uso
3. **Data**: Implementaciones (Firebase, Imgur)
4. **Presentación**: UI + Providers Riverpod

## Tecnologías

| Categoría | Tecnología |
|-----------|-------------|
| Frontend | Flutter + Dart |
| Estado | Riverpod |
| Auth | Firebase Authentication |
| Base de datos | Cloud Firestore |
| Almacenamiento imágenes | Imgur API |
| Selector imágenes | image_picker |

## Configuración Firebase

1. Crear proyecto en Firebase Console
2. **Authentication**: Habilitar Email/Password
3. **Firestore**: Crear base de datos (colecciones: users, friends, images)
4. Agregar `google-services.json` (Android)
5. Ejecutar `flutter pub get`

## Configuración Imgur

El código usa Client-ID público de Imgur. Para mayor límite, obtener uno propio en https://api.imgur.com/oauth2/addclient

## Ejecutar

```bash
flutter pub get
flutter run
```

## Notas

- El caso de uso `ValidarImagen` está preparado para integrar validación NSFW via API
- Las imágenes se suben a Imgur (gratis) y los metadatos se guardan en Firestore
- No se usa Firebase Storage (para evitar costos)