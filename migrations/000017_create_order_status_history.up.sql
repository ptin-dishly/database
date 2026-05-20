-- ============================================================================
-- Migration 000016 — Order Status History and Trigger
-- ============================================================================

-- 1. Create table to store the status history
CREATE TABLE IF NOT EXISTS order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    old_status order_status,
    new_status order_status NOT NULL,
    changed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Create the trigger function
CREATE OR REPLACE FUNCTION log_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo insertar en el historial si el status ha cambiado, o si es un nuevo pedido
    IF TG_OP = 'INSERT' THEN
        INSERT INTO order_status_history (order_id, old_status, new_status, changed_at)
        VALUES (NEW.id, NULL, NEW.status, CURRENT_TIMESTAMP);
    ELSIF TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO order_status_history (order_id, old_status, new_status, changed_at)
        VALUES (NEW.id, OLD.status, NEW.status, CURRENT_TIMESTAMP);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Create the trigger on the orders table
DROP TRIGGER IF EXISTS trigger_log_order_status_change ON orders;
CREATE TRIGGER trigger_log_order_status_change
AFTER INSERT OR UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION log_order_status_change();

-- 4. Create an analytical view to calculate the average time spent in each stage
-- Esto calcula la diferencia en minutos entre el inicio de un estado y el inicio del siguiente estado
CREATE OR REPLACE VIEW view_orders_stage_times AS
WITH status_durations AS (
    SELECT 
        order_id,
        new_status as status,
        changed_at as start_time,
        LEAD(changed_at) OVER (PARTITION BY order_id ORDER BY changed_at) as end_time
    FROM order_status_history
)
SELECT 
    status,
    ROUND(AVG(EXTRACT(EPOCH FROM (end_time - start_time)) / 60)) as avg_minutes
FROM status_durations
WHERE end_time IS NOT NULL
GROUP BY status;

-- 5. Grant permissions to web_anon so the dashboard can read it
GRANT SELECT ON view_orders_stage_times TO web_anon;
