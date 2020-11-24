USE [GD2C2020]
GO

IF OBJECT_ID('LOS_GEDDES.Bi_Estadisticas_clientes', 'U') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_Estadisticas_clientes

IF OBJECT_ID('LOS_GEDDES.Bi_Operaciones_automoviles', 'U') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_Operaciones_automoviles

IF OBJECT_ID('LOS_GEDDES.Bi_Operaciones_autopartes', 'U') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_Operaciones_autopartes

IF OBJECT_ID('LOS_GEDDES.Bi_Instantes', 'U') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_Instantes

IF OBJECT_ID('LOS_GEDDES.Bi_rangos_edades', 'U') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_rangos_edades

IF OBJECT_ID('LOS_GEDDES.Bi_rangos_potencias', 'U') IS NOT NULL
	DROP TABLE LOS_GEDDES.Bi_rangos_potencias

IF OBJECT_ID('LOS_GEDDES.Compraventa_mensual_automoviles', 'V') IS NOT NULL
	DROP VIEW LOS_GEDDES.Compraventa_mensual_automoviles

IF OBJECT_ID('LOS_GEDDES.Precio_promedio_automoviles', 'V') IS NOT NULL
	DROP VIEW LOS_GEDDES.Precio_promedio_automoviles

IF OBJECT_ID('LOS_GEDDES.Ganancias_mensuales_automoviles', 'V') IS NOT NULL
	DROP VIEW LOS_GEDDES.Ganancias_mensuales_automoviles

IF OBJECT_ID('LOS_GEDDES.Tiempo_promedio_en_stock_automoviles', 'V') IS NOT NULL
	DROP VIEW LOS_GEDDES.Tiempo_promedio_en_stock_automoviles

IF OBJECT_ID('LOS_GEDDES.ganancias_mensuales_autopartes', 'V') IS NOT NULL
	DROP VIEW LOS_GEDDES.ganancias_mensuales_autopartes

IF OBJECT_ID('LOS_GEDDES.Maxima_cantidad_stock_por_sucursal', 'V') IS NOT NULL
	DROP VIEW LOS_GEDDES.Maxima_cantidad_stock_por_sucursal

IF OBJECT_ID('LOS_GEDDES.Precio_promedio_autopartes', 'V') IS NOT NULL
	DROP VIEW LOS_GEDDES.Precio_promedio_autopartes

IF OBJECT_ID('LOS_GEDDES.instante_actual_en_meses') IS NOT NULL
	DROP FUNCTION LOS_GEDDES.instante_actual_en_meses

IF OBJECT_ID('LOS_GEDDES.instante_en_meses') IS NOT NULL
	DROP FUNCTION LOS_GEDDES.instante_en_meses

--Creacion de dimensiones
CREATE TABLE LOS_GEDDES.Bi_Instantes(
  inst_id	bigint IDENTITY(1,1),
  inst_mes  tinyint,
  inst_anio smallint

  Constraint pk_instantes PRIMARY KEY(inst_id)
);

CREATE TABLE LOS_GEDDES.Bi_rangos_potencias(
  rgpo_id  bigint,
  rgpo_min decimal(18,0),
  rgpo_max decimal(18,0)

  Constraint pk_rgpo PRIMARY KEY(rgpo_id)
);

CREATE TABLE LOS_GEDDES.Bi_rangos_edades(
  rged_id  bigint,
  rged_min smallint,
  rged_max smallint

  Constraint pk_rged PRIMARY KEY(rged_id)
)
--Creacion de tablas de hechos
CREATE TABLE LOS_GEDDES.Bi_Estadisticas_clientes(
  ecli_id		bigint IDENTITY(1,1),
  ecli_instante bigint,
  ecli_sucursal bigint,
  ecli_sexo		char(1),
  ecli_rg_edad	bigint,
  ecli_cantidad bigint,

  Constraint pk_estad_clientes PRIMARY KEY(ecli_id     ),
  Constraint fk_ecli_inst	   FOREIGN KEY(ecli_instante) REFERENCES  LOS_GEDDES.Bi_Instantes(inst_id),
  Constraint fk_ecli_sucu	   FOREIGN KEY(ecli_sucursal) REFERENCES  LOS_GEDDES.Sucursales(sucu_id),
  Constraint fk_ecli_edad	   FOREIGN KEY(ecli_rg_edad ) REFERENCES  LOS_GEDDES.Bi_rangos_edades(rged_id)
);

CREATE TABLE LOS_GEDDES.Bi_Operaciones_automoviles(
  opau_id			   bigint IDENTITY(1,1),
  opau_auto			   bigint,
  opau_modelo		   decimal(18,0),
  opau_rg_potencia	   bigint,
  opau_instante_compra bigint,
  opau_sucursal_compra bigint,
  opau_precio_compra   decimal(18,2),
  opau_instante_venta  bigint,
  opau_sucursal_venta  bigint,
  opau_precio_venta    decimal(18,2),
  

  Constraint pk_opau	  PRIMARY KEY(opau_id         ),
--  Constraint fk_opau_inst FOREIGN KEY(opau_instante   ) REFERENCES  LOS_GEDDES.Bi_Instantes(inst_id),
 -- Constraint fk_opau_sucu FOREIGN KEY(opau_sucursal	  ) REFERENCES LOS_GEDDES.Sucursales(sucu_id),
 -- Constraint fk_opau_rgpo FOREIGN KEY(opau_rg_potencia) REFERENCES LOS_GEDDES.Bi_Rangos_potencias(rgpo_id)   
);

CREATE TABLE LOS_GEDDES.Bi_Operaciones_autopartes (
  opap_id			  bigint IDENTITY(1,1),
  opap_instante		  bigint,
  opap_sucursal		  bigint,
  opap_autoparte	  decimal(18,0),
  opap_rubro	      bigint,
  opap_fabricante	  bigint,
  opap_cant_comprada  decimal(18,0),
  opap_costo_unitario decimal(18,2),
  opap_cant_vendida   decimal(18,0),
  opap_precio_venta   decimal(18,2),
  opap_stock		  bigint

  Constraint pk_opap	  PRIMARY KEY(opap_id        ),
  Constraint fk_opap_inst FOREIGN KEY(opap_instante  ) REFERENCES LOS_GEDDES.Bi_Instantes(inst_id),
  Constraint fk_opap_sucu FOREIGN KEY(opap_sucursal	 ) REFERENCES LOS_GEDDES.Sucursales(sucu_id),
  Constraint fk_opap_apte FOREIGN KEY(opap_autoparte ) REFERENCES LOS_GEDDES.Autopartes(apte_codigo),
  Constraint fk_opap_cate FOREIGN KEY(opap_rubro     ) REFERENCES LOS_GEDDES.Categorias_autopartes(cate_codigo),   
  Constraint fk_opap_fabr FOREIGN KEY(opap_fabricante) REFERENCES LOS_GEDDES.Fabricantes(fabr_id)
 );
go

--Creacion de indices
create index indx_items_factura_factura_numero
	ON LOS_GEDDES.Items_por_factura(ipfa_factura_numero)

create index indx_items_factura_id_autoparte
	ON LOS_GEDDES.Items_por_factura(ipfa_id_autoparte)

create index indx_items_compra_id_autoparte_cpra
	ON LOS_GEDDES.Items_por_compra(ipco_id_autoparte,ipco_id_compra)

create index indx_facturas_sucursal
	ON LOS_GEDDES.Facturas(fact_sucursal)

create index indx_compras_sucursal
	ON LOS_GEDDES.Compras(cpra_sucursal)
go

--Creacion de funciones
CREATE FUNCTION LOS_GEDDES.edad_en_el_anio(@fechaNacimiento datetime2(3), @unAnio bigint) RETURNS bigint
	AS BEGIN return @unAnio-YEAR(@fechaNacimiento) END
go

CREATE FUNCTION LOS_GEDDES.rango_edad(@edad bigint) RETURNS bigint AS 
	BEGIN
		DECLARE @rg_edad_18_30   bigint = 1 --CUANDO hagamos procedure, se lo pasamos como argumento
		DECLARE @rg_edad_31_50   bigint = 2 
		DECLARE @rg_edad_mayor50 bigint = 3 

		return CASE
			when @edad BETWEEN 18 and 30 then @rg_edad_18_30 
			when @edad BETWEEN 31 and 50 then @rg_edad_31_50
			when @edad > 50 then @rg_edad_mayor50
			else 0
		END
	END
go

CREATE FUNCTION LOS_GEDDES.rg_edad_en_el_anio(@fechaNacimiento datetime2(3), @unAnio bigint) RETURNS bigint AS 
	BEGIN
		return LOS_GEDDES.rango_edad(LOS_GEDDES.edad_en_el_anio(@fechaNacimiento, @unAnio))
	END
go

CREATE FUNCTION LOS_GEDDES.rango_potencia(@potencia decimal(18,0)) RETURNS bigint AS
	BEGIN
		DECLARE @rg_menor   bigint = 1
		DECLARE @rg_medio   bigint = 2 
		DECLARE @rg_mayor   bigint = 3 

		return CASE
			when @potencia BETWEEN 50 and 150 then @rg_menor 
			when @potencia BETWEEN 151 and 300 then @rg_medio
			when @potencia > 300 then @rg_mayor
			else 0
	END
END
go

CREATE FUNCTION LOS_GEDDES.instante_en_meses(@mes bigint, @anio bigint) returns bigint as
	BEGIN
		return @mes + @anio*12
	END
;
go

CREATE FUNCTION LOS_GEDDES.instante_actual_en_meses() returns bigint AS
	BEGIN
		declare @fecha_actual datetime = getdate();
		return LOS_GEDDES.instante_en_meses(month(@fecha_actual), year(@fecha_actual));
	END;
go

create function LOS_GEDDES.calcular_stock(@instante bigint,    @autoparte bigint, @sucursal bigint)
returns bigint AS
    BEGIN
        DECLARE @anio bigint,@mes bigint;

        select top 1 @anio = inst_anio, @mes = inst_mes from LOS_GEDDES.Bi_Instantes where inst_id = @instante;

        return (
            select ISNULL(sum(ipco_cantidad),0)
                from LOS_GEDDES.Compras
                JOIN LOS_GEDDES.Items_por_compra ON
                    cpra_numero = ipco_id_compra
                where cpra_sucursal = @sucursal
					and ipco_id_autoparte = @autoparte
					and (
                        YEAR(cpra_fecha)< @anio
                        or
                        (YEAR(cpra_fecha) = @anio and MONTH(cpra_fecha) < @mes)
					)
            ) - (
			select ISNULL(sum(ipfa_cantidad),0)
				from LOS_GEDDES.Facturas 
				JOIN LOS_GEDDES.Items_por_factura ON
					ipfa_factura_numero = fact_numero
				where ipfa_id_autoparte = @autoparte
					and fact_sucursal = @sucursal
					and (
						YEAR(fact_fecha)< @anio
						or
						(YEAR(fact_fecha) = @anio and MONTH(fact_fecha) < @mes)
				)
		);
    END
go

--Creacion de vistas
CREATE VIEW LOS_GEDDES.Compraventa_mensual_automoviles AS
(
	select inst_anio as Anio, inst_mes as Mes, ciud_nombre as Ciudad, sucu_direccion as Sucursal, count(*) as Cantidad_comprada
		,  (
			select count(*)
				from LOS_GEDDES.Bi_Operaciones_automoviles opv
				where opv.opau_sucursal_venta is not null
					and opv.opau_sucursal_venta=opc.opau_sucursal_compra
					and opv.opau_instante_venta=opc.opau_instante_compra
		) as Cantidad_vendida
		from LOS_GEDDES.Bi_Operaciones_automoviles opc
		join LOS_GEDDES.Bi_Instantes on
			inst_id=opau_instante_compra
		join LOS_GEDDES.Sucursales on
			sucu_id=opau_sucursal_compra
		join LOS_GEDDES.Ciudades on
			ciud_id=sucu_ciudad
		group by inst_anio, inst_mes, ciud_nombre, sucu_direccion, opau_sucursal_compra, opau_instante_compra
);
go

CREATE VIEW LOS_GEDDES.Precio_promedio_automoviles AS
(
	select inst_anio as Anio, inst_mes as Mes, ciud_nombre as Ciudad, sucu_direccion as Sucursal
		, cast(avg(opau_precio_compra) as decimal(18,2)) as Precio_promedio_compra
		, (
			select cast(avg(ov.opau_precio_venta) as decimal(18,2))
				from LOS_GEDDES.Bi_Operaciones_automoviles ov
				where ov.opau_instante_venta is not null
					and ov.opau_instante_venta=oc.opau_instante_compra
					and ov.opau_sucursal_venta=oc.opau_sucursal_compra
		) as promedio_precio_venta
		from LOS_GEDDES.Bi_Operaciones_automoviles oc
		join LOS_GEDDES.Bi_Instantes on
			inst_id=opau_instante_compra
		join LOS_GEDDES.Sucursales
			on sucu_id=opau_sucursal_compra
		join LOS_GEDDES.Ciudades
			on ciud_id=sucu_ciudad
		group by inst_anio, inst_mes, opau_sucursal_compra, opau_instante_compra, ciud_nombre, sucu_direccion
);
go

CREATE VIEW LOS_GEDDES.Ganancias_mensuales_automoviles AS
(
	select inst_anio as Anio, inst_mes as Mes, ciud_nombre as Ciudad, sucu_direccion as Sucursal, sum(opau_precio_venta-opau_precio_compra) as Ganancia
		from LOS_GEDDES.Bi_Operaciones_automoviles
		join LOS_GEDDES.Bi_Instantes on
			inst_id=opau_instante_venta
		join LOS_GEDDES.Sucursales on
			sucu_id=opau_sucursal_venta
		join LOS_GEDDES.Ciudades on
			ciud_id=sucu_ciudad
		where opau_instante_venta is not null
		group by inst_anio, inst_mes, sucu_direccion, ciud_nombre
);
go

CREATE VIEW LOS_GEDDES.Tiempo_promedio_en_stock_automoviles AS
(
	select opau_modelo as Modelo, (
			avg(iif(opau_instante_venta is null
					, LOS_GEDDES.instante_actual_en_meses()
					, LOS_GEDDES.instante_en_meses(fecha_venta.inst_mes, fecha_venta.inst_anio)
				) - LOS_GEDDES.instante_en_meses(fecha_compra.inst_mes, fecha_compra.inst_anio)
			)
		) as promedio_en_stock

		from LOS_GEDDES.Bi_Operaciones_automoviles
		join LOS_GEDDES.bi_instantes fecha_compra on
			fecha_compra.inst_id=opau_instante_compra
		left join LOS_GEDDES.bi_instantes fecha_venta on
			fecha_venta.inst_id=opau_instante_venta
		group by opau_modelo 
);
go

CREATE VIEW LOS_GEDDES.Precio_promedio_autopartes as
(
	Select opap_autoparte as Autoparte, avg(opap_precio_venta) as Precio_promedio_venta, avg(opap_costo_unitario) as Precio_promedio_compra
		from LOS_GEDDES.Bi_Operaciones_autopartes
		group by opap_autoparte
);
go

CREATE VIEW LOS_GEDDES.ganancias_mensuales_autopartes AS
(
	SELECT inst_anio as anio, inst_mes as mes, sucu_ciudad as sucursal_ciudad, sucu_direccion as sucursal_direccion,
		sum((opap_precio_venta - opap_costo_unitario )* opap_cant_vendida) as ganancia
	FROM LOS_GEDDES.Bi_Operaciones_autopartes 
	JOIN LOS_GEDDES.Bi_Instantes ON inst_id = opap_instante
	JOIN LOS_GEDDES.Sucursales ON sucu_id = opap_sucursal
	GROUP BY inst_anio,inst_mes,sucu_ciudad,sucu_direccion
);
go

CREATE VIEW LOS_GEDDES.Maxima_cantidad_stock_por_sucursal as
	select opap_sucursal as Sucursal, inst_anio as Año, max(stock_instantaneo) as Maximo_stock  
	from (
		select opap_instante, opap_sucursal, sum(opap_stock) as stock_instantaneo
			from LOS_GEDDES.Bi_Operaciones_autopartes
			group by opap_instante, opap_sucursal
	) as stock_mensual
	join LOS_GEDDES.Bi_Instantes on
		inst_id=opap_instante
	group by opap_sucursal, inst_anio
go

--Migracion del modelo
print '>> Rangos potencias'
INSERT INTO LOS_GEDDES.Bi_rangos_potencias(rgpo_id, rgpo_min, rgpo_max)
	Values (1, 50,150), (2, 151, 300), (3, 301, null)
;

print '
>> Rangos edades'
INSERT INTO LOS_GEDDES.Bi_rangos_edades(rged_id, rged_min, rged_max)
	Values (0, 0, 17), (1, 18, 30), (2, 31, 50), (3, 51, null)
;
go

create table #operaciones(
	compra		 decimal(18,0),
	venta		 decimal(18,0),
	sucursal	 bigint,
	anio		 bigint,
	mes			 bigint,
	cliente		 bigint,
	automovil	 bigint,
	modelo		 decimal(18,0),
	precio_total decimal(18,2),
)

print '
>> tabla temporal de Operaciones de compraventa'
insert into #Operaciones
(compra, venta, sucursal, anio, mes, cliente, automovil, modelo, precio_total)
( 
	select cpra_numero, null, cpra_sucursal, year(cpra_fecha), MONTH(cpra_fecha), cpra_cliente, auto_id, auto_modelo, cpra_precio_total
		from LOS_GEDDES.Compras
		left join LOS_GEDDES.Automoviles
			on auto_id=cpra_automovil

	UNION ALL

	select null, fact_numero, fact_sucursal, year(fact_fecha), MONTH(fact_fecha), fact_cliente, auto_id, auto_modelo, fact_precio 
		from LOS_GEDDES.Facturas
		left join LOS_GEDDES.Automoviles
			on auto_id=fact_automovil
);

print '
>> Instantes de tiempo'
insert into LOS_GEDDES.Bi_Instantes(inst_mes, inst_anio)
	select distinct mes, anio from #operaciones
		order by anio, mes
;

print '
>> estadisticas clientes'
INSERT INTO LOS_GEDDES.Bi_Estadisticas_clientes
(ecli_instante, ecli_sucursal, ecli_sexo, ecli_rg_edad, ecli_cantidad)
(
	Select distinct inst_id, sucursal, clie_sexo, rg_edad, count(*)
		from (
			select *, LOS_GEDDES.rg_edad_en_el_anio(clie_fecha_nac, anio) as rg_edad 
				from LOS_GEDDES.Clientes 
				join #Operaciones
					on clie_id=cliente
		) as Clientes
		
		join LOS_GEDDES.Bi_Instantes
			on inst_mes = mes
			and inst_anio=anio
		group by sucursal, inst_id, rg_edad, clie_sexo
);

print '
>> operaciones de automoviles

	* Compras'
 insert into LOS_GEDDES.Bi_Operaciones_automoviles
 (opau_auto, opau_modelo, opau_rg_potencia, opau_instante_compra, opau_sucursal_compra, opau_precio_compra)
 (
	select automovil, modelo, LOS_GEDDES.rango_potencia(mode_potencia), inst_id, sucursal, precio_total from #operaciones
		join LOS_GEDDES.Bi_instantes
				on inst_anio=anio
				and inst_mes=mes
		join LOS_GEDDES.Modelos_automoviles
			on mode_codigo=modelo
		where modelo is not null		
 );
go

print '
	* Ventas'
 update LOS_GEDDES.Bi_Operaciones_automoviles
	set opau_instante_venta=inst_id,
		opau_sucursal_venta=sucursal,
		opau_precio_venta=precio_total
	from #operaciones
	join LOS_GEDDES.bi_instantes on
		inst_anio=anio
		and inst_mes=mes
	where venta is not null
		and automovil=opau_auto

print '
>> Operaciones de autopartes'
insert into LOS_GEDDES.Bi_Operaciones_autopartes
(opap_instante, opap_sucursal, opap_autoparte, opap_rubro, opap_fabricante, opap_cant_comprada, opap_costo_unitario, opap_precio_venta
, opap_cant_vendida  , opap_stock)
(
	select inst_id, sucursal, autoparte, null as rubro, null as fabricante
	, isnull(sum(cantidad_comprada), 0) as cantidad_comprada
	, max(costo_unitario), max(precio_venta)
	, isnull(sum(cantidad_vendida), 0) as cant_vendida, null as stock

		from (
				select anio, mes, sucursal, ipco_id_autoparte as autoparte, ipco_cantidad as cantidad_comprada, 0 as cantidad_vendida, ipco_precio as costo_unitario, 0 as precio_venta
					from #Operaciones
					join LOS_GEDDES.Items_por_compra
						on ipco_id_compra=compra
					
				union all

				select anio, mes, sucursal, ipfa_id_autoparte as autoparte, 0 as cantidad_comprada, ipfa_cantidad as cantidad_vendida,0 as costo_unitario, ipfa_precio_facturado as precio_venta
					from #Operaciones
					join LOS_GEDDES.Items_por_factura
						on ipfa_factura_numero=venta
					
		) as Operaciones_autopartes

		join LOS_GEDDES.Bi_Instantes
			on inst_anio=anio
			and inst_mes=mes

		group by inst_id, sucursal, autoparte
);
go
print'
	* Fabricantes y rubros'

update LOS_GEDDES.Bi_Operaciones_autopartes
	set opap_rubro = apte_categoria
	  , opap_fabricante = apte_fabricante
	
	from LOS_GEDDES.Autopartes
	where apte_codigo=opap_autoparte
;
go

print '
	* Calculo de Stock'
update LOS_GEDDES.Bi_Operaciones_autopartes
	set opap_stock = LOS_GEDDES.calcular_stock(opap_instante,opap_autoparte,opap_sucursal)
go

drop table #operaciones
drop function LOS_GEDDES.edad_en_el_anio
drop function LOS_GEDDES.rango_edad
drop function LOS_GEDDES.rg_edad_en_el_anio
drop function LOS_GEDDES.rango_potencia
drop function LOS_GEDDES.calcular_stock
drop index LOS_GEDDES.Items_por_factura.indx_items_factura_factura_numero
drop index LOS_GEDDES.Items_por_factura.indx_items_factura_id_autoparte 
drop index LOS_GEDDES.Items_por_compra.indx_items_compra_id_autoparte_cpra
drop index LOS_GEDDES.Facturas.indx_facturas_sucursal
drop index LOS_GEDDES.Compras.indx_compras_sucursal
go
