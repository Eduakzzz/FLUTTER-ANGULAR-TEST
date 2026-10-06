# Prueba técnica: Flutter y Angular

Aplicación Flutter preparada para un mini catálogo con Riverpod. La pantalla inicial muestra un texto estático.

## Requisitos previos

Entorno utilizado: Flutter 3.44.8 y Dart 3.12.2. Se necesita un dispositivo o destino Flutter disponible.

## Ejecutar Flutter

```powershell
cd flutter_app
flutter pub get
flutter run
```

Para utilizar un servidor web, ejecuta `flutter run -d web-server` y abre la dirección indicada en la consola.

## Arquitectura

`main.dart` inicia una aplicación Material dentro de `ProviderScope`, que proporciona el contenedor de Riverpod.

Las dependencias están declaradas en `pubspec.yaml` y sus versiones resueltas en `pubspec.lock`.

## Comprobaciones

```powershell
cd flutter_app
dart format .
flutter analyze
```
