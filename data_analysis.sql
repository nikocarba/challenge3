-- Análisis de Gastos
SELECT categoria, format_datetime(fecha_transaccion, 'MMMM') mes, sum(gasto_credito)credito, sum(gasto_debito) debito
FROM "default"."fakebank"
GROUP BY format_datetime(fecha_transaccion, 'MMMM'), categoria
ORDER BY categoria

-- Estado de cuentas mensual
SELECT cliente, format_datetime(fecha_transaccion, 'MMMM') mes, sum(coalesce(gasto_credito, 0)) + sum(coalesce(gasto_debito, 0)) as saldo_total
FROM "default"."fakebank"
GROUP BY cliente, month(fecha_transaccion), format_datetime(fecha_transaccion, 'MMMM')
order by cliente, month(fecha_transaccion)


SELECT cliente, sum(coalesce(gasto_credito, 0)) + sum(coalesce(gasto_debito, 0)) as saldo_total
FROM "default"."fakebank"
GROUP BY cliente
order by cliente

-- Segmentación de Categorías
SELECT 
    cliente,
    format_datetime(fecha_transaccion, 'MMMM') mes,
    sum(coalesce(gasto_credito, 0)) + sum(coalesce(gasto_debito, 0)) as saldo_total,
    CASE 
        WHEN sum(coalesce(gasto_credito, 0)) + sum(coalesce(gasto_debito, 0)) > 100 THEN 'Alto'
        WHEN sum(coalesce(gasto_credito, 0)) + sum(coalesce(gasto_debito, 0)) >= 50 THEN 'Medio'
        WHEN sum(coalesce(gasto_credito, 0)) + sum(coalesce(gasto_debito, 0)) >= 25 THEN 'Bajo'
        WHEN sum(coalesce(gasto_credito, 0)) + sum(coalesce(gasto_debito, 0)) > 0 THEN 'Muy bajo'
    END AS segmentacion
FROM "default"."fakebank"
GROUP BY cliente, month(fecha_transaccion), format_datetime(fecha_transaccion, 'MMMM')
order by cliente, month(fecha_transaccion)