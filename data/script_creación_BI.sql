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
  inst_mes  tinyint NOT NULL,
  inst_anio smallint NOT NULL

  Constraint pk_instantes PRIMARY KEY(inst_id)
);

CREATE TABLE LOS_GEDDES.Bi_rangos_potencias(
  rgpo_id  bigint,
  rgpo_min decimal(18,0) NOT NULL,
  rgpo_max decimal(18,0)  

  Constraint pk_rgpo PRIMARY KEY(rgpo_id)
);

CREATE TABLE LOS_GEDDES.Bi_rangos_edades(
  rged_id  bigint,
  rged_min smallint NOT NULL,
  rged_max smallint

  Constraint pk_rged PRIMARY KEY(rged_id)
)
--Creacion de tablas de hechos
CREATE TABLE LOS_GEDDES.Bi_Estadisticas_clientes(
  ecli_id		bigint IDENTITY(1,1),
  ecli_instante bigint NOT NULL,
  ecli_sucursal bigint NOT NULL,
  ecli_sexo		char(1),
  ecli_rg_edad	bigint NOT NULL,
  ecli_cantidad bigint NOT NULL,

  Constraint pk_estad_clientes PRIMARY KEY(ecli_id     ),
  Constraint fk_ecli_inst	   FOREIGN KEY(ecli_instante) REFERENCES  LOS_GEDDES.Bi_Instantes(inst_id),
  Constraint fk_ecli_sucu	   FOREIGN KEY(ecli_sucursal) REFERENCES  LOS_GEDDES.Sucursales(sucu_id),
  Constraint fk_ecli_edad	   FOREIGN KEY(ecli_rg_edad ) REFERENCES  LOS_GEDDES.Bi_rangos_edades(rged_id)
);

CREATE TABLE LOS_GEDDES.Bi_Operaciones_automoviles(
  opau_id			   bigint IDENTITY(1,1),
  opau_auto			   bigint NOT NULL,
  opau_modelo		   decimal(18,0)NOT NULL,
  opau_rg_potencia	   bigint NOT NULL,
  opau_instante_compra bigint NOT NULL,
  opau_sucursal_compra bigint NOT NULL,
  opau_precio_compra   decimal(18,2) NOT NULL,
  opau_instante_venta  bigint,
  opau_sucursal_venta  bigint ,
  opau_precio_venta    decimal(18,2), 
  
  Constraint pk_opau		   PRIMARY KEY(opau_id),
  Constraint fk_opau_auto	   FOREIGN KEY(opau_auto		   ) REFERENCES LOS_GEDDES.Automoviles(auto_id),
  Constraint fk_opau_modelo	   FOREIGN KEY(opau_modelo		   ) REFERENCES LOS_GEDDES.Modelos_automoviles(mode_codigo),
  Constraint fk_opau_rgpo	   FOREIGN KEY(opau_rg_potencia	   ) REFERENCES LOS_GEDDES.Bi_Rangos_potencias(rgpo_id),   
  Constraint fk_opau_cpra_inst FOREIGN KEY(opau_instante_compra) REFERENCES LOS_GEDDES.Bi_Instantes(inst_id),
  Constraint fk_opau_cpra_sucu FOREIGN KEY(opau_sucursal_compra) REFERENCES LOS_GEDDES.Sucursales(sucu_id),
  Constraint fk_opau_vnta_inst FOREIGN KEY(opau_instante_venta ) REFERENCES LOS_GEDDES.Bi_Instantes(inst_id),
  Constraint fk_opau_vnta_sucu FOREIGN KEY(opau_sucursal_venta ) REFERENCES LOS_GEDDES.Sucursales(sucu_id)
);

CREATE TABLE LOS_GEDDES.Bi_Operaciones_autopartes (
  opap_id			  bigint IDENTITY(1,1),
  opap_instante		  bigint NOT NULL,
  opap_sucursal		  bigint NOT NULL,
  opap_autoparte	  decimal(18,0) NOT NULL,
  opap_rubro	      bigint,
  opap_fabricante	  bigint NOT NULL,
  opap_cant_comprada  decimal(18,0) NOT NULL,
  opap_costo_unitario decimal(18,2) NOT NULL,
  opap_cant_vendida   decimal(18,0) NOT NULL,
  opap_precio_venta   decimal(18,2) NOT NULL

  Constraint pk_opap	  PRIMARY KEY(opap_id        ),
  Constraint fk_opap_inst FOREIGN KEY(opap_instante  ) REFERENCES LOS_GEDDES.Bi_Instantes(inst_id),
  Constraint fk_opap_sucu FOREIGN KEY(opap_sucursal	 ) REFERENCES LOS_GEDDES.Sucursales(sucu_id),
  Constraint fk_opap_apte FOREIGN KEY(opap_autoparte ) REFERENCES LOS_GEDDES.Autopartes(apte_codigo),
  Constraint fk_opap_cate FOREIGN KEY(opap_rubro     ) REFERENCES LOS_GEDDES.Categorias_autopartes(cate_codigo),   
  Constraint fk_opap_fabr FOREIGN KEY(opap_fabricante) REFERENCES LOS_GEDDES.Fabricantes(fabr_id)
 );
go

CREATE INDEX indx_items_factura_factura_numero
	ON LOS_GEDDES.Items_por_factura(ipfa_factura_numero)

CREATE INDEX indx_bi_operaciones_automoviles_opau_id 
	ON [LOS_GEDDES].[Bi_Operaciones_automoviles] ([opau_auto]) INCLUDE ([opau_id])

CREATE INDEX indx_items_factura_id_autoparte
	ON LOS_GEDDES.Items_por_factura(ipfa_id_autoparte)

CREATE INDEX indx_items_compra_id_autoparte_cpra
	ON LOS_GEDDES.Items_por_compra(ipco_id_autoparte,ipco_id_compra)

CREATE INDEX indx_facturas_sucursal
	ON LOS_GEDDES.Facturas(fact_sucursal)

CREATE INDEX indx_compras_sucursal
	ON LOS_GEDDES.Compras(cpra_sucursal)
go

--Creacion de funciones
CREATE FUNCTION LOS_GEDDES.edad_en_el_anio(@fechaNacimiento datetime2(3), @unAnio smallint)
	RETURNS bigint AS BEGIN
		return @unAnio-YEAR(@fechaNacimiento)
	END
go

CREATE FUNCTION LOS_GEDDES.rango_edad(@edad bigint) RETURNS bigint AS 
	BEGIN
		DECLARE @rg_edad_18_30   bigint = 1 
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

CREATE FUNCTION LOS_GEDDES.instante_en_meses(@mes tinyint, @anio smallint) returns bigint as
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

CREATE FUNCTION LOS_GEDDES.calcular_stock(@instante bigint,    @autoparte bigint, @sucursal bigint)
returns bigint AS
    BEGIN
        DECLARE @anio bigint,@mes bigint;

        Select top 1 @anio = inst_anio, @mes = inst_mes from LOS_GEDDES.Bi_Instantes where inst_id = @instante;

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
	Select inst_anio as Anio, inst_mes as Mes, ciud_nombre as Ciudad, sucu_direccion as Sucursal, count(*) as Cantidad_comprada
		,  (
			Select count(*)
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
	Select inst_anio as Anio, inst_mes as Mes, ciud_nombre as Ciudad, sucu_direccion as Sucursal
		, cast(avg(opau_precio_compra) as decimal(18,2)) as Precio_promedio_compra
		, (
			Select cast(avg(ov.opau_precio_venta) as decimal(18,2))
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
	Select inst_anio as Anio, inst_mes as Mes, ciud_nombre as Ciudad, sucu_direccion as Sucursal, sum(opau_precio_venta-opau_precio_compra) as Ganancia
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
	Select opau_modelo as Modelo, (
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
	Select inst_anio as anio, inst_mes as mes, sucu_ciudad as sucursal_ciudad, sucu_direccion as sucursal_direccion,
		sum((opap_precio_venta - opap_costo_unitario )* opap_cant_vendida) as ganancia
		FROM LOS_GEDDES.Bi_Operaciones_autopartes 
		JOIN LOS_GEDDES.Bi_Instantes ON inst_id = opap_instante
		JOIN LOS_GEDDES.Sucursales ON sucu_id = opap_sucursal
		GROUP BY inst_anio,inst_mes,sucu_ciudad,sucu_direccion
);
go

CREATE VIEW LOS_GEDDES.Maxima_cantidad_stock_por_sucursal as
	Select opap_sucursal as Sucursal, inst_anio as Anio  
		from (
			Select opap_instante, opap_sucursal
				from LOS_GEDDES.Bi_Operaciones_autopartes
				group by opap_instante, opap_sucursal
		) as stock_mensual
		join LOS_GEDDES.Bi_Instantes on
			inst_id=opap_instante
		group by opap_sucursal, inst_anio
go

CREATE PROCEDURE LOS_GEDDES.CrearRangosDePotencia AS
BEGIN
	INSERT INTO LOS_GEDDES.Bi_rangos_potencias(rgpo_id, rgpo_min, rgpo_max)
		Values (1, 50,150), (2, 151, 300), (3, 301, null);
END
GO

CREATE PROCEDURE LOS_GEDDES.CrearRangosEdades AS
BEGIN
	INSERT INTO LOS_GEDDES.Bi_rangos_edades(rged_id, rged_min, rged_max)
		Values (0, 0, 17), (1, 18, 30), (2, 31, 50), (3, 51, null);
END
GO

-- Migracion de Datos
-- Instantes de tiempo
CREATE PROCEDURE LOS_GEDDES.MigracionInstantes AS
BEGIN
	
	INSERT INTO LOS_GEDDES.Bi_Instantes(inst_mes, inst_anio)
	Select distinct mes, anio from #operaciones
		order by anio, mes;
END
GO

-- Estadisticas de Clientes
CREATE PROCEDURE LOS_GEDDES.MigracionClientes AS
BEGIN

	INSERT INTO LOS_GEDDES.Bi_Estadisticas_clientes
	(ecli_instante, ecli_sucursal, ecli_sexo, ecli_rg_edad, ecli_cantidad)
	(
	Select distinct inst_id, sucursal, clie_sexo, rg_edad, count(*)
		from (
			Select *, LOS_GEDDES.rg_edad_en_el_anio(clie_fecha_nac, anio) as rg_edad 
				from LOS_GEDDES.Clientes 
				join #Operaciones
					on clie_id=cliente
		) as Clientes
		
		join LOS_GEDDES.Bi_Instantes
			on inst_mes = mes
			and inst_anio=anio
		group by sucursal, inst_id, rg_edad, clie_sexo
);
END
GO

-- Compras de Automoviles
CREATE PROCEDURE LOS_GEDDES.MigracionComprasAutomoviles AS
BEGIN
	 INSERT INTO LOS_GEDDES.Bi_Operaciones_automoviles
	 (opau_auto, opau_modelo, opau_rg_potencia, opau_instante_compra, opau_sucursal_compra, opau_precio_compra)
	 (
		Select automovil, modelo, LOS_GEDDES.rango_potencia(mode_potencia), inst_id, sucursal, precio_total from #operaciones
			join LOS_GEDDES.Bi_instantes
					on inst_anio=anio
					and inst_mes=mes
			join LOS_GEDDES.Modelos_automoviles
				on mode_codigo=modelo
			where modelo is not null		
	 );
 END
GO

-- Ventas de Automoviles
CREATE PROCEDURE LOS_GEDDES.MigracionVentasAutomoviles AS
BEGIN

	 UPDATE LOS_GEDDES.Bi_Operaciones_automoviles
		set opau_instante_venta=inst_id,
			opau_sucursal_venta=sucursal,
			opau_precio_venta=precio_total
		from #operaciones
		join LOS_GEDDES.bi_instantes on
			inst_anio=anio
			and inst_mes=mes
		where venta is not null
			and automovil=opau_auto
END
GO

-- Compra de Autopartes
CREATE PROCEDURE LOS_GEDDES.MigracionCompraAutopartes AS
BEGIN

	INSERT INTO LOS_GEDDES.Bi_Operaciones_autopartes
	(opap_instante, opap_sucursal, opap_autoparte, opap_rubro, opap_fabricante, opap_cant_comprada, opap_costo_unitario, opap_precio_venta
	, opap_cant_vendida)
	(
		Select inst_id, o.sucursal, ipco_id_autoparte, apte_categoria as rubro, apte_fabricante as fabricante
		, isnull(sum(ipco_cantidad), 0) as cantidad_comprada
		, max(ipco_precio), 0 as max_precio_venta, 0 as cant_vendida
		FROM #operaciones o
		join LOS_GEDDES.Items_por_compra on ipco_id_compra=o.compra					
		join LOS_GEDDES.Bi_Instantes
				on inst_anio=o.anio
				and inst_mes=o.mes
		join LOS_GEDDES.Autopartes a on a.apte_codigo = ipco_id_autoparte
			group by inst_id, o.sucursal, ipco_id_autoparte, apte_categoria, apte_fabricante)

END
GO

-- Venta de Autopartes
CREATE PROCEDURE LOS_GEDDES.MigracionVentaAutopartes AS
BEGIN

	INSERT INTO LOS_GEDDES.Bi_Operaciones_autopartes
	(opap_instante, opap_sucursal, opap_autoparte, opap_rubro, opap_fabricante, opap_cant_comprada, opap_costo_unitario, opap_precio_venta
	, opap_cant_vendida)
	(Select inst_id, o.sucursal, ipfa_id_autoparte, apte_categoria as rubro, apte_fabricante as fabricante
		, 0 as cantidad_comprada
		, SUM(ipfa_cantidad), max(ipfa_precio_facturado) as max_precio_venta
		, isnull(sum(ipfa_cantidad), 0) as cant_vendida
		from #operaciones o
						join LOS_GEDDES.Items_por_factura
							on ipfa_factura_numero=o.venta
		join LOS_GEDDES.Bi_Instantes
				on inst_anio=anio
				and inst_mes=mes
		join LOS_GEDDES.Autopartes a on a.apte_codigo = ipfa_id_autoparte
			group by inst_id, o.sucursal, ipfa_id_autoparte, apte_categoria, apte_fabricante)

END
GO

CREATE PROCEDURE LOS_GEDDES.MigracionBI AS
BEGIN
	PRINT '*************************** Inicio migracion de datos BI ****************************'
	DECLARE @SALTO_DE_LINEA char(1) = char(10)

	print '>> Creacion de tabla temporal Operaciones:'	 
	SELECT * INTO #Operaciones FROM
	(Select cpra_numero as compra, null AS venta, cpra_sucursal AS sucursal, year(cpra_fecha) AS anio, MONTH(cpra_fecha) AS mes, cpra_cliente AS cliente, auto_id AS automovil, auto_modelo AS modelo, 
	cpra_precio_total AS precio_total
		from LOS_GEDDES.Compras
		left join LOS_GEDDES.Automoviles
			on auto_id=cpra_automovil

	UNION ALL

	Select null AS compra, fact_numero AS venta, fact_sucursal AS sucursal, year(fact_fecha)AS anio, MONTH(fact_fecha)AS mes, fact_cliente AS cliente, auto_id AS automovil, auto_modelo AS modelo, 
	fact_precio  AS precio_total
		from LOS_GEDDES.Facturas
		left join LOS_GEDDES.Automoviles
			on auto_id=fact_automovil
	) AS Operaciones

	print @SALTO_DE_LINEA + '>> Migracion Rangos edades:'
	EXEC LOS_GEDDES.CrearRangosEdades

	print @SALTO_DE_LINEA + '>> Migracion Rangos potencias:'
	EXEC LOS_GEDDES.CrearRangosDePotencia

	print @SALTO_DE_LINEA +'>> Migracion Instantes de tiempo:'
	EXEC LOS_GEDDES.MigracionInstantes

	print @SALTO_DE_LINEA +'>> Migracion estadisticas clientes:'
	EXEC LOS_GEDDES.MigracionClientes

	print @SALTO_DE_LINEA +'>> Migracion Compras de automoviles:'
	EXEC LOS_GEDDES.MigracionComprasAutomoviles

	print @SALTO_DE_LINEA +'>> Migracion Ventas de automoviles:'
	EXEC LOS_GEDDES.MigracionVentasAutomoviles

	print @SALTO_DE_LINEA +'>> Migracion Compras de autopartes:'
	EXEC LOS_GEDDES.MigracionCompraAutopartes

	print @SALTO_DE_LINEA +'>> Migracion Ventas de autopartes:'
	EXEC LOS_GEDDES.MigracionVentaAutopartes	

END
GO

EXEC LOS_GEDDES.MigracionBI
GO


DROP FUNCTION LOS_GEDDES.edad_en_el_anio
DROP FUNCTION LOS_GEDDES.rango_edad
DROP FUNCTION LOS_GEDDES.rg_edad_en_el_anio
DROP FUNCTION LOS_GEDDES.rango_potencia
DROP FUNCTION LOS_GEDDES.calcular_stock
DROP INDEX LOS_GEDDES.Items_por_factura.indx_items_factura_factura_numero
DROP INDEX LOS_GEDDES.Items_por_factura.indx_items_factura_id_autoparte 
DROP INDEX LOS_GEDDES.Items_por_compra.indx_items_compra_id_autoparte_cpra
DROP INDEX LOS_GEDDES.Facturas.indx_facturas_sucursal
DROP INDEX LOS_GEDDES.BI_Operaciones_automoviles.indx_bi_operaciones_automoviles_opau_id
DROP INDEX LOS_GEDDES.Compras.indx_compras_sucursal
DROP PROCEDURE LOS_GEDDES.CrearRangosDePotencia
DROP PROCEDURE LOS_GEDDES.CrearRangosEdades
DROP PROCEDURE LOS_GEDDES.MigracionInstantes
DROP PROCEDURE LOS_GEDDES.MigracionClientes
DROP PROCEDURE LOS_GEDDES.MigracionComprasAutomoviles
DROP PROCEDURE LOS_GEDDES.MigracionVentasAutomoviles
DROP PROCEDURE LOS_GEDDES.MigracionCompraAutopartes
DROP PROCEDURE LOS_GEDDES.MigracionVentaAutopartes 
DROP PROCEDURE LOS_GEDDES.MigracionBI
GO