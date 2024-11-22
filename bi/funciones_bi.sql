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
