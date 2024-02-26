use GD2015C1
go

/*Se necesita saber que productos no han sido vendidos durante el año 2012 pero que sí tuvieron ventas en año anteriores.
De esos productos mostrar:

Código de producto
Nombre de Producto
Un string que diga si es compuesto o no.
 El resultado deberá ser ordenado por cantidad vendida en años anteriores.

NOTA: No se permite el uso de sub-selects en el FROM ni funciones definidas por el usuario para este punto.

*/

select prod_codigo as Codigo
	, prod_detalle as Nombre
	, iif(exists (
		select comp_componente from Composicion 
			where comp_producto=prod_codigo
	), 'Si', 'No') as Compuesto
	
	from Producto
	left join Item_Factura on
		item_producto=prod_codigo
	left join Factura on
		item_tipo=fact_tipo
		and item_numero=fact_numero
		and item_sucursal=fact_sucursal
	where year(fact_fecha)<2012
		and not exists (
			select * from Factura
				join Item_Factura on
					item_tipo=fact_tipo
					and item_numero=fact_numero
					and item_sucursal=fact_sucursal	
				where year(fact_fecha)=2012
				and item_producto=prod_codigo
		)
	group by prod_codigo, prod_detalle
	order by sum(item_cantidad) Asc