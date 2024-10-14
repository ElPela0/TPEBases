--1a
ALTER TABLE persona
 ADD CONSTRAINT ri_fechabaja CHECK ((activo = TRUE) OR (activo = FALSE AND fecha_baja >= fecha_alta + INTERVAL '6 months'));
--1b
CREATE OR REPLACE FUNCTION FN_Chequear_Importes()
    RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM comprobante c JOIN lineacomprobante l
        ON c.id_comp = l.id_comp AND c.id_tcomp = l.id_tcomp
        GROUP BY c.id_comp, c.id_tcomp, c.importe
        HAVING c.importe != SUM(l.importe)
    )THEN
        RAISE EXCEPTION 'El sistema no permite la modificación de los importes ya que no se corresponderían con sus líneas';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER TR_LINEACOMPROBANTE_CHK --funciona
    AFTER INSERT OR UPDATE OR DELETE ON lineacomprobante
    FOR EACH STATEMENT EXECUTE FUNCTION FN_Chequear_Importes();


CREATE OR REPLACE TRIGGER TR_COMPROBANTE_CHK
    AFTER UPDATE ON comprobante
    FOR EACH STATEMENT EXECUTE FUNCTION FN_Chequear_Importes();

CREATE OR REPLACE FUNCTION FN_Chequear_Insert_Comprobante()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.importe != 0
        THEN RAISE EXCEPTION 'No se pueden agregar comprobantes los cuales el importe inicial no sea 0';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER TR_CHK_insert_Comprobante
    AFTER INSERT ON comprobante
    FOR EACH ROW EXECUTE FUNCTION FN_Chequear_Insert_Comprobante();
/*
CREATE ASSERTION total_importe
CHECK (NOT EXISTS (SELECT 1
                    FROM comprobante c JOIN lineacomprobante l
                    ON c.id_comp = l.id_comp AND c.id_tcomp = l.id_tcomp)
                    GROUP BY c.id_comp,c.id_tcomp
                    HAVING c.importe != COUNT(l.importe))
 */
 