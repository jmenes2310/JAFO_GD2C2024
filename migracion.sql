
-- Migracion

create procedure jafo.migracion_rubro
as 
begin
	begin try
	begin transaction
		insert into jafo.rubro (codigo)
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


INSERT INTO jafo.provincia (nombre)
SELECT DISTINCT M.CLI_USUARIO_DOMICILIO_PROVINCIA
FROM gd_esquema.Maestra M
WHERE M.CLI_USUARIO_DOMICILIO_PROVINCIA IS NOT NULL

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


INSERT INTO jafo.domicilio (calle, numero_calle, piso, depto, cp ,localidad_codigo)
	(
		SELECT M.CLI_USUARIO_DOMICILIO_CALLE,
			   M.CLI_USUARIO_DOMICILIO_NRO_CALLE,
			   M.CLI_USUARIO_DOMICILIO_PISO,
			   M.CLI_USUARIO_DOMICILIO_DEPTO,
			   M.CLI_USUARIO_DOMICILIO_CP,
			   jafo.localidad.codigo
		FROM gd_esquema.Maestra M
		INNER JOIN jafo.localidad ON M.CLI_USUARIO_DOMICILIO_LOCALIDAD = jafo.localidad.nombre
		where not exists (
			select 1 from jafo.domicilio
			where calle = M.CLI_USUARIO_DOMICILIO_CALLE 
			and numero_calle = M.CLI_USUARIO_DOMICILIO_NRO_CALLE
			and cp = M.CLI_USUARIO_DOMICILIO_CP
		)
	UNION

	SELECT M.VEN_USUARIO_DOMICILIO_CALLE,
		   M.VEN_USUARIO_DOMICILIO_NRO_CALLE,
		   M.VEN_USUARIO_DOMICILIO_PISO,
		   M.VEN_USUARIO_DOMICILIO_DEPTO,
		   M.VEN_USUARIO_DOMICILIO_CP,
		   jafo.localidad.codigo
	FROM gd_esquema.Maestra M
	INNER JOIN jafo.localidad ON M.VEN_USUARIO_DOMICILIO_LOCALIDAD = jafo.localidad.nombre
	where not exists (
		select 1 from jafo.domicilio
		where calle = M.VEN_USUARIO_DOMICILIO_CALLE 
		and numero_calle = M.VEN_USUARIO_DOMICILIO_NRO_CALLE
		and cp = M.VEN_USUARIO_DOMICILIO_CP
		)
	UNION 

	SELECT M.ALMACEN_CALLE,
		   M.ALMACEN_NRO_CALLE,
		   null,
		   null,
		   null,
		   jafo.localidad.codigo
	FROM gd_esquema.Maestra M
	INNER JOIN jafo.localidad ON M.ALMACEN_Localidad = jafo.localidad.nombre
	where not exists (
		select 1 from jafo.domicilio
		where calle = M.ALMACEN_CALLE 
		and numero_calle = M.ALMACEN_NRO_CALLE
		)
	)

INSERT INTO jafo.almacen (codigo, domicilio_codigo, costo_dia_alquiler)
	SELECT DISTINCT M.ALMACEN_CODIGO, 
			    jafo.domicilio.codigo,
				M.ALMACEN_COSTO_DIA_AL
	FROM gd_esquema.Maestra M
	INNER JOIN jafo.domicilio  ON calle = M.ALMACEN_CALLE and numero_calle = M.ALMACEN_NRO_CALLE

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