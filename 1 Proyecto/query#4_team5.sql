--------------------------------------------------------------------------------
--	Jose Barrera, 15-10123
--	Maria Magallanes, 13-10787
--------------------------------------------------------------------------------

--¿Cuántos empleados totales se pueden esperar que usen
-- el transporte universitario ese día?
SELECT ROUND((COUNT(*) +
			(SELECT COUNT(*)
			FROM personal
			INNER JOIN censo ON censo.documento_identidad_personal = personal.documento_identidad_personal
			INNER JOIN medio_transporte ON censo.medio_transporte = medio_transporte.id_medio_transporte
			INNER JOIN horas_estandar as jueves ON censo.hora_jueves = jueves.id_horas_estandar
			WHERE (medio_transporte.nombre_medio_transporte = 'Carro propio' 
			OR medio_transporte.nombre_medio_transporte = 'Cola')
			)
	) * 0.25 / (SELECT COUNT(*) FROM censo) * (SELECT COUNT(*) FROM personal)) AS "# Empleados Totales"
FROM personal
INNER JOIN censo ON censo.documento_identidad_personal = personal.documento_identidad_personal
INNER JOIN medio_transporte ON censo.medio_transporte = medio_transporte.id_medio_transporte
INNER JOIN horas_estandar as jueves ON censo.hora_jueves = jueves.id_horas_estandar
WHERE medio_transporte.nombre_medio_transporte = 'Transporte Universitario'
AND jueves.nombre_horas_estandar <> 'NR'
AND jueves.nombre_horas_estandar <> 'No uso el transporte USB';