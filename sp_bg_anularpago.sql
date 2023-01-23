create procedure sp_bg_anularpago
	@nromov varchar(30)
as
begin
	declare @nroasiento varchar(30), @nrocobza varchar(30), @nrocxc varchar(30), @totmus decimal(15, 2),
	@intorg decimal(15, 2), @caporg decimal(15, 2), @capamr decimal(15, 2), @nrocuo int, @idestu varchar(20),
	@vtc decimal(15, 2)

	select @vtc=cmbpar from a25tabtipca where feccmb=convert(date, getdate())

	select @nroasiento=Bd11enccj.nrodoc, @nrocobza=ntaorg, @nrocxc=nrocxc, @totmus=totmus, @idestu=Bd11enccj.codreg FROM Bd11enccj 
	inner join Bd12detcj on Bd11enccj.nromov=Bd12detcj.nromov 
	inner join Ba02perso on Bd11enccj.codreg=Ba02perso.codreg 
	where Bd11enccj.nromov=@nromov

	/*anular cxc*/
	DECLARE MY_CURSOR CURSOR 
	  LOCAL STATIC READ_ONLY FORWARD_ONLY
	FOR 

	select intorg, caporg, capamr, nrocuo from Be12cuoac where estado=0 and nromov=@nrocobza

	OPEN MY_CURSOR
	FETCH NEXT FROM MY_CURSOR INTO @intorg, @caporg, @capamr, @nrocuo
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		--update Be09cuota set intorg=@intorg, capamr=@caporg, saldeu=saldeu+@capamr, anulad=1
		--where nrocuo=@nrocuo and nromov=@nrocxc

		FETCH NEXT FROM MY_CURSOR INTO @intorg, @caporg, @capamr, @nrocuo
	END
	CLOSE MY_CURSOR
	DEALLOCATE MY_CURSOR

	--update Be08enccc set totamr=totamr-@totmus where nromov=@nrocxc
	--update Be11encac set estado=1 where nromov=@nrocobza
	--update Be12cuoac set estado=1 where nromov=@nrocobza

	/*anular caja*/
	--update Bd11enccj set estado=1, detobs='Anulado por banco ganadero' where nromov=@nromov
    --update Bd12detcj set estado=1 where nromov=@nromov

	/*anular contabilidad*/
	declare @VCodCcs varchar(30), @vCtaIng varchar(20), @vCtaCxC varchar(30), @GrpCta varchar(30), @vCtaBco varchar(30),
	@TotCap decimal(15, 2), @TotInt decimal(15, 2), @CtaAux varchar(30), @NroAst varchar(30), @nroact int, @gestion int,
	@cadena varchar(100)

	select @GrpCta=codcpt, @TotCap=totcap, @TotInt=totint, @VCodCcs=codccs from Be11encac 
	where nromov=@nrocobza

	select @vCtaCxC=ctactb, @vCtaIng=caaing, @CtaAux=ctaaux from Be03grpct where grpcta=@GrpCta

	select @vCtaBco='11102025'

	select @nroact=nroact+1 from bc11nroco where coddoc='CT'
	select @gestion=codges from bc02gesco where gescer=0 and estado=0
	select @NroAst=concat('CT', @nroact, '-', @gestion)
	select @cadena=concat('Por anulación: segun ingreso a caja ', @nromov)

	insert into bc12encas (codast, codges, fecmov, hormov, tipdoc, codreg, tipmon, tipcmb, detuno, totdeb, tothab, debtbs, habtbs, ntaorg, fecreg, codusr, estado) 
    values (@NroAst, @gestion, convert(date, getdate()), getdate(), 'CT', @idestu, 1, @vtc, @cadena, @totmus, @totmus, (@totmus / @vtc) , (@totmus / @vtc), @nrocobza, convert(date, getdate()), 'bg', 0)

	if @TotInt>0
	begin
		insert into bc13detas (codast, nrocor, codcta, detcta, codccs, codiaa, deborg, debmna, debmex, estado)
        values(@NroAst, 1, @vCtaCxC, (select descta from bc05plact where codcta=@vCtaCxC), @VCodCcs, @CtaAux, @TotCap, @TotCap, (@TotCap / @vtc), 0)

		insert into bc13detas (codast, nrocor, codcta, detcta, codccs, codiaa, deborg, debmna, debmex, estado)
        values(@NroAst, 2, '42102001', (select descta from bc05plact where codcta='42102001'), @VCodCcs, @CtaAux, @TotInt, @TotInt, (@TotInt / @vtc), 0)

		insert into bc13detas (codast, nrocor, codcta, detcta, codccs, haborg, habmna, habmex, estado) 
        values(@NroAst, 3, @vCtaBco, (select descta from bc05plact where codcta=@vCtaBco), @VCodCcs, @totmus, @totmus, (@totmus / @vtc), 0)
	end
	else
	begin
		insert into bc13detas (codast, nrocor, codcta, detcta, codccs, codiaa, deborg, debmna, debmex, estado)
        values(@NroAst, 1, @vCtaCxC, (select descta from bc05plact where codcta=@vCtaCxC), @VCodCcs, @CtaAux, @totmus, @totmus, (@totmus / @vtc), 0)

		insert into bc13detas (codast, nrocor, codcta, detcta, codccs, haborg, habmna, habmex, estado)
		values(@NroAst, 2, @vCtaBco, (select descta from bc05plact where codcta=@vCtaBco), @VCodCcs, @totmus, @totmus, (@totmus / @vtc), 0)
	end

	update bc11nroco set nroact=@nroact where coddoc='CT'

end