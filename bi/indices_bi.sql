------------------------------ INDICES -----------------------------
-- Para hechos publicacion
create index idx_publicacion_producto_fecha_codigo ON jafo.publicacion (producto_id, fecha_inicio, codigo);

create index idx_producto_id_subrubro_marca ON jafo.producto (id, subrubro_codigo, marca_codigo);

-- para hechos ventas
create index idx_venta_codigo_cliente_fecha ON jafo.venta (codigo, cliente_codigo, fecha, total);
create index idx_envio_venta_fecha_domicilio ON jafo.envio (venta_codigo, fecha_entrega, domicilio_codigo);
create index idx_cliente_codigo_fecha_nacimiento ON jafo.cliente (codigo, fecha_nacimiento);
create index idx_detalle_venta_codigo_publicacion ON jafo.detalle_venta (venta_codigo, publicacion_codigo);
create index idx_subrubro_codigo_rubro ON jafo.subrubro (codigo, rubro_codigo);

create index idx_domicilio_codigo_localidad ON jafo.domicilio (codigo, localidad_codigo);
create index idx_localidad_codigo_provincia_nombre ON jafo.localidad (codigo, provincia_codigo, nombre);
create index idx_provincia_codigo_nombre ON jafo.provincia (codigo, nombre);
create index idx_ubicacion_localidad_provincia ON jafo.bi_dim_ubicacion (localidad, provincia);

-- para hechos pagos
CREATE INDEX idx_pago_medio_pago_fecha_cuotas ON jafo.pago (medio_pago_codigo, fecha, cantidad_cuotas);

CREATE INDEX idx_medio_pago_id ON jafo.bi_dim_medio_pago (id_medio_pago);

CREATE INDEX idx_cantidad_cuotas_cantidad ON jafo.bi_dim_cantidad_cuotas (cantidad);

CREATE INDEX idx_tiempo_fecha ON jafo.bi_dim_tiempo (id_tiempo);


--DROP INDEX jafo.idx_publicacion_producto_fecha_codigo;

--DROP INDEX jafo.idx_producto_id_subrubro_marca;

--DROP INDEX jafo.venta.idx_venta_codigo_cliente_fecha;

--DROP INDEX jafo.envio.idx_envio_venta_fecha_domicilio;

--DROP INDEX jafo.cliente.idx_cliente_codigo_fecha_nacimiento;

--DROP INDEX jafo.detalle_venta.idx_detalle_venta_codigo_publicacion;

--DROP INDEX jafo.subrubro.idx_subrubro_codigo_rubro;

--DROP INDEX jafo.domicilio.idx_domicilio_codigo_localidad;

--DROP INDEX jafo.localidad.idx_localidad_codigo_provincia_nombre;

--DROP INDEX jafo.provincia.idx_provincia_codigo_nombre;

--DROP INDEX jafo.bi_dim_ubicacion.idx_ubicacion_localidad_provincia;

--DROP INDEX jafo.pago.idx_pago_medio_pago_fecha_cuotas;

--DROP INDEX jafo.bi_dim_medio_pago.idx_medio_pago_id;

--DROP INDEX jafo.bi_dim_cantidad_cuotas.idx_cantidad_cuotas_cantidad;

--DROP INDEX jafo.bi_dim_tiempo.idx_tiempo_fecha;
