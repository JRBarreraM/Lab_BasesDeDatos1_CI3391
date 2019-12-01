--------------------------------------------------------------------------------
--	Jose Barrera, 15-10123
--	Maria Magallanes, 13-10787
--------------------------------------------------------------------------------

--¿Quiénes son los empleados críticos que sabemos necesitan del transporte universitario
-- en cada parada los jueves?
SELECT ruta.nombre_ruta, personal.nacionalidad, personal.documento_identidad_personal
FROM personal
INNER JOIN censo ON censo.documento_identidad_personal = personal.documento_identidad_personal
INNER JOIN horas_estandar as jueves ON censo.hora_jueves = jueves.id_horas_estandar
INNER JOIN ruta ON ruta.id_ruta = censo.ruta
INNER JOIN medio_transporte ON censo.medio_transporte = medio_transporte.id_medio_transporte
WHERE medio_transporte.nombre_medio_transporte = 'Transporte Universitario'
	AND jueves.nombre_horas_estandar <> 'NR'
	AND jueves.nombre_horas_estandar <> 'No uso el transporte USB'
	AND ruta.nombre_ruta <> 'Ruta intraurbana inactiva'
	AND ruta.nombre_ruta <> 'Ruta urbana inactiva'
	AND (personal.documento_identidad_personal IN(
	-- Secretario de cada departamento academico
	SELECT personal.documento_identidad_personal
	FROM personal
	INNER JOIN cargo ON personal.cargo = cargo.id_cargo
	WHERE cargo.nombre_cargo ILIKE 'SECRETARIO%' AND personal.departamento IN (
	  SELECT id_departamento FROM departamento
	  INNER JOIN personal ON personal.departamento = departamento.id_departamento
	  INNER JOIN tipo_personal ON personal.tipo_personal = tipo_personal.id_tipo_personal
	  WHERE tipo_personal.nombre_tipo_personal = 'DOCEN'
	)) OR personal.documento_identidad_personal IN (
	-- Tecnico de cada departamento academico
	SELECT personal.documento_identidad_personal
	FROM personal
	INNER JOIN cargo on personal.cargo = cargo.id_cargo
	WHERE cargo.nombre_cargo ILIKE 'TECNICO DE LABORATORIO%'
	) OR personal.documento_identidad_personal IN (
	-- Asistente de cada departamento academico
	SELECT personal.documento_identidad_personal
	FROM personal
	INNER JOIN cargo ON personal.cargo = cargo.id_cargo
	WHERE cargo.nombre_cargo ILIKE 'ASISTENTE%' AND personal.departamento IN (
	  SELECT id_departamento FROM departamento
	  INNER JOIN personal ON personal.departamento = departamento.id_departamento
	  INNER JOIN tipo_personal ON personal.tipo_personal = tipo_personal.id_tipo_personal
	  WHERE tipo_personal.nombre_tipo_personal = 'DOCEN'
	)) OR personal.documento_identidad_personal IN (
	-- Profesor mas antiguo de cada departamento
	SELECT DISTINCT ON (departamento.id_departamento) personal.documento_identidad_personal
	FROM personal
	INNER JOIN cargo ON personal.cargo = cargo.id_cargo
	INNER JOIN departamento ON personal.departamento = departamento.id_departamento
	WHERE cargo.nombre_cargo ILIKE 'PROFESOR%'
	GROUP BY personal.documento_identidad_personal, departamento.id_departamento, personal.fecha_ingreso_personal
	ORDER BY departamento.id_departamento, personal.fecha_ingreso_personal
	))
GROUP BY ruta.nombre_ruta, personal.nacionalidad, personal.documento_identidad_personal