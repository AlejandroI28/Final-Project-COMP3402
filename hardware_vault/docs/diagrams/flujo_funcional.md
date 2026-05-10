# Diagrama de Flujo Funcional — Hardware Vault

Representa el recorrido principal del usuario al utilizar la aplicación.

```mermaid
flowchart TD
    Start([Usuario abre la app]) --> Splash[Splash Screen<br/>~1.4s fade-in]
    Splash --> Main[MainShell<br/>BottomNavigationBar]

    Main --> Tab1[Catalog<br/>tab izquierdo]
    Main --> Tab2[News<br/>tab central — default]
    Main --> Tab3[My PC<br/>tab derecho]

    %% Catalog flow
    Tab1 --> Empty1[Empty state:<br/>Press search to begin]
    Empty1 --> Filters[Usuario configura filtros<br/>Type / Brand / Series<br/>+ search query]
    Filters --> SearchBtn{Presiona<br/>botón Search?}
    SearchBtn -- No --> Empty1
    SearchBtn -- Sí --> Results[Lista filtrada de<br/>CPUs y/o GPUs]
    Results --> Detail[PartDetailScreen<br/>specs + benchmark]
    Results --> Clear{Presiona Clear?}
    Clear -- Sí --> Empty1

    %% News flow
    Tab2 --> NewsList[Lista de noticias<br/>featured + cards]
    NewsList --> NewsSearch[Filtra por<br/>search bar]
    NewsSearch --> NewsList

    %% My PC flow
    Tab3 --> Builds{¿Hay builds<br/>guardados?}
    Builds -- No --> EmptyBuilds[Empty state +<br/>botón New Build]
    Builds -- Sí --> BuildList[Lista de builds]
    EmptyBuilds --> Editor[BuildEditor<br/>BottomSheet]
    BuildList --> Editor
    BuildList --> DeleteDialog[Confirm Delete<br/>Dialog]
    Editor --> Save[Save → SQLite<br/>upsert pc_builds]
    Save --> BuildList
    DeleteDialog -- Confirma --> DeleteDB[DELETE FROM<br/>pc_builds WHERE id=?]
    DeleteDB --> Builds
```

**Notas funcionales clave:**

- El catálogo arranca en estado vacío y solo muestra resultados al presionar Search (botón verde) o Enter en el TextField.
- El botón Clear (X) solo aparece cuando hay algún filtro activo o texto en la búsqueda.
- News carga 8 artículos mock con imágenes temáticas de Unsplash.
- My PC persiste cada build en una tabla SQLite (`pc_builds`) usando `sqflite`.
