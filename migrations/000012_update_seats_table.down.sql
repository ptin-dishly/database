-- Revertimos los cambios a la estructura original
ALTER TABLE seats RENAME COLUMN comensal_name TO seat_number;

-- Intentamos convertir a INTEGER (esto fallará si hay nombres, por eso usamos NULL en caso de error)
ALTER TABLE seats ALTER COLUMN seat_number TYPE INTEGER USING (NULL);