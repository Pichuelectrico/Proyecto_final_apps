# Especificación del Proyecto: App de Envío de Imágenes Entre Amigos

## Objetivo General

Desarrollar una aplicación móvil Flutter donde los usuarios puedan registrarse/iniciar sesión, enviar imágenes a sus contactos/amigos y recibir imágenes de otros usuarios, integrando elementos multimedia, autenticación segura, almacenamiento en la nube, y análisis básico con inteligencia artificial.

## Características Funcionales

### Autenticación

- Registro e inicio de sesión mediante correo electrónico usando Firebase Authentication.
- Protección de rutas basada en estado de autenticación.

### Usuarios

- Vista de perfil del usuario actual.
- Lista de amigos/contactos posiblemente predefinidos o gestionados manualmente.

### Envío de Imágenes

- Selector de fotos desde la galería o cámara.
- Vista previa antes de enviar.
- Guardado de imagen en Firebase Storage con metadatos (remitente, destinatario, timestamp).
- Almacenamiento de registro en Firestore.

### Recepción

- Pantalla de feed mostrando imágenes recibidas.
- Notificaciones push futuras (opcional).
- Visualización detallada de cada imagen recibida/enviada.

### Moderación Automática (IA NSFW)

- Antes de guardar/enviar una imagen, validarla contra una API pública de detección NSFW.
- Bloquear automáticamente la subida si la imagen es considerada inapropiada.

### Historial Personal

- Listado de todas las imágenes enviadas y recibidas por el usuario.
- Filtros (por amigo, fecha, etc.)

### Recursos Multimedia Adicionales

- Reproducir audios adjuntos (opcional).
- Gráficos estadísticos simples (ej. cantidad de imágenes enviadas por día).

## Requisitos Técnicos Cubiertos

| Requisito        | Tecnología Usada                                                 |
| ---------------- | ---------------------------------------------------------------- |
| Uso de APIs      | Firebase Auth / Firestore / Storage, API NSFW Detection          |
| BD Local/Remota  | Firestore (remoto)                                               |
| Manejo de Estado | Riverpod                                                         |
| Multimedia       | Imágenes desde galería/cámara + (opcional) reproducción de audio |
| IA/ML            | Consumo de API NSFW (ej. Sightengine o similar)                  |
| UX/UI Creativa   | Widgets personalizados, transiciones, diseño limpio              |

## Tecnologías Utilizadas

- **Frontend**: Flutter + Dart
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Manejo de Estado**: Riverpod
- **API Externa**: Sightengine API (detención NSFW)
- **Otros Paquetes**:
  - `firebase_auth`
  - `cloud_firestore`
  - `firebase_storage`
  - `riverpod`
  - `image_picker`
  - `http`
  - `shared_preferences`
  - `intl`
  - `flutter_spinkit`
  - `cached_network_image`
  - `sightengine` (si hay cliente SDK) o `http` directo

## Estructura del Proyecto Actualizada

lib/
├── main.dart
├── core/
│ └── constants.dart
├── modelos/
│ ├── usuario.dart
│ ├── imagen.dart
│ └── friend.dart
├── dominio/
│ ├── repositorios/
│ │ ├── auth_repo.dart
│ │ ├── user_repo.dart
│ │ └── image_repo.dart
│ └── casos_uso/
│ ├── iniciar_sesion.dart
│ ├── registrar_usuario.dart
│ ├── cargar_imagen.dart
│ └── validar_imagen.dart
├── data/
│ ├── firebase/
│ │ ├── auth_servicio.dart
│ │ ├── firestore_servicio.dart
│ │ └── storage_servicio.dart
│ └── repositorios/
│ ├── auth_repo_impl.dart
│ ├── user_repo_impl.dart
│ └── image_repo_impl.dart
├── presentacion/
│ ├── vistas/
│ │ ├── login_page.dart
│ │ ├── home_page.dart
│ │ ├── gallery_page.dart
│ │ └── profile_page.dart
│ ├── widgets/
│ │ ├── custom_button.dart
│ │ ├── image_card.dart
│ │ └── friend_selector.dart
│ └── providers/
│ ├── auth_provider.dart
│ ├── image_provider.dart
│ └── friends_provider.dart
└── utils/
├── validators.dart
└── helpers.dart

## Futuras Mejoras Potenciales

- Home screen widgets (Android/iOS)
- Comentarios en imágenes
- Grupos de envío masivo
- Soporte para mensajes de texto y emojis
- Historial visual con gráficos de actividad mensual
