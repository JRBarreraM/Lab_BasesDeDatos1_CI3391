--¿Cuántos empleados deben llegar los jueves en el transporte universitario
-- a cada hora de cada departamento?
SELECT departamento.nombre_departamento, jueves.nombre_horas_estandar,
(COUNT(*)) * (SELECT COUNT(*) FROM personal) * 1/100
FROM personal
INNER JOIN departamento ON personal.departamento = departamento.id_departamento
INNER JOIN censo ON censo.documento_identidad_personal = personal.documento_identidad_personal
INNER JOIN medio_transporte ON censo.medio_transporte = medio_transporte.id_medio_transporte
INNER JOIN horas_estandar as jueves ON censo.hora_jueves = jueves.id_horas_estandar
WHERE medio_transporte.nombre_medio_transporte = 'Transporte Universitario' AND jueves.nombre_horas_estandar <> 'NR'
GROUP BY departamento.nombre_departamento, jueves.nombre_horas_estandar;