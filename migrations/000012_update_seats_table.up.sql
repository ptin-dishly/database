-- Cambiamos el nombre de la columna para identificar asientos por el nombre del comensal
ALTER TABLE seats RENAME COLUMN seat_number TO comensal_name;

-- Cambiamos el tipo a VARCHAR para permitir texto
ALTER TABLE seats ALTER COLUMN comensal_name TYPE VARCHAR;