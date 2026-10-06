# Respuestas de la prueba técnica

## Parte 1 — Preguntas conceptuales

### Dart y Flutter

#### 1. ¿Qué diferencia hay entre final y const en Dart? ¿Por qué importa usar const en constructores de widgets?

`final` permite asignar una variable una sola vez, incluso con un valor obtenido en ejecución. `const` exige un valor conocido al compilar. Un constructor `const` permite reutilizar instancias de widgets con argumentos constantes y evitar trabajo innecesario al actualizar el árbol. No garantiza que el widget nunca se reconstruya por cambios en sus dependencias. Una referencia `final` tampoco hace inmutable una colección por sí sola.

#### 2. Explica el null safety de Dart. ¿Cuándo usarías ?, !, ?? y late? ¿Por qué abusar de ! es una mala práctica?

Los tipos son no anulables por defecto; `String?` admite `null`. `??` aporta un valor alternativo, como `query ?? ''`. `!` afirma que un valor no es nulo y falla si la afirmación es falsa. `late` permite inicializar después de declarar, pero leer antes de inicializar también falla. Prefiero comprobar o modelar la ausencia; abusar de `!` elimina la protección del compilador.

#### 3. ¿Cuál es la diferencia entre StatelessWidget y StatefulWidget? ¿Qué aportan ConsumerWidget y ConsumerStatefulWidget?

`StatelessWidget` describe la UI sin un objeto `State` propio; puede reconstruirse al cambiar parámetros o dependencias. `StatefulWidget` conserva un `State` para manejar ciclo de vida y estado local, como un controlador de texto. `ConsumerWidget` añade acceso a `WidgetRef`; `ConsumerStatefulWidget` lo combina con `State`. Los consumidores observan Riverpod sin guardar otra copia del estado de negocio.

#### 4. ¿Qué es un Future y qué es un Stream? Da un caso de uso real de cada uno.

Un `Future<T>` termina una vez con un resultado o error, como obtener un producto por ID. Un `Stream<T>` puede emitir múltiples eventos, como ubicaciones GPS o mensajes de un socket. Las consultas HTTP del catálogo devuelven `Future` y `FutureProvider` expone sus resultados como `AsyncValue`. Los streams necesitan gestionar suscripciones y ciclo de vida.

#### 5. ¿Por qué es preferible extraer un widget a una clase propia en lugar de un método _buildAlgo() que retorna un Widget?

Una clase de widget crea una unidad reutilizable, comprobable y que puede ser `const`. Aporta una frontera independiente para actualizar el árbol y aparece claramente en las herramientas de inspección. Un método ejecuta su contenido cuando el padre lo llama y no crea por sí mismo esa frontera. `ProductTile` concentra la presentación sin ejecutar HTTP ni modificar el carrito.

### Riverpod

#### 6. ¿Qué problema resuelve Riverpod frente a setState o frente a Provider (el paquete)?

`setState` administra estado local de un widget; compartirlo e inyectar dependencias requiere trabajo adicional. Riverpod ofrece un contenedor, estados derivados, gestión del ciclo de vida y overrides para tests. Frente al paquete Provider, sus providers se identifican mediante referencias explícitas y pueden consumirse sin `BuildContext`, desde otro provider o un `ProviderContainer`.

#### 7. Explica la diferencia entre ref.watch, ref.read y ref.listen. ¿Dónde es incorrecto usar ref.read?

`watch` observa y actualiza al consumidor; lo uso en `build` para productos y contador. `read` obtiene el valor sin suscribirse; lo uso en callbacks para acciones del carrito y búsqueda. `listen` observa transiciones para efectos como una notificación, aunque esta app no lo necesita. Usar `read` para pintar un valor que debe actualizarse es incorrecto: el widget no queda suscrito.

#### 8. ¿Cuándo usarías un Provider, un FutureProvider, un Notifier y un AsyncNotifier?

`Provider` expone dependencias o valores derivados, como `productRepositoryProvider`. `FutureProvider` administra consultas, como `productsProvider` y `productDetailsProvider`. `Notifier` encapsula acciones que publican nuevo estado síncrono, como `CartNotifier` y `SearchQueryNotifier`. Usaría `AsyncNotifier` para estado asíncrono con operaciones imperativas propias, como cargar y guardar una entidad; el catálogo no lo necesita.

#### 9. ¿Qué hace el modificador autoDispose y qué problema evita? ¿Y family?

`autoDispose` permite liberar el estado cuando deja de tener consumidores y ejecutar `ref.onDispose`. Evita conservar consultas sin uso; el notifier de búsqueda cancela su timer al desecharse. `family` crea estados independientes por argumento: `productDetailsProvider(id)` carga ese producto. Desechar un provider no cancela automáticamente HTTP: la cancelación del transporte debe implementarse si se necesita.

#### 10. ¿Cómo manejas los estados de carga, error y datos con AsyncValue? Escribe un ejemplo con .when o pattern matching.

`AsyncValue<T>` representa carga, error o datos. Uso `when` para elegir la UI y distingo datos vacíos de una lista con productos. Reintentar invalida el provider y vuelve a consultar. `skipLoadingOnRefresh: false` muestra carga durante ese reintento.

```dart
final products = ref.watch(productsProvider);
return products.when(
  skipLoadingOnRefresh: false,
  loading: () => const CircularProgressIndicator(),
  error: (error, stackTrace) => FilledButton(
    onPressed: () => ref.invalidate(productsProvider),
    child: const Text('Reintentar'),
  ),
  data: (items) => Text(
    items.isEmpty ? 'No hay productos' : '${items.length} productos',
  ),
);
```

#### 11. ¿Cómo sobrescribirías un provider en un test para inyectar un repositorio falso?

`FakeProductRepository` implementa el contrato y devuelve resultados o errores controlados. Sobrescribo `productRepositoryProvider` para evitar HTTP. Uso `ProviderContainer` para providers y `ProviderScope` para widgets. Este ejemplo va dentro de un test, importando el fake de `test/support/fake_product_repository.dart`; la suscripción mantiene activo el provider autoDispose mientras espero su resultado.

```dart
final fakeRepository = FakeProductRepository();
final container = ProviderContainer(
  overrides: [
    productRepositoryProvider.overrideWithValue(fakeRepository),
  ],
);
addTearDown(container.dispose);
final subscription = container.listen(productsProvider, (_, _) {});
addTearDown(subscription.close);
final products = await container.read(productsProvider.future);
expect(products, fakeRepository.products);
```

### Angular

#### 12. ¿Qué diferencia hay entre un componente standalone y uno declarado en un NgModule?

Standalone declara sus dependencias en `imports` y puede utilizarse o cargarse sin declararlo en un `NgModule`. En una app con módulos, el módulo declara componentes y organiza imports y exports. Standalone hace visibles las dependencias de cada componente y simplifica su composición. Ambos enfoques pueden convivir.

#### 13. Explica la diferencia entre un Observable (RxJS) y un Signal. ¿Cuándo preferirías cada uno?

Un Observable representa una secuencia recibida mediante suscripción y admite `map`, `switchMap` y `catchError`. Un Signal mantiene un valor actual leído síncronamente y permite derivaciones con `computed`. `OrdersService` usa Observable para HTTP; `OrdersPageComponent` usa Signals para el filtro y `computed` para los pedidos visibles. `toSignal` conecta la consulta con la vista y administra su limpieza.

#### 14. ¿Para qué sirven @Input() / input() y @Output() / output()? ¿Cómo se comunican dos componentes hermanos?

Los inputs transmiten datos del padre al hijo y los outputs comunican eventos en sentido contrario. `OrderCardComponent` recibe `order` mediante `input.required<Order>()` y emite el ID con `viewDetail`, declarado con `output<number>()`. Dos hermanos pueden comunicarse mediante el padre, que recibe el evento y actualiza los datos del otro hijo, o mediante un servicio compartido si necesitan un ámbito mayor.

#### 15. ¿Qué es la inyección de dependencias en Angular y para qué sirve providedIn: 'root'?

Angular obtiene colaboradores desde sus inyectores, evitando construir servicios manualmente en cada componente. `providedIn: 'root'` registra el servicio en el inyector raíz y normalmente comparte una instancia en ese ámbito, salvo overrides en inyectores inferiores. `OrdersService` recibe HttpClient con `inject(HttpClient)` y expone pedidos tipados. Los tests sustituyen el transporte con `provideHttpClientTesting()`.

#### 16. ¿Por qué hay que preocuparse por las suscripciones a Observables? Menciona dos formas de evitar fugas de memoria.

Una fuente duradera puede seguir haciendo trabajo después de destruir el componente. `async` pipe se suscribe y se libera automáticamente; `takeUntilDestroyed` termina la suscripción al destruir su contexto. `toSignal` también administra la limpieza en su contexto. Aunque HTTP normalmente completa, timers y streams continuos necesitan gestionar su finalización.

### Código limpio y buenas prácticas

#### 17. Explica con tus palabras el principio de responsabilidad única (SRP) y cómo lo aplicarías en una app Flutter.

Una clase se concentra en una responsabilidad y tiene una razón coherente para cambiar. El datasource cambia por HTTP y JSON, el repositorio por la forma de ofrecer datos y `CartNotifier` por las reglas del carrito. Los widgets cambian por presentación y eventos de usuario. Así puedo modificar y probar una responsabilidad sin mezclarla con las demás.

#### 18. ¿Por qué separar la app en capas (presentación, dominio, datos)? ¿Qué va en cada una?

Presentación contiene pantallas, widgets y providers. Dominio define `Product`, `CartItem` y `ProductRepository`; datos implementa HTTP, parseo y ese contrato. Puedo probar presentación con un fake y cambiar el origen sin convertir widgets en clientes HTTP. `Product.fromJson` es una simplificación explícita que vincula la entidad con JSON.

#### 19. ¿Qué diferencia hay entre una prueba unitaria, una de widget y una de integración?

Una unitaria comprueba una regla aislada, como cantidades y total del carrito. Una de widget monta parte de Flutter y comprueba UI y eventos con resultados controlados por un fake. Una de integración recorre partes trabajando juntas, como buscar, abrir detalle y agregar. Las pruebas con fake no demuestran disponibilidad de la API ni ejecución en dispositivo real.

#### 20. Menciona tres convenciones que sigues al hacer commits y abrir un pull request.

Uso Conventional Commits con mensajes que describen un incremento concreto. Mantengo commits pequeños y coherentes, sin mezclar cambios ajenos. Antes de abrir un PR reviso el diff y ejecuto las comprobaciones relevantes; su descripción explica comportamiento, validaciones y limitaciones. El historial conserva la evolución real de la solución.

## Parte 4 — Code review

### Fragmento A — Flutter / Riverpod

| Problema | Por qué importa | Cómo lo corregiría |
|---|---|---|
| HTTP dentro de `build` | Cada rebuild vuelve a consultar; la respuesta llama a `setState` y puede provocar un ciclo de peticiones. | Consulta desde `productsProvider`, mediante repositorio inyectado. |
| Estado de negocio local y `setState` desde un Future | Duplica estado y la respuesta puede llegar después de destruir el widget. | Observar `AsyncValue` con `ConsumerWidget`. |
| HTTP y JSON en UI | Mezcla presentación, transporte y parseo y dificulta pruebas. | Datasource HTTP y repositorio tipado. |
| `List` y `Map` sin tipos | El compilador no comprueba campos y los errores aparecen tarde. | `Product` inmutable con `fromJson` y `List<CartItem>`. |
| Sin validar HTTP ni manejar errores | Red, códigos de error o JSON inválido pueden dejar carga infinita. | Validación en datos y estado de error con retry en UI. |
| `ref.read(cartProvider)` en build | El contador no observa cambios del carrito. | `ref.watch(cartCountProvider)`. |
| `.add` sobre la lista almacenada | Muta estado compartido sin publicar lista nueva ni notificar de forma fiable. | Acción `cartProvider.notifier.add(product)` que crea estado inmutable nuevo. |
| `StateProvider<List<Map>>` para reglas de carrito | Expone mutaciones sin controlar cantidades; en Riverpod 3 es API legacy. | `NotifierProvider<CartNotifier, List<CartItem>>` con acciones explícitas. |
| Loading fuera de Scaffold y sin vacío | Desaparece la estructura de pantalla y la lista vacía carece de explicación. | Mantener Scaffold y resolver carga, error, vacío y datos en el body. |
| Lista completa con `map().toList()` | Construye widgets que pueden no ser visibles. | `ListView.builder`. |
| Sin constructor const ni componentes pequeños | Reduce reutilización y actualización independiente. | Constructor const y widgets de presentación extraídos. |
| Precio concatenado sin formato | Puede mostrar decimales inconsistentes. | Formato uniforme de importe. |
| `print('agregado')` | Añade ruido de depuración. | Eliminarlo. |

### Reescritura del fragmento Flutter

Este ejemplo se ubicaría en `flutter_app/lib/products_screen.dart`. Reutiliza los providers implementados: `productsProvider` consulta y gestiona `AsyncValue`, `cartCountProvider` suma cantidades y `CartNotifier` actualiza una lista inmutable de `CartItem`. El repositorio y datasource validan HTTP y convierten JSON. La entrada de la app ya proporciona `ProviderScope`; aquí se conserva la acción de agregar del fragmento revisado.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/cart/presentation/providers/cart_provider.dart';
import 'features/products/domain/entities/product.dart';
import 'features/products/presentation/providers/products_provider.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final count = ref.watch(cartCountProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Productos ($count)')),
      body: products.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se pudieron cargar los productos'),
              FilledButton(
                onPressed: () => ref.invalidate(productsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No hay productos disponibles'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              return ProductAddTile(
                product: product,
                onAdd: () => ref.read(cartProvider.notifier).add(product),
              );
            },
          );
        },
      ),
    );
  }
}

class ProductAddTile extends StatelessWidget {
  const ProductAddTile({
    required this.product,
    required this.onAdd,
    super.key,
  });

  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(product.title),
    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
    trailing: IconButton(
      tooltip: 'Agregar al carrito',
      onPressed: onAdd,
      icon: const Icon(Icons.add_shopping_cart),
    ),
  );
}
```

### Fragmento B — Angular

| Problema | Por qué importa | Cómo lo corregiría |
|---|---|---|
| `orders: any` y respuesta any | Impide comprobar el payload y la lista carece de valor inicial explícito. | Interfaces `Order` y `OrdersResponse`, con lista inicial o estado tipado. |
| HttpClient en componente | Mezcla transporte y presentación y dificulta pruebas. | `OrdersService` con `providedIn: 'root'` y HTTP tipado. |
| `setInterval` sin limpieza | Sigue lanzando requests después de destruir el componente. | Eliminar polling si no se necesita; si es necesario, timer RxJS con teardown. |
| Requests independientes en cada tick | Se pueden solapar y una respuesta vieja sustituir datos recientes. | `switchMap` para conservar la consulta vigente si existe polling. |
| Primera carga tras cinco segundos | Muestra una pantalla sin datos antes de consultar. | Carga inmediata o `timer(0, intervalo)` si se justifica polling. |
| Sin carga ni error | No distingue una petición pendiente de datos vacíos ni explica fallos. | Estado de carga, datos y error con retry. |
| `*ngFor` sin imports standalone | La directiva no está disponible sólo por escribirla en el template. | Importar NgFor/CommonModule o usar `@for`. |
| Sin identificación estable | Puede recrear DOM innecesariamente al sustituir pedidos. | `@for (order of orders; track order.id)` o trackBy. |
| Suscripción manual sin ciclo de vida explícito | Facilita olvidar teardown de fuentes duraderas o requests activas. | Async pipe, toSignal o takeUntilDestroyed. |
| Intervalo mágico y polling sin motivo | Ejecuta trabajo continuo sin una necesidad justificada. | Cargar una vez o definir y justificar el intervalo de refresco. |

HttpClient normalmente completa después de responder; no toda suscripción HTTP finita implica una fuga permanente. El problema inequívoco aquí es el intervalo sin limpiar, que conserva trabajo tras destruir el componente. Si se mantiene polling, también hay que gestionar requests activas y errores para que un fallo no termine el flujo de refresco.
