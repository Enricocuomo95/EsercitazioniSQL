use HotelSognoDoro;

drop table if exists Recenzione;
drop table if exists Prenotazione;
drop table if exists Cliente;
drop table if exists Camera;
drop table if exists Facilities;
drop table if exists Dipendente;
drop table if exists Albergo;

create table Cliente(
	nome varchar(20) not null,
	cognome varchar(20) not null,
	teleforno varchar(10) not null,
	cod_fis char(18) not null,
	email varchar(20) not null,
	primary key(cod_fis)
);

--assuo per convenzione che per localizzare un albergo nel mio db
--posso identificare univocamente un albergo con la provincia e un indirizzo
--in questo modo evito di inserire due volte lo stesso albergo
--assumo per convenzione che la valutazione verrà inserita a posteriori da booking(esempio)
create table Albergo(
	id_albergo int identity(1,1),
	nome varchar(255) not null,
	indirizzo varchar(255) not null,
	valutazione int default 1,
	CHECK (valutazione BETWEEN 1 AND 5),
	unique (nome,indirizzo),
	primary key (id_albergo)	
);

--assumo per convenzione che un albergo non ha due facilites con lo stesso nome
--N.B: questa chiave candidata diventa primaria 
create table Facilities(
	albergoRif int not null,
	nome varchar(20) not null,
	descrizione varchar(255) not null,
	ora_apertura time not null,
	ora_chiusura time not null,
	CHECK (ora_apertura < ora_chiusura),
	CHECK (descrizione in ('spa','palestra','parcheggio')),
	foreign key (albergoRif) references Albergo(id_albergo) on delete cascade,
	primary key (albergoRif,nome)
);

create table Dipendente(
	albergoRif int not null,
	cod_fis char(18) not null,
	telefono varchar(10) not null,
	nome varchar(20) not null,
	cognome varchar(20) not null,
	manzione varchar(255) not null,
	CHECK (manzione in ('reception','personale pulizia','camerieri sala','cameriere camera','manager')),
	foreign key (albergoRif) references Albergo(id_albergo) on delete cascade,
	primary key (cod_fis)
);

--assumo per convenzione che un hotel non ha più di 300 camere 
--il numero di camera potrebbe essere stringa poichè non è un valore col quale devo operare,
--ma lo metto intero così ho più controllo con la check
--assumo per convenzione una camera scrausa la paghi 20 bucce
create table Camera(
	id_camera int identity(1,1),
	albergoRif int not null,
	numero_camera int not null,
	tariffa_notte int default 20,
	tipo varchar(255) not null,
	ospiti_max int default 1,
	CHECK (numero_camera BETWEEN 1 AND 300),
	CHECK (tipo in ('suite','doppia','singola')),
	foreign key (albergoRif) references Albergo(id_albergo) on delete cascade,
	unique (albergoRif,numero_camera),
	primary key(id_camera)
);

--assumo per convenzione di registrare anche le possibili prenotazioni
--in tal caso l'entità prenotazione esiste anche senza cliente
--ma in nessun caso può esistere senza camera

--devo controllare che la data di check_in della prossima tupla per camera x 
--sia diverso della data di check_out della vecchia tupla con camera x
create table Prenotazione(
	id_prenotazione int identity(1,1),
	cameraRif int not null,
	cod_fis char(18) default 'N.D.',
	check_in datetime not null,
	check_out datetime not null,
	CHECK (check_in < check_out),
	foreign key (cameraRif) references Camera (id_camera) on delete cascade,
	foreign key (cod_fis) references Cliente (cod_fis) on delete set null,
	unique (cameraRif,check_in),
	primary key(id_prenotazione)
);

create table Recenzione(
	id_recenzione int identity(1,1),
	prenotazioneRif int not null,
	valutazione int,
	nota varchar(255),
	CHECK(valutazione between 1 AND 5),
	foreign key (prenotazioneRif) references Prenotazione (id_prenotazione) on delete cascade,
	primary key (id_recenzione)
);


insert into Cliente(nome, cognome, teleforno, cod_fis, email) values
	('tipo1','cognome','33333333','123456789123456780','ffffff'),
	('tipo2','cognome','33333333','123456789123456781','ffffff'),
	('tipo3','cognome','33333333','123456789123456782','ffffff'),
	('tipo4','cognome','33333333','123456789123456783','ffffff'),
	('tipo5','cognome','33333333','123456789123456784','ffffff');

select * from Cliente;

insert into Albergo(nome, indirizzo, valutazione) values
	('sa','via pippo',1),
	('bo','via pippo',2),
	('mi','via pippo',3),
	('ro','via pippo',5);

select * from Albergo;

insert into Facilities(albergoRif, nome, descrizione, ora_apertura, ora_chiusura) values
	(1,'attività1','spa','13:30','18:30'),
	(1,'attività2','palestra','13:30','18:30'),
	(3,'attività2','spa','13:30','18:30'),
	(1,'attività4','spa','13:30','18:30');

select * from Facilities;

insert into Dipendente(albergoRif, cod_fis, telefono, nome, cognome, manzione) values
	(1, '123456789123456780', '999999', 'pippo', 'pluto', 'camerieri sala'),
	(3, '123456789123456781', '999999', 'pippo', 'pluto', 'manager'),
	(2, '123456789123456782', '999999', 'pippo', 'pluto', 'cameriere camera'),
	(1, '123456789123456783', '999999', 'pippo', 'pluto', 'camerieri sala');

select * from Dipendente;

insert into Camera(albergoRif ,numero_camera, tariffa_notte, tipo, ospiti_max) values
	(2,102,40,'doppia',3),
	(1,102,40,'doppia',3),
	(2,104,40,'doppia',3),
	(3,102,40,'doppia',3),
	(4,102,40,'doppia',3);

select * from Camera;

--lo stesso cliente prenota la stessa cmera dello stesso hotel
insert into Prenotazione (cameraRif, cod_fis, check_in, check_out) values
	(5,'123456789123456780','18-06-12 10:34:09 AM', '20-06-12 10:34:09 PM');

insert into Prenotazione (cameraRif, cod_fis, check_in, check_out) values
	(5,'123456789123456780','22-06-12 10:34:09 AM', '27-06-12 10:34:09 PM');

insert into Prenotazione (cameraRif, cod_fis, check_in, check_out) values
	(1,'123456789123456780','22-06-12 10:34:09 AM', '27-06-12 10:34:09 PM'),
	(1,'123456789123456781','23-06-12 10:34:09 AM', '27-06-12 10:34:09 PM'),
	(1,'123456789123456782','24-06-12 10:34:09 AM', '27-06-12 10:34:09 PM'),
	(2,'123456789123456783','22-06-12 10:34:09 AM', '27-06-12 10:34:09 PM'),
	(3,'123456789123456784','22-06-12 10:34:09 AM', '27-06-12 10:34:09 PM');

select* from Prenotazione;


--lo stesso cliente prenota la stessa cmera ma diverso hotel
insert into Prenotazione (cameraRif, cod_fis, check_in, check_out) values
	(5,'123456789123456781','18-07-12 10:34:09 AM', '20-08-12 10:34:09 PM');

insert into Prenotazione (cameraRif, cod_fis, check_in, check_out) values
	(4,'123456789123456781','22-07-12 10:34:09 AM', '27-08-12 10:34:09 PM');

insert into Recenzione(prenotazioneRif, valutazione, nota) values
	(1,3,'ciaobello'),
	(2,3,'ciaobello'),
	(7,3,'ciaobello'),
	(18,3,'ciaobello'),
	(7,3,'ciaobello');


select cli.nome as CLIENTE, cam.numero_camera as 'Camera prenotata',
		a.nome,a.indirizzo,a.valutazione		
	from Prenotazione p inner join Cliente cli on p.cod_fis = cli.cod_fis
	inner join Camera cam on p.cameraRif = cam.id_camera
	inner join Albergo a on cam.albergoRif = a.id_albergo
	where cli.cod_fis = '123456789123456780';


select cli.nome as CLIENTE, cam.numero_camera as 'Camera prenotata',
		a.nome,a.indirizzo,a.valutazione		
	from Prenotazione p inner join Cliente cli on p.cod_fis = cli.cod_fis
	inner join Camera cam on p.cameraRif = cam.id_camera
	inner join Albergo a on cam.albergoRif = a.id_albergo
	where cli.cod_fis = '123456789123456781';


CREATE VIEW albergoGeneraleConClienti AS
	Select al.*, cl.nome + '' + cl.cognome AS Nominativo
	From Albergo al
	join Camera ca on al.id_albergo = ca.albergoRif
	join Prenotazione p on ca.id_camera = p.cameraRif
	join Cliente cl on p.cod_fis = cl.cod_fis;

select *
	from albergoGeneraleConClienti v join Facilities f on v.id_albergo = f.albergoRif;


--voglio una view che visualizzi il nome dell'albergo e lamedia delle valutazioni fatte dagli utenti 
drop view if exists mediaAlbergo;
Create view mediaAlbergo AS
	select AVG(re.valutazione) AS 'media valutazione',al.id_albergo
	from Albergo al inner join Camera ca on al.id_albergo = ca.albergoRif
	inner join Prenotazione pr on ca.id_camera = pr.cameraRif
	inner join Recenzione re on pr.id_prenotazione = re.prenotazioneRif
	group by(al.id_albergo);

select v.[media valutazione], a.nome, a.indirizzo from mediaAlbergo v inner join Albergo a on a.id_albergo = v.id_albergo;



-- change your stored procedure to accept such a table type parameter
CREATE PROCEDURE InsertPrenotazione
	@CameraRif int,
	@ClienteRif varchar,
    @CheckOutIO Datetime,
	@CheckInIO dateTime
AS
BEGIN
    BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @CheckIn datetime
			DECLARE @checkOut datetime

			SELECT @CheckIn = [check_in]
			FROM Prenotazione
			WHERE cameraRif = 1; 

			SELECT @CheckOut = [check_out]
			FROM Prenotazione
			WHERE cameraRif = 1; 
		
			IF (@CheckInIO BETWEEN @CheckIn AND @CheckOut)
				THROW 50001, 'Prenotazione non consentita', 1	

			IF (@CheckOutIO BETWEEN @CheckIn AND @CheckOut)
				THROW 50001, 'Prenotazione non consentita', 1

			IF (@CheckInIO = @CheckIn)
				THROW 50001, 'Prenotazione non consentita', 1

			IF (@CheckOutIO = @CheckOut)
				THROW 50001, 'Prenotazione non consentita', 1
			
			select @CheckIn;
			select @checkOut;
			select *
			from Prenotazione
			where cameraRif = 1;
			insert into Prenotazione(cameraRif, cod_fis, check_in, check_out) values
			(@CameraRif,@ClienteRif,@CheckInIO,@CheckOutIO);
		COMMIT TRANSACTION
	END TRY
    BEGIN CATCH
        PRINT 'ERRORE'
		ROLLBACK
    END CATCH
END

EXEC InsertPrenotazione @CameraRif = 1,
					@ClienteRif = '123456789123456780',
					@CheckOutIO = '22-06-12 10:34:09 AM',
					@CheckInIO = '23-06-12 10:34:09 AM';








