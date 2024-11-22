-----------------FUCIONES--------------------------------------------------------
go
CREATE FUNCTION jafo.obtener_id_tiempo (@fecha datetime) 
RETURNS varchar(10)								 
AS
BEGIN
	DECLARE @id int;
	
	SELECT @id = id_tiempo
    FROM jafo.bi_dim_tiempo
    WHERE anio = YEAR(@fecha)
      AND mes = MONTH(@fecha)
      AND cuatrimestre = CASE 
                               WHEN MONTH(@fecha) BETWEEN 1 AND 4 THEN 1
                               WHEN MONTH(@fecha) BETWEEN 5 AND 8 THEN 2
                               WHEN MONTH(@fecha) BETWEEN 9 AND 12 THEN 3
                           END;

    RETURN @id;
END

GO

create function jafo.obtener_stock_inicial (@publicacion_codigo decimal(18,0))
returns decimal(18,0)
as
begin
    declare @stock_vendido decimal (18,0)
    declare @stock_actual decimal(18,0)

    set @stock_vendido = (
        select sum(dv.cantidad)
        from publicacion p
        inner join jafo.detalle_venta dv
            on dv.publicacion_codigo = @publicacion_codigo
        group by dv.publicacion_codigo
    )

    set @stock_actual = (select p.stock from publicacion p where p.codigo = @publicacion_codigo)


    return @stock_vendido + @stock_actual
end
go

-- Recibe una edad int y devuelve el id del rango de esa edad
create function jafo.getAgeRange(@age int)
returns int
as
begin
	declare @id int
	if (@age < 24)
		set @id = (select idRangoEtario
		from jafo.bi_dim_rango_etario
		where descripcion_rango = ('< 25'))
	else if (@age < 35)
		set @id = (select idRangoEtario
		from jafo.bi_dim_rango_etario
		where descripcion_rango = ('25-35'))
	else if (@age < 50)
		set @id = (select idRangoEtario
		from jafo.bi_dim_rango_etario
		where descripcion_rango = ('35-50'))
	else
		set @id = (select idRangoEtario
		from jafo.bi_dim_rango_etario
		where descripcion_rango = ('> 50'))
	return @id
end
go


-- Recibe una fecha datetime y devuelve el id del rango horario asociado
create function jafo.getRangoHorarioPorFecha(@fechaHora datetime)
returns int
as
begin
	declare @id int
	if(DATEPART(HOUR,@fechaHora) between 0 and 5) 
		set @id = (select idRangoHorario from jafo.bi_dim_rango_horario where descripcion_rango = ('00:00-06:00'))
	else if(DATEPART(HOUR,@fechaHora) between 6 and 11) 
		set @id = (select idRangoHorario from jafo.bi_dim_rango_horario where descripcion_rango = ('06:00-12:00'))
	else if(DATEPART(HOUR,@fechaHora) between 12 and 17) 
		set @id = (select idRangoHorario from jafo.bi_dim_rango_horario where descripcion_rango = ('12:00-18:00'))
	else 
		set @id = (select idRangoHorario from jafo.bi_dim_rango_horario where descripcion_rango = ('18:00-24:00'))
	return @id
end
go
