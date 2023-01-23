alter procedure sp_bg_obtenerdetallepagos
	@idestu varchar(15), @fecini date, @fecfin date, @codigobusqueda varchar(3)
as
begin
	if (@codigobusqueda='DID')
	begin
		select @idestu=codreg from Ba02Perso where numide like @idestu+'%'
	end
	if (@codigobusqueda='COD')
	begin
		select @idestu=codreg from Ba02Perso where codreg like @idestu+'%'
	end

	select codges, abreviatura, totmus, Bd11enccj.fecreg, codusr, desper, nromov from Bd11enccj 
	join ConceptosPago on Bd11enccj.codcpt=ConceptosPago.cod 
	join ba02perso on Bd11enccj.codreg=Ba02Perso.codreg 
	where Bd11enccj.codreg=@idestu and Bd11enccj.fecreg between convert(date, @fecini) and convert(date, @fecfin) 
	order by Bd11enccj.fecreg asc
end