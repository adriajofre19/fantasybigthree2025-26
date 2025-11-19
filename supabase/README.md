# Migracions de Supabase

Aquest directori conté les migracions SQL per a la base de dades Supabase.

## Executar les migracions

Per crear la taula `players` i configurar les polítiques RLS a la teva base de dades Supabase:

1. Accedeix al teu projecte Supabase
2. Ves a **SQL Editor**
3. Crea una nova query
4. Executa el fitxer complet:
   - `000_complete_setup.sql` - **RECOMANAT**: Executa totes les migracions d'una vegada
   
   O executa els fitxers individuals en aquest ordre:
   - `001_create_players_table.sql` - Crea la taula players
   - `002_add_players_insert_update_policies.sql` - Afegeix les polítiques d'INSERT i UPDATE
   - `003_add_player_photo_url.sql` - Afegeix el camp photo_url per les fotos dels jugadors
   - `004_create_user_players_table.sql` - Crea la taula user_players per gestionar compres/ventes de jugadors
   - `005_create_player_stats_table.sql` - Crea la taula player_stats per emmagatzemar estadístiques diàries
   - `006_create_user_player_points_function.sql` - Crea funcions per calcular punts acumulats
   - `007_insert_sample_players.sql` - (Opcional) Insereix jugadors de mostra per desenvolupament
   - `008_add_is_starter_to_user_players.sql` - Afegeix el camp is_starter per indicar titulars/suplents

**IMPORTANT**: Si tens problemes executant les migracions individuals, usa `000_complete_setup.sql` que conté tot en un únic fitxer.

Alternativament, si tens el CLI de Supabase instal·lat:

```bash
supabase db push
```

### Solució d'errors RLS

Si obtens l'error "new row violates row-level security policy", tens dues opcions:

**Opció 1 (Recomanada)**: Executa la migració `002_add_players_insert_update_policies.sql` que afegeix les polítiques necessàries per INSERT i UPDATE.

**Opció 2**: Afegeix la clau de servei (Service Role Key) de Supabase a les teves variables d'entorn com `SUPABASE_SERVICE_ROLE_KEY`. Això permetrà que l'endpoint de sincronització bypassi RLS. **ATENCIÓ**: Aquesta clau ha de mantenir-se secreta i només s'ha d'utilitzar al servidor, mai al client.

## Estructura de la taula `players`

La taula `players` conté la següent informació:

- `id`: ID únic de la fila (auto-increment)
- `player_id`: ID del jugador a l'API de la NBA
- `full_name`: Nom complet del jugador
- `first_name`: Nom del jugador
- `last_name`: Cognom del jugador
- `team_id`: ID de l'equip
- `team_name`: Nom de l'equip
- `position`: Posició del jugador (obtinguda de l'API de la NBA)
- `photo_url`: URL de la foto oficial del jugador de la NBA
- `is_active`: Si el jugador està actiu
- `season`: Temporada (ex: "2025-26")
- `created_at`: Data de creació
- `updated_at`: Data d'actualització

La combinació de `player_id` i `season` és única per permetre múltiples temporades.

## Estructura de la taula `user_players`

La taula `user_players` gestiona les compres i ventes de jugadors pels usuaris:

- `id`: ID únic de la fila (auto-increment)
- `user_id`: ID de l'usuari (FK a auth.users)
- `player_id`: ID del jugador (FK a players.id)
- `purchase_date`: Data de compra del jugador
- `sale_date`: Data de venda del jugador (NULL si encara el té)
- `total_points`: Punts totals acumulats durant el període de propietat
- `is_active`: Si el jugador està actualment actiu al equip de l'usuari
- `is_starter`: Si el jugador és titular (true) o suplent (false)
- `created_at`: Data de creació
- `updated_at`: Data d'actualització

Els punts es calculen automàticament basant-se en les estadístiques de `player_stats` entre `purchase_date` i `sale_date` (o data actual si encara no s'ha venut).

**Restricció**: Cada usuari pot tenir màxim 5 titulars (`is_starter = true`) actius alhora. Això s'aplica automàticament mitjançant un trigger.

## Estructura de la taula `player_stats`

La taula `player_stats` emmagatzema les estadístiques diàries de cada jugador:

- `id`: ID únic de la fila (auto-increment)
- `player_id`: ID del jugador (FK a players.id)
- `game_date`: Data del partit
- `points`, `rebounds`, `assists`, `steals`, `blocks`, `turnovers`: Estadístiques bàsiques
- `field_goals_made`, `field_goals_attempted`: Tirs de camp
- `three_pointers_made`: Triples encertats
- `free_throws_made`: Tirs lliures encertats
- `minutes_played`: Minuts jugats
- `fantasy_points`: Punts de fantasia calculats automàticament segons el sistema de puntuació
- `season`: Temporada (ex: "2025-26")
- `created_at`, `updated_at`: Dates de creació i actualització

Els `fantasy_points` es calculen automàticament mitjançant un trigger que aplica la fórmula de puntuació definida a la funció `calculate_fantasy_points()`.

## Funcions disponibles

- `calculate_user_player_points(p_user_player_id)`: Calcula els punts totals acumulats per un jugador d'un usuari
- `recalculate_all_user_player_points()`: Recalcula tots els punts de tots els usuaris (útil després de sincronitzar estadístiques)
- `get_user_active_players(p_user_id)`: Retorna tots els jugadors actius d'un usuari amb els seus punts totals

