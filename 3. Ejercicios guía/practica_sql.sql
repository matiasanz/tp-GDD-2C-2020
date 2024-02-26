use [GD2015C1]
go

/*1
Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea mayor o
igual a $ 1000 ordenado por código de cliente*/

create procedure ej_1 as
	select clie_codigo as codigo, clie_razon_social as [razon social]
		from Cliente
		where clie_limite_credito >= 1000
		order by codigo;
go

drop procedure ej_1
go

/*2 Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados por
cantidad vendida*/

create procedure ej_2 as
	select prod_codigo as codigo, prod_detalle as detalle
		from Producto
		join Item_Factura on prod_codigo = item_producto 
		join Factura on item_tipo = fact_tipo
				and  item_numero = fact_numero
				and  item_sucursal = fact_sucursal
		where year(fact_fecha) = 2012
		GROUP BY prod_codigo, prod_detalle
		order by sum(item_cantidad);
;
go

drop procedure ej_2
go
/*3. Realizar una consulta que muestre código de producto, nombre de producto y el stock
total, sin importar en que deposito se encuentre, los datos deben ser ordenados por
nombre del artículo de menor a mayor.
*/

create procedure ej_3 as
	select prod_codigo as codigo, prod_detalle as nombre, sum(stoc_cantidad) as [stock total]
	from Producto
	join STOCK on prod_codigo = stoc_producto
	group by prod_codigo, prod_detalle
	order by nombre
;
go

drop procedure ej_3
go

--------------------------------------------------------------------
--4
/* Realizar una consulta que muestre para todos los art�culos c�digo, detalle y cantidad
de art�culos que lo componen. Mostrar solo aquellos art�culos para los cuales el
stock promedio por dep�sito sea mayor a 100. */

create procedure ej_4 as
	select prod_codigo as codigo, prod_detalle as detalle, count(distinct comp_componente) as [cantidad de componentes]
		from Producto
		left join Composicion on prod_codigo=comp_producto
		join Stock on prod_codigo=stoc_producto
		group by prod_codigo, prod_detalle
		having avg(stoc_cantidad)>100;
;
go
drop procedure ej_4
go

--5
/*
Realizar una consulta que muestre c�digo de art�culo, detalle y cantidad de egresos
de stock que se realizaron para ese art�culo en el a�o 2012 (egresan los productos
que fueron vendidos). Mostrar solo aquellos que hayan tenido m�s egresos que en el 2011.
*/
create procedure ej_5 as
	select prod_codigo, prod_detalle, sum(item_cantidad)
		from Producto
		join Item_Factura on
			item_producto=prod_codigo
		join Factura on 
			fact_numero=item_numero
			and fact_sucursal=item_sucursal
			and fact_tipo=item_tipo
		where year(fact_fecha)=2012
		group by prod_codigo, prod_detalle
		having sum(item_cantidad) > (
			select sum(item_cantidad)
				from Item_Factura
				join Factura on 
					fact_numero=item_numero
					and fact_sucursal=item_sucursal
					and fact_tipo=item_tipo
				where item_producto=prod_codigo
				and year(fact_fecha)=2011
		)
;
go
drop procedure ej_5
go

----------------------------------------------------------------------------------------------
print 'to-do->5-25'
go
----------------------------------------------------------------------------------------------
/*25. Realizar una consulta SQL que para cada año y familia muestre :
a. Año
b. El código de la familia más vendida en ese año.
c. Cantidad de Rubros que componen esa familia.
d. Cantidad de productos que componen directamente al producto más vendido de
esa familia.
e. La cantidad de facturas en las cuales aparecen productos pertenecientes a esa
familia.
f. El código de cliente que más compro productos de esa familia.
g. El porcentaje que representa la venta de esa familia respecto al total de venta
del año.
El resultado deberá ser ordenado por el total vendido por año y familia en forma
descendente.*/
/*
select Año, familia_mas_vendida, count(distinct rubr_id) as Rubros, (null) as Facturas from (
	select year(fact_fecha) as Año
		, (
			select top 1 prod_familia
				from Producto
				join Item_Factura on
					prod_codigo=item_producto
				join Factura f1 on
				item_numero=fact_numero
				and item_sucursal=fact_sucursal
		
				where year(f1.fact_fecha)=year(Facturas.fact_fecha)
				group by prod_familia
				order by sum(item_cantidad*item_precio)
		) as familia_mas_vendida
		
		from Factura Facturas
		group by year(fact_fecha)
) as Mas_vendida
join Producto on
	prod_familia=familia_mas_vendida
join Rubro on
	prod_rubro=rubr_id
join Item_Factura on
	item_producto=prod_codigo
join Factura on
	fact_numero=item_numero
	and fact_sucursal=item_sucursal
group by Año, familia_mas_vendida
/*	, (select top 1 fami_id) as Codigo_mas_vendida
	, count(distinct prod_rubro) as Cantidad_rubros
	, isnull((
		select top 1 sum(comp_cantidad)
			from Composicion
			join Producto on
				prod_familia=fami_id
			join Item_Factura on
				item_producto=prod_codigo
			where comp_producto=prod_codigo
			group by prod_codigo
			order by sum(item_cantidad)
	), 0) as Componentes_prod_mas_vendido

	from Familia
	join Producto on
		prod_familia=fami_id
	join Item_Factura on
		item_producto=prod_codigo
	join Factura on
		item_numero=fact_numero
		and item_sucursal=fact_sucursal
	group by year(fact_fecha), fami_id
	order by year(fact_fecha), sum(item_cantidad) desc*/
go*/
----------------------------------------------------------------------------------------------
/*26. Escriba una consulta sql que retorne un ranking de empleados devolviendo las
siguientes columnas:
 Empleado
 Depósitos que tiene a cargo
 Monto total facturado en el año corriente
 Codigo de Cliente al que mas le vendió
 Producto más vendido
 Porcentaje de la venta de ese empleado sobre el total vendido ese año.
Los datos deberan ser ordenados por venta del empleado de mayor a menor.*/

create procedure ej_26 as
	select empl_apellido as Empleado
			, (select count(distinct depo_codigo)
				from Deposito 
				where depo_encargado=empl_codigo
			)  as Depositos_a_cargo
			, isnull(sum(fact_total), 0) as Total_facturado
			, (
				select top 1 fact_cliente from Factura
					join Item_Factura on
						item_numero=fact_numero
						and item_sucursal=fact_sucursal
					where fact_vendedor=empl_codigo
					group by fact_cliente
					order by sum(item_cantidad) desc
			) as Mejor_cliente
			, (
				select top 1 item_producto from Factura
					join Item_Factura on
						item_numero=fact_numero 
						and item_sucursal=fact_sucursal
					where fact_vendedor=empl_codigo
					group by item_producto
					order by sum(item_cantidad) desc
			) as Producto_mas_vendido
			, isnull(sum(fact_total), 0)*100/ (select sum(fact_total) from Factura
			) as Porcentaje_de_venta

		from Empleado	
			left join Factura on
				fact_vendedor=empl_codigo
		group by empl_codigo, empl_apellido
		order by Total_facturado desc
;
go

drop procedure ej_26
go
----------------------------------------------------------------------------------------------
/*27. Escriba una consulta sql que retorne una estadística basada en la facturacion por año y
envase devolviendo las siguientes columnas:
 Año
 Codigo de envase
 Detalle del envase
 Cantidad de productos que tienen ese envase
 Cantidad de productos facturados de ese envase
 Producto mas vendido de ese envase
 Monto total de venta de ese envase en ese año
 Porcentaje de la venta de ese envase respecto al total vendido de ese año
Los datos deberan ser ordenados por año y dentro del año por el envase con más
facturación de mayor a menor*/
go

create procedure ej_27 as
	select year(F_gral.fact_fecha) as Año
			, enva_codigo	as Codigo
			, enva_detalle	as Detalle
			, count(distinct prod_codigo) as Cantidad_productos
			, sum(item_cantidad) as Cantidad_vendida
			, (
				select top 1 prod_detalle
					from Producto
						join Item_Factura on
							item_producto=prod_codigo
					where prod_envase=enva_codigo
					group by prod_detalle
					order by sum(item_precio*item_cantidad) desc
			) as Producto_mas_vendido
			, cast(sum(item_cantidad*item_precio) as numeric(12,2)) as Total_ventas
			, sum(item_cantidad)*100/(
				select sum(item_cantidad) from Factura F2
					join Item_Factura on
						item_numero=F2.fact_numero
						and item_sucursal=f2.fact_sucursal
					where year(f2.fact_fecha)=year(F_gral.fact_fecha)
			) as Porcentaje_de_venta

		from Envases
			join Producto on
				prod_envase=enva_codigo
			join Item_Factura on
				item_producto=prod_codigo
			join Factura F_gral on
				fact_numero=item_numero
				and fact_sucursal=item_sucursal
		group by enva_codigo, enva_detalle, year(fact_fecha)
		order by year(fact_fecha), sum(item_cantidad*item_precio) desc
;
go

drop procedure ej_27
go
----------------------------------------------------------------------------------------------
/*Escriba una consulta sql que retorne una estadística por Año y Vendedor que retorne las
siguientes columnas:
 Año.
 Codigo de Vendedor
 Detalle del Vendedor
 Cantidad de facturas que realizó en ese año
 Cantidad de clientes a los cuales les vendió en ese año.
 Cantidad de productos facturados con composición en ese año
 Cantidad de productos facturados sin composicion en ese año.
 Monto total vendido por ese vendedor en ese año
Los datos deberan ser ordenados por año y dentro del año por el vendedor que haya
vendido mas productos diferentes de mayor a menor.*/

go
create procedure ej_28 as
	select year(fact_fecha) as Año
		, empl_codigo as Codigo
		, empl_apellido as Detalle
		, count(*) as Facturas
		, count(distinct fact_cliente) as Clientes
		, (
			select count(*) from Item_Factura
				join Factura F2 on
					F2.fact_numero=item_numero
					and F2.fact_sucursal=item_sucursal
				join Composicion on
					item_producto=comp_producto
				where fact_vendedor=empl_codigo
					and year(F2.fact_fecha)=year(F1.fact_fecha)
		) as [Productos facturados con composicion]
		, (
			select count(*) from Item_factura
				join Factura F2 on
					F2.fact_numero=item_numero
					and F2.fact_sucursal=item_sucursal
				left join Composicion on
					comp_producto=item_producto
				where fact_vendedor=empl_codigo
					and year(F2.fact_fecha)=year(F1.fact_fecha)
					and comp_componente is null
		) as [Productos facturados sin composicion]
		, sum(fact_total) as [Total vendido]

		from Empleado
		join Factura F1 on 
			fact_vendedor = empl_codigo
		group by empl_codigo, year(fact_fecha), empl_apellido 
		order by Año, [Total vendido] desc
;
go

--exec ej_28

drop procedure ej_28
go
----------------------------------------------------------------------------------------------
/*29. Se solicita que realice una estadística de venta por producto para el año 2011, solo para
los productos que pertenezcan a las familias que tengan más de 20 productos asignados
a ellas, la cual deberá devolver las siguientes columnas:
a. Código de producto
b. Descripción del producto
c. Cantidad vendida
d. Cantidad de facturas en la que esta ese producto
e. Monto total facturado de ese producto
Solo se deberá mostrar un producto por fila en función a los considerandos establecidos
antes. El resultado deberá ser ordenado por el la cantidad vendida de mayor a menor*/

create procedure ej_29 as
	select prod_codigo Codigo
			, prod_detalle Detalle
			, sum(item_cantidad) Cantidad_vendida
			, count(*) as Cantidad_facturas
			, cast(sum(item_cantidad*item_precio) as numeric(12,2)) Total_facturado
		from Producto
		join Item_Factura on
			item_producto=prod_codigo
		group by prod_codigo, prod_detalle
		order by sum(item_cantidad*item_precio) desc
;
go

drop procedure ej_29
go
----------------------------------------------------------------------------------------------
/*30. Se desea obtener una estadistica de ventas del año 2012, para los empleados que sean
jefes, o sea, que tengan empleados a su cargo, para ello se requiere que realice la
consulta que retorne las siguientes columnas:
 Nombre del Jefe
 Cantidad de empleados a cargo
 Monto total vendido de los empleados a cargo
 Cantidad de facturas realizadas por los empleados a cargo
 Nombre del empleado con mejor ventas de ese jefe
Debido a la perfomance requerida, solo se permite el uso de una subconsulta si fuese
necesario.
Los datos deberan ser ordenados por de mayor a menor por el Total vendido y solo se
deben mostrarse los jefes cuyos subordinados hayan realizado más de 10 facturas.*/

create procedure ej_30 as
	select jefe.empl_apellido as Nombre
			, count(distinct Subditos.empl_codigo) as [Empleados a cargo]
			, sum(fact_total) as [Total ventas empleados a cargo]
			, count(*) as facturas_De_empleados
			, (
				select top 1 empl_codigo from Empleado e
					join Factura on
						fact_vendedor=empl_codigo
					where e.empl_jefe=jefe.empl_codigo
					group by e.empl_codigo
					order by sum(fact_total) desc
			) as [mejor vendedor]
		from Empleado jefe
		join Empleado Subditos on
			Subditos.empl_jefe=jefe.empl_codigo
		join Factura on
			fact_vendedor=Subditos.empl_codigo
		group by jefe.empl_apellido, jefe.empl_codigo
;
go

--exec ej_30

drop procedure ej_30
go
----------------------------------------------------------------------------------------------
--31. repite 28
----------------------------------------------------------------------------------------------
/*32. Se desea conocer las familias que sus productos se facturaron juntos en las mismas
facturas para ello se solicita que escriba una consulta sql que retorne los pares de
familias que tienen productos que se facturaron juntos. Para ellos deberá devolver las
siguientes columnas:
 Código de familia
 Detalle de familia
 Cantidad de facturas
 Total vendido
Los datos deberan ser ordenados por Total vendido y solo se deben mostrar las familias
que se vendieron juntas más de 10 veces.*/

create procedure ej_32 as
	select fami_id as Codigo
		, fami_detalle as Detalle
		, count(distinct fact_id) as Cantidad_facturas
		, sum(item_cantidad) as Total_vendido
		from Familia
		join Producto on
			prod_familia=fami_id
		join Item_Factura on
			item_producto=prod_codigo
		join (
			select fact_numero, fact_sucursal, fact_tipo, ROW_NUMBER() over (order by newid()) as fact_id
				from Factura
		) Facturas on
			fact_numero=item_numero
			and fact_sucursal=item_sucursal
		group by fami_id, fami_detalle
;
go

drop procedure ej_32
go
----------------------------------------------------------------------------------------------
/*33. Se requiere obtener una estadística de venta de productos que sean componentes. Para
ello se solicita que realiza la siguiente consulta que retorne la venta de los
componentes del producto más vendido del año 2012. Se deberá mostrar:
a. Código de producto
b. Nombre del producto
c. Cantidad de unidades vendidas
d. Cantidad de facturas en la cual se facturo
e. Precio promedio facturado de ese producto.
f. Total facturado para ese producto
El resultado deberá ser ordenado por el total vendido por producto para el año 2012.*/

create procedure ej_33 as
	select prod_codigo as Codigo, prod_detalle as Detalle, sum(item_cantidad) as Cantidad_vendida
		, (
			select count(*) from Factura
				join Item_Factura on 
					item_numero=fact_numero 
					and item_sucursal=fact_sucursal 
				where item_producto=prod_codigo
		) as Cantidad_facturas
		, cast(avg(item_precio) as numeric(12,2)) as Precio_promedio
		, sum(item_precio*item_cantidad) as Total_facturado
		from Producto
		join Item_Factura on
			item_producto=prod_codigo
		join Factura on
			fact_numero=item_numero
			and fact_sucursal=item_sucursal
		where year(fact_fecha)=2012
		group by prod_codigo, prod_detalle
		order by sum(item_cantidad)
;
go

drop procedure ej_33
go
----------------------------------------------------------------------------------------------
/*34. Escriba una consulta sql que retorne para todos los rubros la cantidad de facturas mal
facturadas por cada mes del año 2011 Se considera que una factura es incorrecta cuando
en la misma factura se factutan productos de dos rubros diferentes. Si no hay facturas
mal hechas se debe retornar 0. Las columnas que se deben mostrar son:
1- Codigo de Rubro
2- Mes
3- Cantidad de facturas mal realizadas.*/

create procedure facturacion_por_rubro_2011 as
	select rubr_detalle as Rubro
		, month(fact_fecha) as mes
		, (
			select count(distinct p2.prod_rubro) from Factura
				join Item_Factura i1 on
					i1.item_numero=fact_numero
					and i1.item_sucursal=fact_sucursal
				join Producto P1 on
					P1.prod_codigo=i1.item_producto
			
				left join Item_Factura i2 on
					i2.item_numero=fact_numero
					and i2.item_sucursal=fact_sucursal
				left join Producto P2 on
					p2.prod_codigo=i2.item_producto
				where p1.prod_rubro=rubr_id
					and p2.prod_rubro!=p1.prod_rubro
			
		) as Facturas_mal
		from Rubro
		join Producto
			on prod_rubro=rubr_id
		full join Item_Factura
			on item_producto=prod_codigo
		join Factura
			on	item_numero=fact_numero
			and item_sucursal=fact_sucursal
		where year(fact_fecha)=2011
		group by rubr_detalle, rubr_id, month(fact_fecha)
		order by month(fact_fecha)
;
go
--exec facturacion_por_rubro_2011 
go
drop procedure facturacion_por_rubro_2011 
go
----------------------------------------------------------------------------------------------
/*35. Se requiere realizar una estadística de ventas por año y producto, para ello se solicita
que escriba una consulta sql que retorne las siguientes columnas:
 Año
 Codigo de producto
 Detalle del producto
 Cantidad de facturas emitidas a ese producto ese año
 Cantidad de vendedores diferentes que compraron ese producto ese año.
 Cantidad de productos a los cuales compone ese producto, si no compone a ninguno
se debera retornar 0.
 Porcentaje de la venta de ese producto respecto a la venta total de ese año.
Los datos deberan ser ordenados por año y por producto con mayor cantidad vendida.*/
go
create procedure estadistica_anio_producto as
	select year(fact_fecha) as Anio, prod_codigo as Codigo, prod_detalle as Detalle, 
		(select count(*) from Factura F1
			join item_factura on
				item_numero=fact_numero
				and item_tipo=fact_tipo
				and item_sucursal=fact_sucursal
			where item_producto=prod_codigo
				and year(F1.fact_fecha)=year(F2.fact_fecha)
			) as Cantidad_Facturas
		, count(distinct fact_vendedor) as Vendedores
		, count(distinct comp_componente) as Cantidad_componentes
		, sum(item_cantidad)*100/(
			select sum(item_cantidad) from Factura F3
				join Item_Factura
					on item_tipo=fact_tipo 
					and item_sucursal=fact_sucursal 
					and item_numero=fact_numero 
				where year(F3.fact_fecha)=year(f2.fact_fecha)
		) as Porcentaje_ventas

		from Producto
			join Item_Factura on
				item_producto=prod_codigo
			join Factura F2 on 
				item_tipo=fact_tipo
				and item_numero=fact_numero
				and item_sucursal=fact_sucursal
			left join Composicion
				on comp_producto=prod_codigo
			
		group by prod_codigo, prod_detalle, year(fact_fecha)
		order by year(fact_fecha), sum(item_cantidad) desc
;
go

--exec estadistica_anio_producto 

drop procedure estadistica_anio_producto 
go