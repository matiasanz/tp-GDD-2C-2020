USE [GD2C2020]
GO

-- Creacion Schema
IF NOT EXISTS(SELECT * FROM sys.schemas WHERE name = 'LOS_GEDDES')
	EXEC('CREATE SCHEMA[LOS_GEDDES] AUTHORIZATION [dbo]')
GO

-- Drop tables
IF OBJECT_ID('LOS_GEDDES.Items_por_factura') IS NOT NULL
	DROP TABLE LOS_GEDDES.Items_por_factura

IF OBJECT_ID('LOS_GEDDES.Facturas') IS NOT NULL
	DROP TABLE LOS_GEDDES.Facturas

IF OBJECT_ID('LOS_GEDDES.Items_por_Compra') IS NOT NULL
	DROP TABLE LOS_GEDDES.Items_por_Compra

IF OBJECT_ID('LOS_GEDDES.Autopartes') IS NOT NULL
	DROP TABLE LOS_GEDDES.Autopartes

IF OBJECT_ID('LOS_GEDDES.Categorias_autopartes') IS NOT NULL
	DROP TABLE LOS_GEDDES.Categorias_autopartes

IF OBJECT_ID('LOS_GEDDES.Compras') IS NOT NULL
	DROP TABLE LOS_GEDDES.Compras

IF OBJECT_ID('LOS_GEDDES.Clientes') IS NOT NULL
	DROP TABLE LOS_GEDDES.Clientes

IF OBJECT_ID('LOS_GEDDES.Automoviles') IS NOT NULL
	DROP TABLE LOS_GEDDES.Automoviles

IF OBJECT_ID('LOS_GEDDES.Modelos_automoviles') IS NOT NULL
	DROP TABLE LOS_GEDDES.Modelos_automoviles

IF OBJECT_ID('LOS_GEDDES.Fabricantes') IS NOT NULL
	DROP TABLE LOS_GEDDES.Fabricantes

IF OBJECT_ID('LOS_GEDDES.Tipo_componentes') IS NOT NULL
	DROP TABLE LOS_GEDDES.Tipo_componentes

IF OBJECT_ID('LOS_GEDDES.Componentes') IS NOT NULL
	DROP TABLE LOS_GEDDES.Componentes

IF OBJECT_ID('LOS_GEDDES.Tipos_automoviles') IS NOT NULL
	DROP TABLE LOS_GEDDES.Tipos_automoviles

IF OBJECT_ID('LOS_GEDDES.Sucursales') IS NOT NULL
	DROP TABLE [LOS_GEDDES].Sucursales

IF OBJECT_ID('LOS_GEDDES.Ciudades') IS NOT NULL
	DROP TABLE LOS_GEDDES.Ciudades
GO

--Creacion de Tablas
CREATE TABLE LOS_GEDDES.Ciudades (
  ciud_id     bigint IDENTITY(1,1) NOT NULL,
  ciud_nombre nvarchar(255) NOT NULL
  CONSTRAINT PK_Ciudades PRIMARY KEY(ciud_id)
);  

CREATE TABLE LOS_GEDDES.Sucursales(
  sucu_id		 bigint IDENTITY(1,1) NOT NULL,
  sucu_direccion nvarchar(255) NOT NULL,
  sucu_mail		 nvarchar(255) NOT NULL,
  sucu_telefono  decimal(18,0) NOT NULL,
  sucu_ciudad    bigint NOT NULL

  CONSTRAINT PK_Sucursales PRIMARY KEY(sucu_id),
  CONSTRAINT FK_Sucursales_ciudad FOREIGN KEY(sucu_ciudad) REFERENCES LOS_GEDDES.Ciudades(ciud_id)
);

CREATE TABLE LOS_GEDDES.Tipos_automoviles(
  taut_codigo	   decimal(18,0) NOT NULL, 
  taut_descripcion nvarchar(255) NOT NULL

  CONSTRAINT PK_Tipos_automoviles PRIMARY KEY(taut_codigo)
);

CREATE TABLE LOS_GEDDES.Componentes (
  comp_id		   bigint,
  comp_descripcion nvarchar(255) NOT NULL

  CONSTRAINT PK_Componentes PRIMARY KEY(comp_id)
);

CREATE TABLE LOS_GEDDES.Tipo_componentes(
  tcom_id			 bigint IDENTITY(1,1) NOT NULL,
  tcom_componente    bigint NOT NULL,
  tcom_codigo		 decimal(18,0) NOT NULL,
  tcom_descripcion	 nvarchar(255)

  CONSTRAINT PK_Tipo_componentes PRIMARY KEY(tcom_id),
  CONSTRAINT FK_Tipo_componentes_componente FOREIGN KEY(tcom_componente) REFERENCES LOS_GEDDES.Componentes(comp_id)
);

CREATE TABLE LOS_GEDDES.Fabricantes(
  fabr_id	  bigint IDENTITY(1,1) NOT NULL,
  fabr_nombre nvarchar(255) NOT NULL

  CONSTRAINT PK_Fabricantes PRIMARY KEY(fabr_id)
);

CREATE TABLE LOS_GEDDES.Modelos_automoviles(
  mode_codigo            decimal(18,0) NOT NULL,
  mode_nombre            nvarchar(255) NOT NULL,
  mode_potencia          decimal(18,0) NOT NULL,
  mode_fabricante        bigint NOT NULL,
  mode_tipo_auto         decimal(18,0) NOT NULL,
  mode_tipo_transmision  bigint NOT NULL,
  mode_tipo_motor        bigint NOT NULL,
  mode_tipo_caja_cambios bigint NOT NULL,
  mode_cantidad_cambios  smallint NULL

  CONSTRAINT PK_Modelos_automoviles PRIMARY KEY(mode_codigo),
  CONSTRAINT FK_Modelos_automoviles_fabricante FOREIGN KEY(mode_fabricante) REFERENCES LOS_GEDDES.Fabricantes(fabr_id),
  CONSTRAINT FK_Modelos_automoviles_tipo_auto FOREIGN KEY(mode_tipo_auto) REFERENCES LOS_GEDDES.Tipos_automoviles(taut_codigo), 
  CONSTRAINT FK_Modelos_automoviles_tipo_transmision FOREIGN KEY(mode_tipo_transmision) REFERENCES LOS_GEDDES.Tipo_componentes(tcom_id),
  CONSTRAINT FK_Modelos_automoviles_tipo_motor FOREIGN KEY(mode_tipo_motor) REFERENCES LOS_GEDDES.Tipo_componentes(tcom_id),
  CONSTRAINT FK_Modelos_automoviles_tipo_caja_cambios FOREIGN KEY(mode_tipo_caja_cambios) REFERENCES LOS_GEDDES.Tipo_componentes(tcom_id)
);

CREATE TABLE LOS_GEDDES.Automoviles(
  auto_id         bigint IDENTITY(1,1) NOT NULL,
  auto_nro_chasis nvarchar(50) NOT NULL,
  auto_nro_motor  nvarchar(50) NOT NULL,
  auto_patente    nvarchar(50) NOT NULL,
  auto_fecha_alta datetime2(3) NOT NULL,
  auto_cant_kms   decimal(18,0) NOT NULL,
  auto_modelo     decimal(18,0) NOT NULL

  CONSTRAINT PK_Automoviles PRIMARY KEY(auto_id),
  CONSTRAINT FK_Automoviles_modelo FOREIGN KEY(auto_modelo) REFERENCES LOS_GEDDES.Modelos_automoviles(mode_codigo),
);

CREATE TABLE LOS_GEDDES.Clientes(
  clie_id		 bigint IDENTITY(1,1) NOT NULL,
  clie_dni		 decimal(18,0) NOT NULL,
  clie_nombre	 nvarchar(255) NOT NULL,
  clie_apellido  nvarchar(255) NOT NULL,  
  clie_direccion nvarchar(255) NOT NULL,
  clie_fecha_nac datetime2(3) NOT NULL,
  clie_mail		 nvarchar(255) NOT NULL,
  clie_sexo		 char(1)
  
  CONSTRAINT PK_Clientes PRIMARY KEY(clie_id),
  CONSTRAINT CK_sexo CHECK(clie_sexo in ('m', 'f'))
);

CREATE TABLE LOS_GEDDES.Compras(
  cpra_numero        decimal(18,0) NOT NULL,
  cpra_fecha         datetime2(3) NOT NULL,
  cpra_precio_total  decimal(18,2), --NOT NULL, <--En la compra de autopartes se carga despues
  cpra_sucursal      bigint NOT NULL,
  cpra_automovil     bigint,
  cpra_cliente       bigint NOT NULL

  CONSTRAINT PK_Compras PRIMARY KEY(cpra_numero)
  CONSTRAINT FK_Compras_sucursal FOREIGN KEY(cpra_sucursal) REFERENCES LOS_GEDDES.Sucursales(sucu_id),
  CONSTRAINT FK_Compras_automovil FOREIGN KEY(cpra_automovil) REFERENCES LOS_GEDDES.Automoviles(auto_id),
  CONSTRAINT FK_Compras_cliente FOREIGN KEY(cpra_cliente) REFERENCES LOS_GEDDES.Clientes(clie_id)
);

CREATE TABLE LOS_GEDDES.Categorias_autopartes(
  cate_codigo	   bigint NOT NULL,
  cate_descripcion nvarchar(255) NOT NULL
  
  CONSTRAINT PK_Categorias_autopartes PRIMARY KEY(cate_codigo)
);

CREATE TABLE LOS_GEDDES.Autopartes(
  apte_id			  bigint IDENTITY(1,1),
  apte_codigo		  decimal(18,0) NOT NULL, 
  apte_descripcion	  nvarchar(255) NOT NULL,
  apte_modelo_auto    decimal(18,0) NOT NULL,
  apte_fabricante	  bigint NOT NULL,
  apte_categoria      bigint

  CONSTRAINT PK_Autopartes PRIMARY KEY(apte_id),
  CONSTRAINT FK_Autopartes FOREIGN KEY(apte_fabricante) REFERENCES LOS_GEDDES.Fabricantes(fabr_id),
  CONSTRAINT FK_Autopartes_modelo_auto FOREIGN KEY(apte_modelo_auto) REFERENCES LOS_GEDDES.Modelos_automoviles(mode_codigo),
  CONSTRAINT FK_Autoparte_categoria FOREIGN KEY(apte_categoria) REFERENCES LOS_GEDDES.Categorias_autopartes(cate_codigo)
);

CREATE TABLE LOS_GEDDES.Items_por_compra (
  ipco_id_compra	decimal(18,0) NOT NULL,
  ipco_id_autoparte bigint NOT NULL,
  ipco_cantidad	    decimal(18,0) NOT NULL,
  ipco_precio	    decimal(18,2) NOT NULL

  CONSTRAINT PK_Items_por_compra PRIMARY KEY(ipco_id_compra, ipco_id_autoparte),
  CONSTRAINT FK_Items_por_compra_id_compra FOREIGN KEY(ipco_id_compra) REFERENCES LOS_GEDDES.Compras(cpra_numero),
  CONSTRAINT FK_Items_por_compra_id_autoparte FOREIGN KEY(ipco_id_autoparte) REFERENCES LOS_GEDDES.Autopartes(apte_id)
);

CREATE TABLE LOS_GEDDES.Facturas(
  fact_numero			 decimal(18,0) NOT NULL,
  fact_fecha			 datetime2(3) NOT NULL,
  fact_cliente   		 bigint NULL,
  fact_sucursal 		 bigint NOT NULL,
  fact_automovil		 bigint NULL,
  fact_direccion_cliente nvarchar(255) NULL,
  fact_mail_cliente		 nvarchar(255) NULL

  CONSTRAINT PK_Facturas PRIMARY KEY(fact_numero),
  CONSTRAINT FK_Facturas_cliente FOREIGN KEY(fact_cliente) REFERENCES LOS_GEDDES.Clientes(clie_id),
  CONSTRAINT FK_Facturas_sucursal FOREIGN KEY(fact_sucursal) REFERENCES LOS_GEDDES.Sucursales(sucu_id),
  CONSTRAINT FK_Facturas_automovil FOREIGN KEY(fact_automovil) REFERENCES LOS_GEDDES.Automoviles(auto_id)
);

CREATE TABLE LOS_GEDDES.Items_por_factura(
  ipfa_factura_numero   decimal(18,0) NOT NULL,
  ipfa_id_autoparte	    bigint NOT NULL,
  ipfa_cantidad		    decimal(18,0) NOT NULL,
  ipfa_precio_facturado decimal(18,2) NOT NULL

  CONSTRAINT PK_Items_por_factura PRIMARY KEY (ipfa_factura_numero, ipfa_id_autoparte),
  CONSTRAINT FK_Items_por_factura_factura_numero FOREIGN KEY(ipfa_factura_numero) REFERENCES LOS_GEDDES.Facturas(fact_numero),
  CONSTRAINT FK_Items_por_factura_id_autoparte FOREIGN KEY(ipfa_id_autoparte) REFERENCES LOS_GEDDES.Autopartes(apte_id)
);
GO

-- Migracion de Datos
-- Ciudades
IF OBJECT_ID ('LOS_GEDDES.MigracionCiudades', 'P') IS NOT NULL  
   DROP PROCEDURE LOS_GEDDES.MigracionCiudades; 
GO
CREATE PROCEDURE LOS_GEDDES.MigracionCiudades AS
BEGIN
	INSERT INTO LOS_GEDDES.Ciudades(ciud_nombre)
	SELECT DISTINCT SUCURSAL_CIUDAD 
	FROM gd_esquema.Maestra
	WHERE SUCURSAL_CIUDAD IS NOT NULL;
END
GO

--Sucursales
IF OBJECT_ID ('LOS_GEDDES.MigracionSucursales', 'P') IS NOT NULL  
   DROP PROCEDURE LOS_GEDDES.MigracionSucursales; 
GO
CREATE PROCEDURE LOS_GEDDES.MigracionSucursales AS
BEGIN
	INSERT INTO LOS_GEDDES.Sucursales(sucu_direccion,sucu_mail,sucu_telefono,sucu_ciudad)
	SELECT DISTINCT SUCURSAL_DIRECCION,SUCURSAL_MAIL,SUCURSAL_TELEFONO,c.ciud_id
	FROM gd_esquema.Maestra m
	JOIN LOS_GEDDES.Ciudades c on c.ciud_nombre = m.SUCURSAL_CIUDAD
	WHERE SUCURSAL_CIUDAD IS NOT NULL;
END
GO

--Tipo Automoviles
IF OBJECT_ID ('LOS_GEDDES.MigracionTipoAutomoviles', 'P') IS NOT NULL  
   DROP PROCEDURE LOS_GEDDES.MigracionTipoAutomoviles; 
GO
CREATE PROCEDURE LOS_GEDDES.MigracionTipoAutomoviles AS
BEGIN
	INSERT INTO LOS_GEDDES.Tipos_automoviles(taut_codigo,taut_descripcion)
	SELECT DISTINCT TIPO_AUTO_CODIGO,TIPO_AUTO_DESC
	FROM gd_esquema.Maestra
	WHERE TIPO_AUTO_CODIGO IS NOT NULL
END
GO

--Componentes
IF OBJECT_ID ('LOS_GEDDES.MigracionComponentes', 'P') IS NOT NULL  
   DROP PROCEDURE LOS_GEDDES.MigracionComponentes; 
GO
CREATE PROCEDURE LOS_GEDDES.MigracionComponentes 
@Id_Transmision bigint, @Id_Caja bigint, @Id_Motor bigint
AS
BEGIN
	INSERT INTO LOS_GEDDES.Componentes(comp_id,comp_descripcion)
	VALUES (@Id_Transmision,'TRANSMISION'),
		   (@Id_Caja,'CAJA'),
		   (@Id_Motor,'MOTOR');
END
GO

IF OBJECT_ID ('LOS_GEDDES.MigracionTipoComponentes', 'P') IS NOT NULL  
   DROP PROCEDURE LOS_GEDDES.MigracionTipoComponentes; 
GO
CREATE PROCEDURE LOS_GEDDES.MigracionTipoComponentes 
@Id_Transmision bigint, @Id_Caja bigint, @Id_Motor bigint
AS
BEGIN
	INSERT INTO LOS_GEDDES.Tipo_componentes(tcom_componente,tcom_codigo,tcom_descripcion)
	(
		SELECT DISTINCT @Id_Transmision,TIPO_TRANSMISION_CODIGO,TIPO_TRANSMISION_DESC
		FROM gd_esquema.Maestra
		WHERE TIPO_TRANSMISION_CODIGO IS NOT NULL

		UNION ALL

		SELECT DISTINCT @Id_Caja,TIPO_CAJA_CODIGO,TIPO_CAJA_DESC
		FROM gd_esquema.Maestra
		WHERE TIPO_CAJA_CODIGO IS NOT NULL

		UNION ALL

		SELECT DISTINCT @Id_Motor,TIPO_MOTOR_CODIGO,null
		FROM gd_esquema.Maestra
		WHERE TIPO_MOTOR_CODIGO IS NOT NULL
	)
END
GO

--Fabricantes
IF OBJECT_ID ('LOS_GEDDES.MigracionFabricantes', 'P') IS NOT NULL  
   DROP PROCEDURE LOS_GEDDES.MigracionFabricantes; 
GO
CREATE PROCEDURE LOS_GEDDES.MigracionFabricantes AS
BEGIN
	INSERT INTO LOS_GEDDES.Fabricantes(fabr_nombre)
	SELECT DISTINCT FABRICANTE_NOMBRE
	FROM gd_esquema.Maestra
	WHERE FABRICANTE_NOMBRE IS NOT NULL;
END
GO

--Modelos Automoviles
IF OBJECT_ID ('LOS_GEDDES.MigracionModelosAutomoviles', 'P') IS NOT NULL  
   DROP PROCEDURE LOS_GEDDES.MigracionModelosAutomoviles; 
GO
CREATE PROCEDURE LOS_GEDDES.MigracionModelosAutomoviles 
@Id_Transmision bigint, @Id_Caja bigint, @Id_Motor bigint
AS
BEGIN
	INSERT INTO LOS_GEDDES.Modelos_automoviles(mode_codigo,mode_nombre,mode_potencia,mode_fabricante,
		mode_tipo_auto,mode_tipo_transmision,mode_tipo_motor,mode_tipo_caja_cambios,mode_cantidad_cambios)
	SELECT DISTINCT 
		MODELO_CODIGO,MODELO_NOMBRE,MODELO_POTENCIA,f.fabr_id,ta.taut_codigo,tct.tcom_id trasmicion,tcm.tcom_id motor,tcc.tcom_id caja, NULL
	FROM gd_esquema.Maestra m
	JOIN LOS_GEDDES.Fabricantes f on f.fabr_nombre = m.FABRICANTE_NOMBRE
	JOIN LOS_GEDDES.Tipos_automoviles ta on ta.taut_codigo = m.TIPO_AUTO_CODIGO
	JOIN LOS_GEDDES.Tipo_componentes tct on tct.tcom_codigo = m.TIPO_TRANSMISION_CODIGO and tct.tcom_componente = @Id_Transmision
	JOIN LOS_GEDDES.Tipo_componentes tcc on tcc.tcom_codigo = m.TIPO_CAJA_CODIGO 
	and tcc.tcom_componente = @Id_Caja
	JOIN LOS_GEDDES.Tipo_componentes tcm on tcm.tcom_codigo = m.TIPO_MOTOR_CODIGO and tcm.tcom_componente = @Id_Motor
	WHERE m.MODELO_CODIGO IS NOT NULL and m.TIPO_TRANSMISION_CODIGO is not null 
		and m.TIPO_CAJA_CODIGO is not null and m.TIPO_MOTOR_CODIGO is not null;
END
GO

--Autopartes
IF OBJECT_ID ('LOS_GEDDES.MigracionAutopartes', 'P') IS NOT NULL  
   DROP PROCEDURE LOS_GEDDES.MigracionAutopartes; 
GO
CREATE PROCEDURE LOS_GEDDES.MigracionAutopartes AS
BEGIN
	INSERT INTO LOS_GEDDES.Autopartes
	(apte_codigo, apte_descripcion, apte_modelo_auto, apte_fabricante)
	(
		SELECT DISTINCT AUTO_PARTE_CODIGO, AUTO_PARTE_DESCRIPCION, MODELO_CODIGO, fabr_id
			from gd_esquema.Maestra maestra
			join LOS_GEDDES.Fabricantes fabr on
				fabr.fabr_nombre = maestra.FABRICANTE_NOMBRE
			where AUTO_PARTE_CODIGO is not null
	);
END
GO

-- Clientes
IF OBJECT_ID ('LOS_GEDDES.MigracionClientes', 'P') IS NOT NULL  
   DROP PROCEDURE LOS_GEDDES.MigracionClientes; 
GO
CREATE PROCEDURE LOS_GEDDES.MigracionClientes AS
BEGIN
	INSERT INTO LOS_GEDDES.Clientes       
			SELECT DISTINCT CLIENTE_DNI, CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_DIRECCION, CLIENTE_FECHA_NAC, 
							CLIENTE_MAIL, NULL
			FROM gd_esquema.Maestra 
			WHERE CLIENTE_DNI IS NOT NULL
END
GO

-- Automoviles
IF OBJECT_ID ('LOS_GEDDES.MigracionAutomoviles', 'P') IS NOT NULL  
   DROP PROCEDURE LOS_GEDDES.MigracionAutomoviles; 
GO
CREATE PROCEDURE LOS_GEDDES.MigracionAutomoviles AS
BEGIN
	insert into LOS_GEDDES.Automoviles
	(auto_nro_chasis, auto_nro_motor, auto_patente, auto_fecha_alta, auto_cant_kms, auto_modelo)
	(
		SELECT DISTINCT AUTO_NRO_CHASIS, AUTO_NRO_MOTOR, AUTO_PATENTE, AUTO_FECHA_ALTA, AUTO_CANT_KMS, MODELO_CODIGO
			from gd_esquema.Maestra
			where AUTO_NRO_CHASIS is not null
	);
END
GO


IF OBJECT_ID ('LOS_GEDDES.MigracionCompras', 'P') IS NOT NULL  
   DROP PROCEDURE LOS_GEDDES.MigracionCompras; 
GO
CREATE PROCEDURE LOS_GEDDES.MigracionCompras AS
BEGIN
	--Compra Automoviles
	print '
	* Compras de Automoviles'

	insert into LOS_GEDDES.Compras
	(cpra_numero, cpra_fecha, cpra_precio_total, cpra_sucursal, cpra_automovil, cpra_cliente)
	(
		select distinct COMPRA_NRO, COMPRA_FECHA, COMPRA_PRECIO, s.sucu_id, a.auto_id, clie_id
			from gd_esquema.Maestra maestra
			join LOS_GEDDES.Ciudades on
				ciud_nombre = SUCURSAL_CIUDAD
			join LOS_GEDDES.Sucursales s on 
				s.sucu_direccion = SUCURSAL_DIRECCION
			join LOS_GEDDES.Clientes on 
				clie_dni = CLIENTE_DNI
				and clie_nombre   = CLIENTE_NOMBRE 
				and clie_apellido = CLIENTE_APELLIDO
			--
			join LOS_GEDDES.Automoviles a on
				 a.auto_nro_chasis = maestra.AUTO_NRO_CHASIS
		
			where maestra.COMPRA_NRO is not null and maestra.AUTO_NRO_MOTOR is not null		
	);

	print '
	* Compras de Autopartes'

	insert into LOS_GEDDES.Compras
	(cpra_numero, cpra_fecha, cpra_precio_total, cpra_sucursal, cpra_cliente)
	(
		select distinct COMPRA_NRO, COMPRA_FECHA, SUM(COMPRA_CANT*COMPRA_PRECIO) as [precio total], s.sucu_id, clie_id
			from gd_esquema.Maestra maestra
			join LOS_GEDDES.Ciudades on
				ciud_nombre = SUCURSAL_CIUDAD
			join LOS_GEDDES.Sucursales s on 
				s.sucu_direccion = SUCURSAL_DIRECCION
			join LOS_GEDDES.Clientes on 
				clie_dni = CLIENTE_DNI
				and clie_nombre   = CLIENTE_NOMBRE 
				and clie_apellido = CLIENTE_APELLIDO
		
			where maestra.COMPRA_NRO is not null and AUTO_PATENTE is null
			
			group by COMPRA_NRO, COMPRA_FECHA, SUCU_ID, clie_id
	);

	-- Items por compra
	print '
	* Items por compra'
	insert into LOS_GEDDES.Items_por_compra
	(ipco_id_compra, ipco_id_autoparte, ipco_cantidad, ipco_precio)
	(
		select distinct c.cpra_numero, apte_id, sum(COMPRA_CANT), COMPRA_PRECIO from gd_esquema.Maestra maestra
			join LOS_GEDDES.Compras c on
				c.cpra_numero = maestra.COMPRA_NRO
			join LOS_GEDDES.Fabricantes f on
				f.fabr_nombre = maestra.FABRICANTE_NOMBRE		
			join LOS_GEDDES.Autopartes ap on
				ap.apte_codigo = maestra.AUTO_PARTE_CODIGO
			where COMPRA_NRO is not null and AUTO_PARTE_CODIGO is not null
			group by cpra_numero, apte_id, fabr_id, COMPRA_PRECIO
	);
END
GO

 --Facturas
IF OBJECT_ID ('LOS_GEDDES.MigracionFacturas', 'P') IS NOT NULL  
   DROP PROCEDURE LOS_GEDDES.MigracionFacturas; 
GO
CREATE PROCEDURE LOS_GEDDES.MigracionFacturas AS
BEGIN
	print '
	* Tabla temporal'

	CREATE TABLE #facturas(
		nro decimal(18, 0),
		fecha datetime2(3),
		cant_facturada decimal(18, 0),
		cliente_dni decimal(18, 0),
		cliente_nombre [nvarchar](255),
		cliente_apellido [nvarchar](255),
		sucursal_direccion nvarchar(255),
		sucursal_mail nvarchar(255),
		sucursal_telefono decimal(18, 0),
		auto_nro_chasis nvarchar(50),
		auto_parte_codigo decimal(18, 0),
		precio_facturado decimal(18, 2)
	)

	INSERT INTO #facturas
	SELECT DISTINCT FACTURA_NRO, FACTURA_FECHA, CANT_FACTURADA, FAC_CLIENTE_DNI, FAC_CLIENTE_NOMBRE, 
		FAC_CLIENTE_APELLIDO, FAC_SUCURSAL_DIRECCION, FAC_SUCURSAL_MAIL, FAC_SUCURSAL_TELEFONO,
		AUTO_NRO_CHASIS, AUTO_PARTE_CODIGO, PRECIO_FACTURADO
		FROM gd_esquema.Maestra
		WHERE FACTURA_NRO IS NOT NULL

	print '
	* Facturas'

	INSERT INTO LOS_GEDDES.Facturas
		
			SELECT DISTINCT f.nro, f.fecha, c.clie_id, s.sucu_id, 
			NULL, c.clie_direccion, c.clie_mail
			FROM #facturas f
			LEFT JOIN LOS_GEDDES.Clientes c 
				ON c.clie_dni = f.cliente_dni
					AND c.clie_apellido = f.cliente_apellido  
					AND c.clie_nombre = f.cliente_nombre 
			INNER JOIN LOS_GEDDES.Sucursales s
				ON s.sucu_direccion = f.sucursal_direccion 
				   AND s.sucu_mail = f.sucursal_mail
				   AND s.sucu_telefono = f.sucursal_telefono
			WHERE f.cant_facturada IS NOT NULL -- Facturas de autopartes

			UNION ALL

			SELECT DISTINCT f.nro, f.fecha, c.clie_id, s.sucu_id, 
			a.auto_id, c.clie_direccion, c.clie_mail
			FROM #facturas f
			INNER JOIN LOS_GEDDES.Automoviles a 
				ON a.auto_nro_chasis = f.auto_nro_chasis
			LEFT JOIN LOS_GEDDES.Clientes c 
				ON c.clie_dni = f.cliente_dni
					AND c.clie_apellido = f.cliente_apellido  
					AND c.clie_nombre = f.cliente_nombre 
			INNER JOIN LOS_GEDDES.Sucursales s
				ON s.sucu_direccion = f.sucursal_direccion 
				   AND s.sucu_mail = f.sucursal_mail
				   AND s.sucu_telefono = f.sucursal_telefono
			WHERE f.cant_facturada IS NULL -- Facturas de autos

	print '
	* items_por_factura'

	INSERT INTO LOS_GEDDES.Items_por_factura
		SELECT f.nro, a.apte_id, SUM(f.cant_facturada), f.precio_facturado
			FROM #facturas f
			INNER JOIN LOS_GEDDES.Autopartes a on f.auto_parte_codigo = a.apte_codigo
			GROUP BY f.nro, a.apte_id, f.precio_facturado

	DROP TABLE #facturas
END
GO

IF OBJECT_ID ('LOS_GEDDES.MigracionTablas', 'P') IS NOT NULL  
   DROP PROCEDURE LOS_GEDDES.MigracionTablas; 
GO

CREATE PROCEDURE LOS_GEDDES.MigracionTablasConcesionaria AS
BEGIN
	print '*************************** Inicio migracion de datos ****************************'
	DECLARE @Id_Transmision bigint = 1 
	DECLARE @Id_Caja bigint = 2 
	DECLARE @Id_Motor bigint = 3 

	DECLARE @SALTO_DE_LINEA char(1) = char(10)

	print '>> Migracion Ciudades:'
	EXEC LOS_GEDDES.MigracionCiudades
	
	print @SALTO_DE_LINEA +'>> Migracion Sucursales'
	EXEC LOS_GEDDES.MigracionSucursales

	print @SALTO_DE_LINEA +'>> Migracion Tipos Automoviles'
	EXEC LOS_GEDDES.MigracionTipoAutomoviles
	
	print @SALTO_DE_LINEA +'>> Migracion Componentes'
	EXEC LOS_GEDDES.MigracionComponentes @Id_Transmision, @Id_Caja, @Id_Motor
	
	print @SALTO_DE_LINEA +'>> Migracion Tipos de Componentes'
	EXEC LOS_GEDDES.MigracionTipoComponentes @Id_Transmision, @Id_Caja, @Id_Motor
	
	print @SALTO_DE_LINEA +'>> Migracion Fabricantes'
	EXEC LOS_GEDDES.MigracionFabricantes
	
	print @SALTO_DE_LINEA +'>> Migracion Modelos Automoviles'
	EXEC LOS_GEDDES.MigracionModelosAutomoviles @Id_Transmision, @Id_Caja, @Id_Motor
	
	print @SALTO_DE_LINEA +'>> Migracion Autopartes'
	EXEC LOS_GEDDES.MigracionAutopartes

	print @SALTO_DE_LINEA +'>> Migracion Clientes'
	EXEC LOS_GEDDES.MigracionClientes

	print @SALTO_DE_LINEA +'>> Migracion Automoviles'
	EXEC LOS_GEDDES.MigracionAutomoviles

	print @SALTO_DE_LINEA +'>> Migracion Compras'
	EXEC LOS_GEDDES.MigracionCompras

	print @SALTO_DE_LINEA +'>> Migracion Facturas'
	EXEC LOS_GEDDES.MigracionFacturas
END
GO

EXEC LOS_GEDDES.MigracionTablasConcesionaria
GO