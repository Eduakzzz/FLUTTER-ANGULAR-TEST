# Prueba técnica: Flutter y Angular

Mini catálogo Flutter con productos de DummyJSON, búsqueda y carrito local, junto con un panel Angular de pedidos obtenidos de la misma API. El carrito Flutter y los pedidos Angular son independientes.

## Requisitos previos

- Flutter 3.44.8 / Dart 3.12.2 (entorno utilizado).
- Node.js 22.22.3 y npm 10.9.8 (entorno utilizado). Angular 21 requiere una versión de Node compatible; las dependencias exactas están en los lockfiles.
- Conexión a Internet para consultar DummyJSON. Para Flutter, un navegador o un dispositivo configurado en el SDK.

## Estructura

```text
flutter_app/    Catálogo, detalle y carrito con Riverpod
angular_app/    Panel de pedidos con componentes standalone
RESPUESTAS.md   Preguntas conceptuales y code review
```

## Ejecutar Flutter

Desde la raíz del repositorio:

```powershell
cd flutter_app
flutter pub get
flutter run -d chrome
```

También se puede usar `flutter run` para elegir un dispositivo disponible, o `flutter run -d web-server` y abrir la dirección indicada en la consola.

### Comprobaciones Flutter

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build web --release
```

Las pruebas cubren carrito, acceso a datos, providers y widgets. `ProviderContainer.test` y `ProviderScope.overrides` permiten inyectar un `FakeProductRepository`; las pruebas HTTP usan `MockClient`, sin depender de la API real.

## Ejecutar Angular

Desde la raíz del repositorio:

```powershell
cd angular_app
npm ci
npm start
```

Abrir `http://localhost:4200`.

### Comprobaciones Angular

```powershell
npm run build
npm test -- --watch=false
```

Las pruebas usan `HttpTestingController` y `TestBed` para controlar respuestas y eventos sin peticiones a DummyJSON.

## Decisiones de arquitectura

### Flutter

La organización por funcionalidad separa:

- **Dominio:** entidades `Product` y `CartItem`, y contrato `ProductRepository`.
- **Datos:** `ProductRemoteDataSource` realiza HTTP y valida la estructura de las respuestas; `ProductRepositoryImpl` implementa el contrato.
- **Presentación:** pantallas, widgets y providers. Los widgets no realizan HTTP.

`Product.fromJson` usa mapeo manual: el modelo es pequeño, la conversión queda explícita y no requiere generación de código. A cambio, la entidad conoce JSON; separaría un DTO si creciera el contrato. Los campos son `final` y las listas de productos y carrito no se pueden modificar.

`productRepositoryProvider` inyecta el repositorio y cierra su cliente HTTP al desecharse. Los `FutureProvider.autoDispose` representan carga, error y datos; el detalle usa `family` por ID. El reintento es explícito mediante invalidación. La búsqueda publica el texto tras **400 ms** sin cambios y cancela su timer al desecharse.

`CartNotifier` agrupa productos por ID y publica listas nuevas para agregar, quitar o modificar cantidades. El contador suma unidades y el total suma subtotales mediante providers derivados. El carrito permanece en memoria entre pantallas. La navegación utiliza `Navigator` y `MaterialPageRoute`.

### Angular

`OrdersService`, registrado con `providedIn: 'root'`, encapsula `HttpClient` y devuelve `Observable<OrdersResponse>`. Consulta `/carts?limit=0` para filtrar el conjunto de pedidos recibido; las interfaces tipan el payload.

`OrdersPageComponent` contiene la consulta, sus estados y el filtro de total mínimo. `toSignal` conecta el Observable con la vista y limpia la suscripción al destruir el componente. `switchMap` reemplaza la consulta vigente al reintentar y `catchError` mantiene disponible el flujo de reintento. Signals y `computed` derivan los pedidos visibles y el detalle seleccionado.

`OrderCardComponent` recibe un pedido mediante un input y comunica la selección mediante un output. Los componentes usan `OnPush` y el template usa `@if` / `@for` con seguimiento por ID.

### Paralelos Flutter / Angular

| Flutter | Angular |
|---|---|
| Repositorio inyectado mediante Provider | Servicio inyectado mediante DI |
| Provider / AsyncValue | Signal / Observable y estado tipado |
| Widget de presentación con parámetros y callbacks | Componente con inputs y outputs |
| ref.watch y providers derivados | Lectura de Signals y computed |
| ProviderScope con overrides | TestBed con providers sustituidos |

## Alcance y pendientes

Se implementaron los requisitos obligatorios de aplicación, pruebas y respuestas de la prueba técnica. El listado Flutter carga inicialmente 20 productos; la búsqueda utiliza el endpoint remoto.

El carrito se pierde al reiniciar la app. No se implementaron paginación, filtros por categoría, persistencia, tema oscuro configurable, un modelo Failure/Result ni generación de código. Tampoco se añadieron pruebas de integración ni CI.

La validación ejecutada cubre análisis, pruebas automatizadas, compilación web de Flutter, build Angular y recorridos en navegador con la API real. No se validó ejecución nativa Android/iOS.

## Mejoras con más tiempo

- Persistir el carrito y añadir paginación.
- Incorporar timeouts, cancelación HTTP y errores tipados, junto con validación de payload en Angular.
- Representar importes en unidades mínimas y definir moneda/localización explícitas.
- Ampliar accesibilidad, pruebas de integración y cobertura en dispositivos; automatizar las comprobaciones en CI.
