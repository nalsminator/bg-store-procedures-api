create procedure sp_bg_listanivel
as
begin
select sigla, descri, estado from Cc01perioC where idgest=(select gesact from Cb00parametros where estado=0)
end
go
create procedure sp_bg_listasubnivel
as
begin
 select sigla, descar, estado from Ca02carre where tipcar=0 and estado=0 and idfacu<>0
end
go

create procedure sp_bg_listaclientes
 @TipoConsulta nvarchar(1),
 @CodigoTipoBusqueda nvarchar(3),
 @CodigoCliente nvarchar(30)
as
begin
 declare @idgest int, @idperi int, @estado int, @estado2 int
 /*todos*/
 if (@TipoConsulta='T') begin select @estado=0, @estado2=0 end
 /*con deuda*/
 if (@TipoConsulta='D') begin select @estado=3, @estado2=7 end
 /*por carnet*/
 if (@CodigoTipoBusqueda='DID')
 begin
	select top 1 @idgest=idgest, @idperi=idperi from Cc08inscriC join Ba02Perso on idestu=codreg
	where numide like @CodigoCliente+'%' and Cc08inscriC.estado in (0, 3) order by Cc08inscriC.fecreg desc
	select distinct @CodigoTipoBusqueda, idestu, desper, Cc01perioC.sigla, Ca02carre.sigla from cc08inscric 
	join Ba02Perso on codreg=idestu 
	join Ca02carre on Ca02carre.idcarr=cc08inscric.idcarr
	join Cc01perioC on cc08inscric.idgest=Cc01perioC.idgest and cc08inscric.idperi=Cc01perioC.idperi 
	where cc08inscric.idgest=@idgest and cc08inscric.idperi=@idperi and numide like @CodigoCliente 
	and codreg in (select coddeu from Be08enccc where estado in (@estado, @estado2))
 end 
 /*por registro*/
 if (@CodigoTipoBusqueda='COD')
 begin
	select top 1 @idgest=idgest, @idperi=idperi from Cc08inscriC where idestu like @CodigoCliente+'%' and estado in (0, 3) order by fecreg desc
	select distinct @CodigoTipoBusqueda, idestu, desper, Cc01perioC.sigla, Ca02carre.sigla from cc08inscric 
	join Ba02Perso on codreg=idestu 
	join Ca02carre on Ca02carre.idcarr=cc08inscric.idcarr
	join Cc01perioC on cc08inscric.idgest=Cc01perioC.idgest and cc08inscric.idperi=Cc01perioC.idperi 
	where cc08inscric.idgest=@idgest and cc08inscric.idperi=@idperi and idestu like @CodigoCliente+'%' 
	and codreg in (select coddeu from Be08enccc where estado in (@estado, @estado2))
 end
end
 
exec sp_bg_listaclientes 'T','COD', '56389'
exec sp_bg_listaclientes 'T','DID', '7660697'
exec sp_nombrepersona 0, 56389

go
/*deuda*/
create procedure sp_bg_deuda
	@tipo int,
	@CodigoCliente nvarchar(20),
	@nromov1 nvarchar(20) null
as
begin
		declare @interes decimal(15,2), @grpcta int, @nromov nvarchar(20), @gestion int, @AbreviaturaConceptoPago varchar(3)
	if @tipo=1
	begin
		select grpcta, nromov, codges, abreviatura from be08enccc 
		join ConceptosPago on Be08enccc.grpcta=ConceptosPago.cod 
		where be08enccc.estado in (3, 7) and coddeu like @CodigoCliente+'%'
	end
	
	if @tipo=2
	begin
		select @grpcta=grpcta, @nromov=nromov, @gestion=codges, @AbreviaturaConceptoPago=abreviatura from be08enccc 
		join ConceptosPago on Be08enccc.grpcta=ConceptosPago.cod 
		where be08enccc.nromov=@nromov1

		select top 1 @interes=cast(convert(decimal(10,2),(select case when getdate() > fecven then (((SELECT DATEDIFF(day, fecven, getdate()) * 0.05) * round(saldeu, 2)) / 100) else 0 end)) as decimal(15,2))
		from be09cuota where nromov=@nromov1 and saldeu>0 order by nrocuo asc

		select top 1 nromov, @gestion as Gestion, @AbreviaturaConceptoPago as AbreviaturaConceptoPago, 1 as Prioridad, nrocuo as NroCuota, month(fecven) as MesPeriodo, year(fecven) as AnioPeriodo, fecven as FechaVencimiento, 'BOB' as CodigoMoneda,
		Cast(CONVERT(DECIMAL(15,2),saldeu) as decimal(15,2)) as MontoConcepto, @interes as MontoMulta, 0 as MontoDescuento, (saldeu + @interes) as MontoNeto
		from be09cuota where nromov=@nromov1 and saldeu>0 order by nrocuo asc
	end
end

go
alter procedure sp_bg_nitnombre
 @CodigoCliente nvarchar(20)
as
begin
 declare @reg nvarchar(20)
 select @reg=codreg from Ba02Perso where codreg like @CodigoCliente+'%'
 select nit, nombre from Bd28Cliente where idestu=@reg
end

exec sp_bg_nitnombre 62152
go
/*parametros conexion*/
alter procedure sp_parambg
 @usuario1 nvarchar(50)
as
begin
	select usuario1, codigoconvenio, usuarioconexion, contraseniaconexion from parametrosbanco where usuario1=@usuario1
end
go
/*tabla para registrar los pagos*/
create table BGPagos(
	idpago int identity not null primary key,
	fecreg datetime not null,
	codigoconvenio int not null,
	fechatransaccion date not null,
	codigotipobusqueda varchar(3) not null,
	codigocliente varchar(30) not null,
	facturanitci int,
	facturanombre varchar(60),
	nrotransaccion int,
	usuario varchar(30),
	abreviatura varchar(20),
	nrocuota int,
	codigomoneda varchar(3),
	montoneto decimal(15,2),
	datosadicionales varchar(30)
)
go
/*procedimiento conceptos pago*/
create procedure sp_bg_conceptospago
as
begin
	select abreviatura, descripcion, estado from conceptospago
end
go
alter procedure sp_bg_registropagos
	@codigoconvenio int, @fechatransaccion date, @codigotipobusqueda varchar(3), @codigocliente varchar(30),
	@facturanitci int, @facturanombre varchar(30), @nrotransaccion int, @usuario varchar(30), @abreviatura varchar(20), @nrocuota int, 
	@codigomoneda varchar(3), @montoneto decimal(15,2), @datosadicionales varchar(30)
as
begin
	insert into BGPagos (fecreg, codigoconvenio, fechatransaccion, codigotipobusqueda, codigocliente, facturanitci, facturanombre, nrotransaccion, 
	usuario, abreviatura, nrocuota, codigomoneda, montoneto, datosadicionales) values (getdate(), @codigoconvenio, @fechatransaccion, @codigotipobusqueda, 
	@codigocliente, @facturanitci, @facturanombre, @nrotransaccion, @usuario, @abreviatura, @nrocuota, @codigomoneda, @montoneto, @datosadicionales)
end
USE SAAIUCEBOL
go
create procedure sp_bg_getcapitalorg
	@nromov varchar(20), @nrocuo int
as
begin
	declare @capamr decimal(15,2)
	select @capamr=capamr from Be09cuota where nromov=@nromov and nrocuo=@nrocuo
	if @capamr is null
	begin
		select @capamr=0
	end
	else
	begin
		select @capamr
	end
end
go
create procedure sp_bg_getinteresorg
	@nromov varchar(20), @nrocuo int
as
begin
	declare @intorg decimal(15,2)
	select @intorg=capamr from Be09cuota where nromov=@nromov and nrocuo=@nrocuo
	if @intorg is null
	begin
		select @intorg=0
	end
	else
	begin
		select @intorg
	end
end