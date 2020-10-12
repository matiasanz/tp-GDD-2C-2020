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
  ciud_nombre nvarchar(255)
  
  PRIMARY KEY(ciud_id)
);  

CREATE TABLE LOS_GEDDES.Sucursales(
  sucu_id		 bigint IDENTITY(1,1) NOT NULL,
  sucu_direccion nvarchar(255),
  sucu_mail		 nvarchar(255),
  sucu_telefono  decimal(18,0),
  sucu_ciudad_id bigint

  PRIMARY KEY(sucu_id),
  FOREIGN KEY(sucu_ciudad_id) REFERENCES LOS_GEDDES.Ciudades(ciud_id)
);

CREATE TABLE LOS_GEDDES.Tipos_automoviles(
  taut_codigo	   decimal(18,0), --cambiar por id
  taut_descripcion nvarchar(255)

  PRIMARY KEY(taut_codigo)
);

CREATE TABLE LOS_GEDDES.Componentes (
  comp_id			bigint IDENTITY(1,1) NOT NULL,
  comp_descripcion nvarchar(255)

  PRIMARY KEY(comp_id)
);

CREATE TABLE LOS_GEDDES.Tipo_componentes(
  tcom_id			 bigint IDENTITY(1,1) NOT NULL,
  tcom_componente_id bigint,
  tcom_codigo		 decimal(18,0),
  tcom_descripcion	 nvarchar(255)

  PRIMARY KEY(tcom_id),
  FOREIGN KEY(tcom_componente_id) REFERENCES LOS_GEDDES.Componentes(comp_id)
);

CREATE TABLE LOS_GEDDES.Fabricantes(
  fabr_id	  bigint IDENTITY(1,1) NOT NULL,
  fabr_nombre nvarchar(255)

  PRIMARY KEY(fabr_id)
);

CREATE TABLE LOS_GEDDES.Modelos_automoviles(
  mode_codigo            decimal(18,0), --cambiar por id
  mode_nombre            nvarchar(255),
  mode_potencia          decimal(18,0),
  mode_fabricante_id     bigint,
  mode_tipo_auto         decimal(18,0),
  mode_tipo_transmision  bigint,
  mode_tipo_motor        bigint,
  mode_tipo_caja_cambios bigint,
  mode_cantidad_cambios  smallint

  PRIMARY KEY(mode_codigo),
  FOREIGN KEY(mode_fabricante_id) REFERENCES LOS_GEDDES.Fabricantes(fabr_id),
  FOREIGN KEY(mode_tipo_auto) REFERENCES LOS_GEDDES.Tipos_automoviles(taut_codigo), 
  FOREIGN KEY(mode_tipo_transmision) REFERENCES LOS_GEDDES.Tipo_componentes(tcom_id),
  FOREIGN KEY(mode_tipo_motor) REFERENCES LOS_GEDDES.Tipo_componentes(tcom_id),
  FOREIGN KEY(mode_tipo_caja_cambios) REFERENCES LOS_GEDDES.Tipo_componentes(tcom_id)
);

CREATE TABLE LOS_GEDDES.Automoviles(
  auto_id         bigint IDENTITY(1,1) NOT NULL,
  auto_nro_chasis nvarchar(50),
  auto_nro_motor  nvarchar(50),
  auto_patente    nvarchar(50),
  auto_fecha_alta datetime2(3),
  auto_cant_kms   decimal(18,0),
  auto_modelo_id  decimal(18,0)

  PRIMARY KEY(auto_id),
  FOREIGN KEY(auto_modelo_id) REFERENCES LOS_GEDDES.Modelos_automoviles(mode_codigo),
);

CREATE TABLE LOS_GEDDES.Clientes(
  clie_id		 bigint IDENTITY(1,1) NOT NULL,
  clie_nombre	 nvarchar(255),
  clie_apellido  nvarchar(255),
  clie_dni		 decimal(18,0),
  clie_direccion nvarchar(255),
  clie_fecha_nac datetime2(3),
  clie_mail		 nvarchar(255),
  clie_sexo		 char(1)
  
  PRIMARY KEY(clie_id),
  check(clie_sexo in ('m', 'f'))
);

CREATE TABLE LOS_GEDDES.Compras(
  cpra_numero        decimal(18,0),
  cpra_fecha         datetime2(3),
  cpra_precio_total  decimal(18,2),
  cpra_sucursal_id   bigint,
  cpra_automovil_id  bigint,
  cpra_cliente_id    bigint

  PRIMARY KEY(cpra_numero)
  FOREIGN KEY(cpra_sucursal_id ) REFERENCES LOS_GEDDES.Sucursales(sucu_id),
  FOREIGN KEY(cpra_automovil_id) REFERENCES LOS_GEDDES.Automoviles(auto_id),
  FOREIGN KEY(cpra_cliente_id) REFERENCES LOS_GEDDES.Clientes(clie_id)
);

CREATE TABLE LOS_GEDDES.Categorias_autopartes(
  cate_codigo	   bigint,
  cate_descripcion nvarchar(255)
  
  PRIMARY KEY(cate_codigo)
);

CREATE TABLE LOS_GEDDES.Autopartes(
  apte_codigo		  decimal(18,0), --cambiar por id
  apte_descripcion	  nvarchar(255),
  apte_modelo_auto_id decimal(18,0),
  apte_fabricante_id  bigint,
  apte_categoria_id   bigint

  PRIMARY KEY(apte_codigo),
  FOREIGN KEY(apte_modelo_auto_id) REFERENCES LOS_GEDDES.Modelos_automoviles(mode_codigo),
  FOREIGN KEY(apte_fabricante_id ) REFERENCES LOS_GEDDES.Fabricantes(fabr_id),
  FOREIGN KEY(apte_categoria_id  ) REFERENCES LOS_GEDDES.Categorias_autopartes(cate_codigo)
);

CREATE TABLE LOS_GEDDES.Items_por_compra (
  ipc_id_compra	   decimal(18,0),
  ipc_id_autoparte decimal(18,0),
  ipc_cantidad	   decimal(18,0),
  ipc_precio	   decimal(18,2)

  PRIMARY KEY(ipc_id_compra, ipc_id_autoparte),
  FOREIGN KEY(ipc_id_compra	  ) REFERENCES LOS_GEDDES.Compras(cpra_numero),
  FOREIGN KEY(ipc_id_autoparte) REFERENCES LOS_GEDDES.Autopartes(apte_codigo)
);

CREATE TABLE LOS_GEDDES.Facturas(
  fact_id				 bigint IDENTITY(1,1) NOT NULL,
  fact_numero			 decimal(18,0),
  fact_fecha			 datetime2(3),
  fact_cliente_id		 bigint,
  fact_sucursal_id		 bigint,
  fact_automovil_id		 bigint,
  fact_direccion_cliente nvarchar(255),
  fact_mail_cliente		 nvarchar(255)

  PRIMARY KEY(fact_id),
  FOREIGN KEY(fact_cliente_id  ) REFERENCES LOS_GEDDES.Clientes(clie_id),
  FOREIGN KEY(fact_sucursal_id ) REFERENCES LOS_GEDDES.Sucursales(sucu_id),
  FOREIGN KEY(fact_automovil_id) REFERENCES LOS_GEDDES.Automoviles(auto_id)
);

CREATE TABLE LOS_GEDDES.Items_por_factura(
  ipf_id_factura	   bigint IDENTITY(1,1) NOT NULL,
  ipf_id_autoparte	   decimal(18,0),
  ipf_cantidad		   decimal(18,0),
  ipf_precio_facturado decimal(18,2)

  PRIMARY KEY(ipf_id_factura, ipf_id_autoparte),
  FOREIGN KEY(ipf_id_factura  ) REFERENCES LOS_GEDDES.Facturas(fact_id),
  FOREIGN KEY(ipf_id_autoparte) REFERENCES LOS_GEDDES.Autopartes(apte_codigo)
);
GO