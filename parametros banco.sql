create table parametrosbanco(
Usuario1 nvarchar(50),
CodigoConvenio int,
UsuarioConexion nvarchar(50),
ContraseniaConexion nvarchar(50)
)
go
create procedure sp_parambg
 @usuario1 nvarchar(50)
as
begin
	select usuario1, codigoconvenio, usuarioconexion, contraseniaconexion from parametrosbanco where usuario1=@usuario1
end
go
insert into parametrosbanco values ('nals', 111111, 'userbg', 123456)