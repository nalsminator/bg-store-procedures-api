create table BGPagos(
idpago int not null primary key,
fecreg datetime not null,
codigoconvenio int not null,
fechatransaccion datetime not null,
codigotipobusqueda varchar(3) not null,
codigocliente varchar(30) not null,
facturanitci int null,
facturanombre varchar(60) null,
nrotransaccion int not null,
nromovbd11 varchar(30) not null,
usuario varchar(30) null,
abreviatura varchar(20) null,
nrocuota int null,
codigomoneda varchar(3) null,
montoneto decimal(15,2) null,
datosadicionales varchar(30) null
)