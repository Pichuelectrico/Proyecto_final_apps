# flutter_bdd_firebase_ejm4

Aplicación Flutter que permite gestionar usuarios, utilizando Firebase Firestore como base de datos y siguiendo una arquitectura limpia (Clean Architecture / Domain-Driven Design).

## Características

- **Ver usuarios**: Muestra una lista de todos los usuarios almacenados en Firestore, ordenados alfabéticamente por nombre.
- **Agregar usuarios**: Botón flotante para agregar nuevos usuarios mediante un formulario.
- **Persistencia en la nube**: Los datos se almacenan en Firebase Firestore.

## Estructura del Proyecto

```
lib/
├── main.dart                           # Punto de entrada de la app
├── modelos/
│   └── usuario_modelo.dart             # Modelo de datos del usuario
├── dominio/
│   └── repositorio_usuario.dart        # Interfaz del repositorio (contrato)
├── data/
│   ├── firebase_fuente_datos_usuario.dart  # Fuente de datos Firestore
│   └── repositorio_usuario_impl.dart        # Implementación del repositorio
├── usecases/
│   ├── obtener_usuarios.dart           # Caso de uso: obtener usuarios
│   └── agregar_usuario.dart            # Caso de uso: agregar usuario
└── presentacion/
    ├── pagina_principal.dart           # Página principal con lista de usuarios
    └── widget_usuario.dart             # Widget para mostrar cada usuario
```

## Arquitectura

La app sigue los principios de **Clean Architecture** con las siguientes capas:

1. **Modelo (Modelos)**: Representación de los datos - `Usuario` con campos `id`, `nombre`, `correo`
2. **Dominio (Dominio)**: Define el contrato del repositorio - `RepositorioUsuario`
3. **Data (Data)**: Implementación concreta - `RepositorioUsuarioImpl` y `FuenteDatosUsuarioFirebase`
4. **Casos de Uso (Usecases)**: Lógica de negocio - `ObtenerUsuarios`, `AgregarUsuario`
5. **Presentación (Presentacion)**: Interfaz de usuario - `PaginaPrincipal`, `WidgetUsuario`

## Requisitos

- Flutter SDK
- Firebase Core (`firebase_core`)
- Cloud Firestore (`cloud_firestore`)

## Configuración

1. Crear un proyecto en Firebase Console
2. Habilitar Firestore Database
3. Agregar el archivo `google-services.json` (Android) o configurar via Firebase CLI
4. Ejecutar `flutter pub get`

## Getting Started

```bash
flutter run
```