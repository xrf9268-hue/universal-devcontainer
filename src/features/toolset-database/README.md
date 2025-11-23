# Database Tools Feature

CLI tools with autocomplete for working with popular databases.

## Tools Included

- **pgcli** - PostgreSQL CLI with autocomplete and syntax highlighting
- **mycli** - MySQL/MariaDB CLI with autocomplete
- **redis-cli** - Redis command-line interface
- **mongosh** - MongoDB Shell (opt-in)
- **litecli** - SQLite CLI with autocomplete (opt-in)

## Usage

### Default (PostgreSQL, MySQL, Redis)
```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/toolset-database:1": {}
  }
}
```

### With MongoDB
```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/toolset-database:1": {
      "installMongosh": true
    }
  }
}
```

### Custom Selection
```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/toolset-database:1": {
      "installPgcli": true,
      "installMycli": false,
      "installRedisCli": true,
      "installMongosh": true,
      "installLitecli": true
    }
  }
}
```

## Tool Usage

### pgcli
```bash
pgcli postgresql://user:pass@localhost:5432/dbname
pgcli -h localhost -U postgres -d mydb
```

### mycli
```bash
mycli -h localhost -u root -p password mydatabase
mycli mysql://user:pass@localhost:3306/db
```

### redis-cli
```bash
redis-cli
redis-cli -h localhost -p 6379
redis-cli PING
```

### mongosh
```bash
mongosh
mongosh "mongodb://localhost:27017"
```

### litecli
```bash
litecli database.db
litecli --help
```
