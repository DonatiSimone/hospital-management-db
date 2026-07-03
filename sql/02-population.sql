INSERT INTO Paziente (codice_fiscale, nome, cognome, data_nascita, sesso, telefono, email, indirizzo, medico_base, note_cliniche_sint) VALUES
('RSSMRA80A01H501U', 'Mario', 'Rossi', '1980-01-01', 'M', '3334444444', 'mario@mail.it', 'Via Roma 1', 'Dr. Verdi', 'Ipertensione'),
('BNCLRA85B02H501U', 'Laura', 'Bianchi', '1985-02-02', 'F', '3335555555', 'laura@mail.it', 'Via Milano 2', 'Dr. Verdi', 'Diabete'),
('VRDLGI90C03H501U', 'Luigi', 'Verdi', '1990-03-03', 'M', NULL, NULL, 'Via Torino 3', NULL, NULL);


INSERT INTO Reparto (nome, ubicazione, telefono) VALUES
('Cardiologia', 'Piano 1', '0111111111'),
('Endocrinologia', 'Piano 2', '0222222222');


INSERT INTO Medico (matricola_medico, albo_numero, nome, cognome, specializzazione, email, telefono, attivo, reparto_id) VALUES
('M001', 'ALB001', 'Luca', 'Rossi', 'Cardiologia', 'rossi@osp.it', '3331111111', TRUE, 1),
('M002', 'ALB002', 'Anna', 'Bianchi', 'Endocrinologia', 'bianchi@osp.it', '3332222222', TRUE, 2),
('M003', 'ALB003', 'Marco', 'Verdi', 'Medicina generale', 'verdi@osp.it', '3333333333', TRUE, NULL);


-- aggiorno capo reparto
UPDATE Reparto SET capo_medico_id = 1 WHERE reparto_id = 1;
UPDATE Reparto SET capo_medico_id = 2 WHERE reparto_id = 2;


INSERT INTO Ambulatorio (nome, sede, specialita, reparto_id) VALUES
('Ambulatorio Cardiologico', 'Edificio A', 'Cardiologia', 1),
('Ambulatorio Diabetologico', 'Edificio B', 'Endocrinologia', 2);


INSERT INTO Calendario_slot (ambulatorio_id, medico_id, inizio, fine, stato, fonte) VALUES
(1, 1, '2026-03-20 09:00', '2026-03-20 09:30', 'libero', 'manuale'),
(1, 1, '2026-03-20 09:30', '2026-03-20 10:00', 'occupato', 'manuale'),
(2, 2, '2026-03-20 10:00', '2026-03-20 10:30', 'libero', 'sistema');

INSERT INTO Visita_tipo VALUES
('V001', 'Visita cardiologica', 'Cardiologia', 30),
('V002', 'Visita diabetologica', 'Endocrinologia', 30);

INSERT INTO Prenotazione (paziente_id, slot_id, visita_tipo_id, priorita, motivo, stato) VALUES
(1, 2, 'V001', 'alta', 'Controllo pressione', 'prenotata'),
(2, 3, 'V002', 'media', 'Controllo glicemia', 'prenotata');


INSERT INTO Visita (prenotazione_id, anamnesi, sintomi, esame_obiettivo, vitali_testo, stato, started_at, ended_at) VALUES
(1, 'Ipertensione nota', 'Mal di testa', 'PA alta', '130/90', 'completata', '2026-03-20 09:30', '2026-03-20 10:00'),
(2, 'Diabete tipo 2', 'Stanchezza', 'Glicemia alta', '180 mg/dl', 'in corso', '2026-03-20 10:00', NULL);


INSERT INTO Esame (visita_id, tipo, codice_loinc, stato, programmato_per, eseguito_il, note) VALUES
(1, 'ECG', '1234-5', 'eseguito', '2026-03-20 09:40', '2026-03-20 09:45', 'Normale'),
(2, 'Glicemia', '2345-6', 'richiesto', '2026-03-20 10:10', NULL, NULL);


INSERT INTO Referto (esame_id, dati_strutturati, allegato_uri, autore_id, versione) VALUES
(1, '{"risultato":"normale"}', 'file://ref1.pdf', 1, 1);


INSERT INTO Dizionario_diagnosi (codice_diagnosi, descrizione, sistema, attivo) VALUES
('401.9', 'Ipertensione essenziale, non specificata', 'ICD-9', TRUE),
('250.00', 'Diabete mellito tipo II, senza complicanze, non specificato come non controllato', 'ICD-9', TRUE),
('414.01', 'Aterosclerosi coronarica del vaso nativo', 'ICD-9', TRUE),
('428.0', 'Scompenso cardiaco congestizio, non specificato', 'ICD-9', TRUE),
('427.31', 'Fibrillazione atriale', 'ICD-9', TRUE),
('272.4', 'Iperlipidemia, non specificata', 'ICD-9', TRUE),
('493.90', 'Asma, non specificata, senza menzione di stato asmatico', 'ICD-9', TRUE),
('486', 'Polmonite, agente non specificato', 'ICD-9', TRUE),
('599.0', 'Infezione delle vie urinarie, sede non specificata', 'ICD-9', TRUE),
('530.81', 'Reflusso gastroesofageo (GERD)', 'ICD-9', TRUE),
('784.0', 'Cefalea', 'ICD-9', TRUE),
('724.2', 'Lombalgia', 'ICD-9', TRUE),
('715.90', 'Osteoartrosi, sede non specificata', 'ICD-9', TRUE),
('311', 'Disturbo depressivo, non altrimenti specificato', 'ICD-9', TRUE),
('278.00', 'Obesità, non specificata', 'ICD-9', TRUE),
('244.9', 'Ipotiroidismo, non specificato', 'ICD-9', TRUE),
('285.9', 'Anemia, non specificata', 'ICD-9', TRUE),
('780.2', 'Sincope e collasso', 'ICD-9', TRUE),
('780.79', 'Altra astenia e affaticamento', 'ICD-9', TRUE),
('789.00', 'Dolore addominale, sede non specificata', 'ICD-9', TRUE);


INSERT INTO Diagnosi (visita_id, codice_diagnosi, stato, autore_medico_id, validata_il, versione) VALUES
(1, 'I10', 'validata', 1, '2026-03-20 10:00', 1),
(2, 'E11', 'provvisoria', 2, NULL, 1);


INSERT INTO AI_suggerimento (visita_id, modello_versione, candidato_codice, candidato_descr, confidenza, spiegazione) VALUES
(1, 'v1.0', 'I10', 'Ipertensione', 0.90, 'Pattern pressione'),
(2, 'v1.0', 'E11', 'Diabete', 0.85, 'Pattern glicemia');

INSERT INTO AI_azione_medico (suggerimento_id, medico_id, azione, nota) VALUES
(1, 1, 'accettato', 'Confermato'),
(2, 2, 'valutare', 'Da verificare');


INSERT INTO Consenso (paziente_id, tipo, stato, valido_dal, valido_al, note) VALUES
(1, 'privacy', 'attivo', '2026-01-01', NULL, 'OK'),
(2, 'privacy', 'attivo', '2026-01-01', NULL, 'OK');

INSERT INTO Utente_sistema (username, ruolo, medico_id, attivo) VALUES
('doc1', 'medico', 1, TRUE),
('doc2', 'medico', 2, TRUE);


INSERT INTO Log (entita, entita_id, azione, utente_id, diff_testo, ip) VALUES
('Prenotazione', 1, 'creazione', 1, 'creata prenotazione', '127.0.0.1'),
('Visita', 1, 'aggiornamento', 2, 'stato completata', '127.0.0.1');


INSERT INTO Allegato_visita (visita_id, tipo, uri, descrizione) VALUES
(1, 'pdf', 'file://referto1.pdf', 'Referto ECG'),
(2, 'pdf', 'file://referto2.pdf', 'Esame glicemia');