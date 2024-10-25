
-- Migracion

create procedure jafo.migracion_rubro
as 
begin
	begin try
	begin transaction
		insert into jafo.rubro (descripcion)
			select distinct PRODUCTO_RUBRO_DESCRIPCION 
			from gd_esquema.Maestra 
			where PRODUCTO_RUBRO_DESCRIPCION is not null

		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Rubros: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end


--Subrubro 
insert into jafo.subrubro (descripcion, rubro_codigo)
	select distinct PRODUCTO_SUB_RUBRO, jafo.rubro.codigo
	from gd_esquema.Maestra
	LEFT JOIN jafo.rubro on PRODUCTO_RUBRO_DESCRIPCION = jafo.rubro.descripcion
	where PRODUCTO_SUB_RUBRO is not null

--Provincia

INSERT INTO jafo.provincia (nombre)
SELECT DISTINCT M.CLI_USUARIO_DOMICILIO_PROVINCIA
FROM gd_esquema.Maestra M
WHERE M.CLI_USUARIO_DOMICILIO_PROVINCIA IS NOT NULL

--Localidad
INSERT INTO jafo.localidad (nombre, provincia_codigo)
	(
		SELECT DISTINCT M.CLI_USUARIO_DOMICILIO_LOCALIDAD, jafo.provincia.codigo 
		FROM gd_esquema.Maestra M
		INNER JOIN jafo.provincia ON M.CLI_USUARIO_DOMICILIO_PROVINCIA = jafo.provincia.nombre

		UNION

		SELECT DISTINCT M.VEN_USUARIO_DOMICILIO_LOCALIDAD, jafo.provincia.codigo 
		FROM gd_esquema.Maestra M
		INNER JOIN jafo.provincia ON M.VEN_USUARIO_DOMICILIO_PROVINCIA = jafo.provincia.nombre

		UNION 

		SELECT DISTINCT M.ALMACEN_Localidad, jafo.provincia.codigo 
		FROM gd_esquema.Maestra M
		INNER JOIN jafo.provincia ON M.ALMACEN_PROVINCIA = jafo.provincia.nombre
	)

--Domicilio
INSERT INTO jafo.domicilio (calle, numero_calle, piso, depto, cp ,localidad_codigo)
	(
		SELECT DISTINCT M.CLI_USUARIO_DOMICILIO_CALLE,
			   M.CLI_USUARIO_DOMICILIO_NRO_CALLE,
			   M.CLI_USUARIO_DOMICILIO_PISO,
			   M.CLI_USUARIO_DOMICILIO_DEPTO,
			   M.CLI_USUARIO_DOMICILIO_CP,
			   jafo.localidad.codigo
		FROM gd_esquema.Maestra M
		INNER JOIN jafo.localidad ON M.CLI_USUARIO_DOMICILIO_LOCALIDAD = jafo.localidad.nombre
		--where not exists (
		--	select 1 from jafo.domicilio
		--	where calle = M.CLI_USUARIO_DOMICILIO_CALLE 
		--	and numero_calle = M.CLI_USUARIO_DOMICILIO_NRO_CALLE
		--	and cp = M.CLI_USUARIO_DOMICILIO_CP
		--)
		--hacer esto esta mal porque estas filtrando por las que no están en jafo.domicilio
		-- ¿de que nos sirve eso? Haciendo eso podriamos tenes dos registros identicos
		-- usando distinct o agrupando por todas las columnas nos aseguramos de solo traer direcciones unicas sin repetidos
		-- ese where serviria en caso de que estemos haciendo una migracion y ya tengamos datos en nuestro jafo.domicilio

	UNION

	SELECT DISTINCT M.VEN_USUARIO_DOMICILIO_CALLE,
		   M.VEN_USUARIO_DOMICILIO_NRO_CALLE,
		   M.VEN_USUARIO_DOMICILIO_PISO,
		   M.VEN_USUARIO_DOMICILIO_DEPTO,
		   M.VEN_USUARIO_DOMICILIO_CP,
		   jafo.localidad.codigo
	FROM gd_esquema.Maestra M
	INNER JOIN jafo.localidad ON M.VEN_USUARIO_DOMICILIO_LOCALIDAD = jafo.localidad.nombre
	--where not exists (
	--	select 1 from jafo.domicilio
	--	where calle = M.VEN_USUARIO_DOMICILIO_CALLE 
	--	and numero_calle = M.VEN_USUARIO_DOMICILIO_NRO_CALLE
	--	and cp = M.VEN_USUARIO_DOMICILIO_CP
	--	)

	UNION 

	SELECT DISTINCT M.ALMACEN_CALLE,
		   M.ALMACEN_NRO_CALLE,
		   null,
		   null,
		   null,
		   jafo.localidad.codigo
	FROM gd_esquema.Maestra M
	INNER JOIN jafo.localidad ON M.ALMACEN_Localidad = jafo.localidad.nombre
	--where not exists (
	--	select 1 from jafo.domicilio
	--	where calle = M.ALMACEN_CALLE 
	--	and numero_calle = M.ALMACEN_NRO_CALLE
	--	)
	)


--Almacen
INSERT INTO jafo.almacen (codigo, domicilio_codigo, costo_dia_alquiler)
	SELECT DISTINCT M.ALMACEN_CODIGO, 
			    jafo.domicilio.codigo domicilio_codigo,
				M.ALMACEN_COSTO_DIA_AL
	FROM gd_esquema.Maestra M
	INNER JOIN jafo.domicilio  ON calle = M.ALMACEN_CALLE and numero_calle = M.ALMACEN_NRO_CALLE


--Marca
INSERT INTO jafo.marca (nombre)
SELECT DISTINCT M.PRODUCTO_MARCA
FROM gd_esquema.Maestra M
WHERE M.PRODUCTO_MARCA IS NOT NULL;

INSERT INTO jafo.modelo (codigo, descripcion, marca_codigo)
SELECT DISTINCT M.PRODUCTO_MOD_CODIGO, 
                M.PRODUCTO_MOD_DESCRIPCION, 
                marca.codigo
FROM gd_esquema.Maestra M
INNER JOIN jafo.marca marca
    ON M.PRODUCTO_MARCA = marca.nombre
WHERE M.PRODUCTO_MOD_CODIGO IS NOT NULL
  AND M.PRODUCTO_MOD_DESCRIPCION IS NOT NULL;


INSERT INTO jafo.usuario (nombre, pass, fecha_creacion)
(
SELECT DISTINCT M.VEN_USUARIO_NOMBRE, 
                M.VEN_USUARIO_PASS, 
                M.VEN_USUARIO_FECHA_CREACION
FROM gd_esquema.Maestra M
WHERE M.VEN_USUARIO_NOMBRE IS NOT NULL
  AND M.VEN_USUARIO_PASS IS NOT NULL
  AND M.VEN_USUARIO_FECHA_CREACION IS NOT NULL
)
UNION
(
SELECT DISTINCT M.CLI_USUARIO_NOMBRE, 
                M.CLI_USUARIO_PASS, 
                M.CLI_USUARIO_FECHA_CREACION
FROM gd_esquema.Maestra M
WHERE M.CLI_USUARIO_NOMBRE IS NOT NULL
  AND M.CLI_USUARIO_PASS IS NOT NULL
  AND M.CLI_USUARIO_FECHA_CREACION IS NOT NULL
)

INSERT INTO jafo.cliente (usuario_codigo, nombre, apellido, fecha_nacimiento, mail, dni)
SELECT DISTINCT U.codigo, 
                M.CLIENTE_NOMBRE, 
                M.CLIENTE_APELLIDO, 
                M.CLIENTE_FECHA_NAC, 
                M.CLIENTE_MAIL, 
                M.CLIENTE_DNI
FROM gd_esquema.Maestra M
INNER JOIN jafo.usuario U
    ON M.CLI_USUARIO_NOMBRE = U.nombre
    AND M.CLI_USUARIO_PASS = U.pass
    AND M.CLI_USUARIO_FECHA_CREACION = U.fecha_creacion
WHERE M.CLIENTE_NOMBRE IS NOT NULL
  AND M.CLIENTE_APELLIDO IS NOT NULL
  AND M.CLIENTE_FECHA_NAC IS NOT NULL
  AND M.CLIENTE_MAIL IS NOT NULL
  AND M.CLIENTE_DNI IS NOT NULL

INSERT INTO jafo.vendedor (usuario_codigo, razon_social, cuit, mail)
SELECT DISTINCT U.codigo, 
                M.VENDEDOR_RAZON_SOCIAL, 
                M.VENDEDOR_CUIT, 
                M.VENDEDOR_MAIL
FROM gd_esquema.Maestra M
INNER JOIN jafo.usuario U
    ON M.VEN_USUARIO_NOMBRE = U.nombre
    AND M.VEN_USUARIO_PASS = U.pass
    AND M.VEN_USUARIO_FECHA_CREACION = U.fecha_creacion
WHERE M.VENDEDOR_RAZON_SOCIAL IS NOT NULL
  AND M.VENDEDOR_CUIT IS NOT NULL
  AND M.VENDEDOR_MAIL IS NOT NULL

INSERT INTO jafo.usuario_domicilio (usuario_codigo, domicilio_codigo)
SELECT u.codigo AS usuario_codigo, d.codigo AS domicilio_codigo
FROM gd_esquema.Maestra M
INNER JOIN jafo.usuario u
    ON (u.nombre = M.VEN_USUARIO_NOMBRE OR u.nombre = M.CLI_USUARIO_NOMBRE)
INNER JOIN jafo.domicilio d
    ON (d.calle = M.VEN_USUARIO_DOMICILIO_CALLE AND d.numero_calle = M.VEN_USUARIO_DOMICILIO_NRO_CALLE AND d.cp = M.VEN_USUARIO_DOMICILIO_CP)
   OR (d.calle = M.CLI_USUARIO_DOMICILIO_CALLE AND d.numero_calle = M.CLI_USUARIO_DOMICILIO_NRO_CALLE AND d.cp = M.CLI_USUARIO_DOMICILIO_CP)
WHERE NOT EXISTS (
    SELECT 1 
    FROM jafo.usuario_domicilio ud
    WHERE ud.usuario_codigo = u.codigo AND ud.domicilio_codigo = d.codigo
)