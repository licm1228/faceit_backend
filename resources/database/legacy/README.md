# Legacy SQL Snapshots

This directory stores historical PostgreSQL dump snapshots that are kept only for reference.

- `ragent2.root.sql`: an older root-level export moved here to avoid polluting the repository root.

Use these files only for manual inspection or historical comparison.
For local PostgreSQL bootstrap, use:

- `resources/database/schema_pg.sql`
- `resources/database/init_data_pg.sql`
- `resources/database/upgrade_interview_schema.sql`
- `resources/database/init_interview_data.sql`
