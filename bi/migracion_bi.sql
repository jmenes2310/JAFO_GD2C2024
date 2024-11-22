-----------------FUCIONES----------------------------

CREATE FUNCTION jafo.obtener_id_tiempo (@fecha datetime) 
RETURNS varchar(10)								 
AS
BEGIN
	DECLARE @id int;
	
	SELECT @id = id
    FROM BI_dim_tiempo 
    WHERE anio = YEAR(@fecha)
      AND mes = MONTH(@fecha)
      AND cuatrimestre = CASE 
                               WHEN MONTH(@fecha) BETWEEN 1 AND 4 THEN 1
                               WHEN MONTH(@fecha) BETWEEN 5 AND 8 THEN 2
                               WHEN MONTH(@fecha) BETWEEN 9 AND 12 THEN 3
                           END;

    RETURN @id;
GO

-----------------TABLAS----------------------------
create table bi_dim_tiempo(
	 id_tiempo int identity(1,1) primary key
	,anio int
	,cuatrimestre int
	,mes int
)


-----------------MIGRACIONES----------------------------
go
create procedure jafo.migracion_provincia
as 
begin
	begin try
	begin transaction
		INSERT INTO jafo.provincia (nombre)
			SELECT DISTINCT fecha_entrega
			FROM javo.
			WHERE M.CLI_USUARIO_DOMICILIO_PROVINCIA IS NOT NULL
		commit transaction
	end try

	begin catch
		rollback transaction
		DECLARE @error nvarchar(max) = CONCAT('Error al migrar Provincia: ', ERROR_MESSAGE())
		RAISERROR(@error,16,1)
	end catch
end
go