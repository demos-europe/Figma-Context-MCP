# Docker Setup für Figma-Context-MCP

## Übersicht

Der Figma-Context-MCP Server wurde für den Betrieb in Docker-Containern erweitert. Der Server läuft standardmäßig im HTTP-Modus und stellt REST-API-Endpunkte zur Verfügung.

## Container-Build

### Voraussetzungen

1. Docker installiert
2. Figma API-Token (Personal Access Token)

### Build-Prozess

```bash
# Container bauen (lokal)
docker build -t figma-mcp .

# Oder DockerHub Image verwenden (empfohlen)
docker pull demosdeutschland/figma-mcp:latest
```

## Container-Ausführung

### Mit Environment-Variablen

```bash
docker run -d \
  --name figma-mcp \
  -p 3000:3000 \
  -e FIGMA_API_KEY=your_figma_api_token_here \
  -e NODE_ENV=production \
  demosdeutschland/figma-mcp:latest
```

### Mit .env-Datei

```bash
# .env-Datei erstellen (basierend auf .env.example)
cp .env.example .env
# .env bearbeiten und FIGMA_API_KEY setzen

# Container mit .env-Datei starten
docker run -d \
  --name figma-mcp \
  -p 3000:3000 \
  --env-file .env \
  demosdeutschland/figma-mcp:latest
```

### Mit Volume-Mounting für Konfiguration

```bash
docker run -d \
  --name figma-mcp \
  -p 3000:3000 \
  -v $(pwd)/config:/usr/src/app/config:ro \
  -v $(pwd)/logs:/usr/src/app/logs \
  -e FIGMA_API_KEY=your_figma_api_token_here \
  demosdeutschland/figma-mcp:latest
```

## Environment-Variablen

| Variable | Beschreibung | Default | Erforderlich |
|----------|--------------|---------|--------------|
| `FIGMA_API_KEY` | Figma Personal Access Token | - | Ja |
| `FIGMA_OAUTH_TOKEN` | OAuth Bearer Token (Alternative zu API Key) | - | Nein |
| `PORT` | Server-Port | 3000 | Nein |
| `OUTPUT_FORMAT` | Ausgabeformat (yaml/json) | yaml | Nein |
| `SKIP_IMAGE_DOWNLOADS` | Deaktiviert Bild-Downloads | false | Nein |
| `NODE_ENV` | Node.js Environment | production | Nein |

## API-Endpunkte

Nach dem Start ist der Server unter folgenden Endpunkten verfügbar:

- **Health Check**: `GET http://localhost:3000/`
- **Streamable HTTP**: `POST http://localhost:3000/mcp`
- **Server-Sent Events**: `GET http://localhost:3000/sse`
- **Messages**: `POST http://localhost:3000/messages`

## Health Check

Der Container verfügt über integrierte Health Checks:

```bash
# Health Check manuell prüfen
docker exec figma-mcp wget --no-verbose --tries=1 --spider http://localhost:3000/

# Container-Status prüfen
docker ps
# Sollte "healthy" in der STATUS-Spalte anzeigen
```

## Logs und Debugging

```bash
# Container-Logs anzeigen
docker logs figma-mcp

# Live-Logs verfolgen
docker logs -f figma-mcp

# In Container einsteigen (für Debugging)
docker exec -it figma-mcp sh
```

## Troubleshooting

### Container startet nicht

1. Prüfen Sie die Logs: `docker logs figma-mcp`
2. Stellen Sie sicher, dass Port 3000 verfügbar ist
3. Verifizieren Sie den FIGMA_API_KEY

### Health Check schlägt fehl

1. Container läuft möglicherweise noch nicht vollständig
2. Port 3000 ist blockiert
3. Server-Startfehler (siehe Logs)

### API-Verbindungsfehler

1. Prüfen Sie die Figma API-Token-Gültigkeit
2. Netzwerkverbindung zum Container testen
3. Firewall-Einstellungen prüfen

## Integration mit MCP-Clients

Der Container kann direkt über HTTP-Clients angesprochen werden:

```bash
# Test der MCP-Tools
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -H "mcp-session-id: test-session" \
  -d '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{}},"id":1}'
```

## Sicherheit

- Container läuft als Non-Root-User (`figma:1001`)
- Sensitive Daten werden über Environment-Variablen injiziert
- Keine Secrets im Container-Image gespeichert
- Alpine Linux für minimale Angriffsfläche

## Performance

- Multi-Stage Build für optimierte Image-Größe
- Production-Dependencies only
- Node.js 18 Alpine für beste Performance
- Health Checks für Container-Monitoring