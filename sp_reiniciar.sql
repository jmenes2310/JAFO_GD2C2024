create procedure jafo.reiniciar
as 
begin
	exec jafo.borrarTablas
	exec jafo.CrearTablas
end