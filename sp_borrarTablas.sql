create procedure jafo.borrarTablas
as 
begin
	DROP TABLE jafo.usuario_domicilio
	DROP TABLE jafo.detalle_factura
	DROP TABLE jafo.detalle_venta
	DROP TABLE jafo.publicacion
	DROP TABLE jafo.producto
	DROP TABLE jafo.pago
	DROP TABLE jafo.medio_pago
	DROP TABLE jafo.modelo
	DROP TABLE jafo.marca
	DROP TABLE jafo.almacen
	DROP TABLE jafo.envio
	DROP TABLE jafo.domicilio
	DROP TABLE jafo.localidad
	DROP TABLE jafo.provincia
	DROP TABLE jafo.venta
	DROP TABLE jafo.cliente
	DROP TABLE jafo.factura
	DROP TABLE jafo.subrubro
	DROP TABLE jafo.rubro
	DROP TABLE jafo.tipo_envio
	DROP TABLE jafo.tipo_medio_pago
	DROP TABLE jafo.vendedor
	DROP TABLE jafo.usuario
	DROP TABLE jafo.concepto

end